package client

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"sync"
	"time"

	"github.com/tunnel/pkg/config"
	"github.com/tunnel/pkg/pool"
	"github.com/tunnel/pkg/protocol"
)

// Client 客户端
type Client struct {
	config       *config.ClientConfig
	serverConn   net.Conn
	proxyConns   map[string]*ProxyConn
	proxyConnsMu sync.RWMutex
	bufferPool   *pool.BufferPool
	workerPool   *pool.WorkerPool
	running      bool
	mu           sync.Mutex
}

// ProxyConn 代理连接
type ProxyConn struct {
	ID        string
	LocalConn net.Conn
	Tunnel    *config.TunnelConfig
	CreatedAt time.Time
}

// NewClient 创建客户端
func NewClient(cfg *config.ClientConfig) *Client {
	return &Client{
		config:     cfg,
		proxyConns: make(map[string]*ProxyConn),
		bufferPool: pool.NewBufferPool(8192),
		workerPool: pool.NewWorkerPool(100),
		running:    true,
	}
}

// Start 启动客户端
func (c *Client) Start() error {
	for c.running {
		if err := c.connect(); err != nil {
			log.Printf("Connection failed: %v", err)
			log.Printf("Reconnecting in %d seconds...", c.config.Client.ReconnectInterval)
			time.Sleep(time.Duration(c.config.Client.ReconnectInterval) * time.Second)
			continue
		}
	}
	return nil
}

// connect 连接服务器
func (c *Client) connect() error {
	conn, err := net.Dial("tcp", c.config.Server.Addr)
	if err != nil {
		return fmt.Errorf("dial error: %v", err)
	}

	c.mu.Lock()
	c.serverConn = conn
	c.mu.Unlock()

	defer func() {
		conn.Close()
		c.mu.Lock()
		c.serverConn = nil
		c.mu.Unlock()

		// 关闭所有代理连接
		c.proxyConnsMu.Lock()
		for _, proxyConn := range c.proxyConns {
			if proxyConn.LocalConn != nil {
				proxyConn.LocalConn.Close()
			}
		}
		c.proxyConns = make(map[string]*ProxyConn)
		c.proxyConnsMu.Unlock()
	}()

	log.Printf("Connected to server: %s", c.config.Server.Addr)

	// 发送认证请求
	if err := c.authenticate(); err != nil {
		return fmt.Errorf("authentication failed: %v", err)
	}

	// 启动心跳
	go c.heartbeat()

	// 处理服务器消息
	return c.handleServerMessages()
}

// authenticate 认证
func (c *Client) authenticate() error {
	tunnels := make([]protocol.Tunnel, 0, len(c.config.Tunnels))
	for _, t := range c.config.Tunnels {
		tunnels = append(tunnels, protocol.Tunnel{
			Name:       t.Name,
			LocalPort:  t.LocalPort,
			RemotePort: t.RemotePort,
		})
	}

	authReq := protocol.AuthRequest{
		Token:      c.config.Server.Token,
		ClientName: c.config.Client.Name,
		Tunnels:    tunnels,
	}

	data, err := json.Marshal(authReq)
	if err != nil {
		return err
	}

	msg := &protocol.Message{
		Type:    protocol.MsgTypeAuth,
		Payload: data,
	}

	if _, err := c.serverConn.Write(msg.Encode()); err != nil {
		return err
	}

	// 读取响应
	buf := make([]byte, 4096)
	n, err := c.serverConn.Read(buf)
	if err != nil {
		return err
	}

	respMsg, err := protocol.DecodeMessage(buf[:n])
	if err != nil || respMsg == nil {
		return fmt.Errorf("invalid response")
	}

	var authResp protocol.AuthResponse
	if err := json.Unmarshal(respMsg.Payload, &authResp); err != nil {
		return err
	}

	if !authResp.Success {
		return fmt.Errorf("authentication failed: %s", authResp.Message)
	}

	log.Printf("Authentication successful (Client ID: %s)", authResp.ClientID)
	return nil
}

// heartbeat 心跳
func (c *Client) heartbeat() {
	ticker := time.NewTicker(time.Duration(c.config.Client.HeartbeatInterval) * time.Second)
	defer ticker.Stop()

	for range ticker.C {
		c.mu.Lock()
		conn := c.serverConn
		c.mu.Unlock()

		if conn == nil {
			break
		}

		msg := &protocol.Message{
			Type:    protocol.MsgTypeHeartbeat,
			Payload: []byte{},
		}

		if _, err := conn.Write(msg.Encode()); err != nil {
			log.Printf("Heartbeat error: %v", err)
			break
		}
	}
}

// handleServerMessages 处理服务器消息
func (c *Client) handleServerMessages() error {
	buf := make([]byte, 8192)
	remaining := []byte{}

	for {
		n, err := c.serverConn.Read(buf)
		if err != nil {
			if err != io.EOF {
				return fmt.Errorf("read error: %v", err)
			}
			return nil
		}

		// 追加到剩余数据
		data := append(remaining, buf[:n]...)

		for len(data) >= 5 {
			msg, err := protocol.DecodeMessage(data)
			if err != nil {
				return fmt.Errorf("decode error: %v", err)
			}

			if msg == nil {
				// 需要更多数据
				break
			}

			// 处理消息
			c.handleMessage(msg)

			// 移除已处理的数据
			data = data[5+msg.Length:]
		}

		remaining = data
	}
}

// handleMessage 处理消息
func (c *Client) handleMessage(msg *protocol.Message) {
	switch msg.Type {
	case protocol.MsgTypeNewProxy:
		var proxyReq protocol.ProxyRequest
		if err := json.Unmarshal(msg.Payload, &proxyReq); err != nil {
			log.Printf("Unmarshal proxy request error: %v", err)
			return
		}

		// 查找隧道配置
		var tunnelConfig *config.TunnelConfig
		for i := range c.config.Tunnels {
			if c.config.Tunnels[i].Name == proxyReq.TunnelName {
				tunnelConfig = &c.config.Tunnels[i]
				break
			}
		}

		if tunnelConfig == nil {
			log.Printf("Tunnel not found: %s", proxyReq.TunnelName)
			return
		}

		// 使用协程池处理
		c.workerPool.Submit(func() {
			c.handleNewProxy(proxyReq.ConnID, tunnelConfig)
		})

	case protocol.MsgTypeData:
		var dataPacket protocol.DataPacket
		if err := json.Unmarshal(msg.Payload, &dataPacket); err != nil {
			log.Printf("Unmarshal data packet error: %v", err)
			return
		}

		c.proxyConnsMu.RLock()
		proxyConn, exists := c.proxyConns[dataPacket.ConnID]
		c.proxyConnsMu.RUnlock()

		if !exists {
			return
		}

		// 写入本地连接
		if _, err := proxyConn.LocalConn.Write(dataPacket.Data); err != nil {
			log.Printf("Local conn write error: %v", err)
			proxyConn.LocalConn.Close()
		}

	case protocol.MsgTypeCloseProxy:
		var proxyReq protocol.ProxyRequest
		if err := json.Unmarshal(msg.Payload, &proxyReq); err != nil {
			return
		}

		c.proxyConnsMu.Lock()
		if proxyConn, exists := c.proxyConns[proxyReq.ConnID]; exists {
			if proxyConn.LocalConn != nil {
				proxyConn.LocalConn.Close()
			}
			delete(c.proxyConns, proxyReq.ConnID)
		}
		c.proxyConnsMu.Unlock()
	}
}

// handleNewProxy 处理新代理
func (c *Client) handleNewProxy(connID string, tunnelConfig *config.TunnelConfig) {
	// 连接本地服务
	localAddr := fmt.Sprintf("%s:%d", tunnelConfig.LocalAddr, tunnelConfig.LocalPort)
	localConn, err := net.Dial("tcp", localAddr)
	if err != nil {
		log.Printf("Failed to connect to local service %s: %v", localAddr, err)
		c.sendCloseProxy(connID)
		return
	}

	proxyConn := &ProxyConn{
		ID:        connID,
		LocalConn: localConn,
		Tunnel:    tunnelConfig,
		CreatedAt: time.Now(),
	}

	c.proxyConnsMu.Lock()
	c.proxyConns[connID] = proxyConn
	c.proxyConnsMu.Unlock()

	defer func() {
		localConn.Close()
		c.proxyConnsMu.Lock()
		delete(c.proxyConns, connID)
		c.proxyConnsMu.Unlock()
		c.sendCloseProxy(connID)
	}()

	// 转发数据(从本地到服务器)
	buf := c.bufferPool.Get()
	defer c.bufferPool.Put(buf)

	for {
		n, err := localConn.Read(buf)
		if err != nil {
			if err != io.EOF {
				log.Printf("Local conn read error: %v", err)
			}
			break
		}

		// 发送数据到服务器
		dataPacket := protocol.DataPacket{
			ConnID: connID,
			Data:   buf[:n],
		}
		data, _ := json.Marshal(dataPacket)
		msg := &protocol.Message{
			Type:    protocol.MsgTypeData,
			Payload: data,
		}

		c.mu.Lock()
		conn := c.serverConn
		c.mu.Unlock()

		if conn == nil {
			break
		}

		if _, err := conn.Write(msg.Encode()); err != nil {
			log.Printf("Failed to send data: %v", err)
			break
		}
	}
}

// sendCloseProxy 发送关闭代理消息
func (c *Client) sendCloseProxy(connID string) {
	proxyReq := protocol.ProxyRequest{
		ConnID: connID,
	}
	data, _ := json.Marshal(proxyReq)
	msg := &protocol.Message{
		Type:    protocol.MsgTypeCloseProxy,
		Payload: data,
	}

	c.mu.Lock()
	conn := c.serverConn
	c.mu.Unlock()

	if conn != nil {
		if _, err := conn.Write(msg.Encode()); err != nil {
			log.Printf("Failed to send heartbeat: %v", err)
		}
	}
}

// Stop 停止客户端
func (c *Client) Stop() {
	c.mu.Lock()
	c.running = false
	if c.serverConn != nil {
		c.serverConn.Close()
	}
	c.mu.Unlock()

	c.workerPool.Stop()
}
