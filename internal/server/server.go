package server

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"sync"
	"time"
	
	"github.com/tunnel/pkg/pool"
	"github.com/tunnel/pkg/protocol"
)

// Client 客户端连接
type Client struct {
	ID       string
	Name     string
	Conn     net.Conn
	Tunnels  map[string]*Tunnel
	LastSeen time.Time
	mu       sync.RWMutex
	stats    *ClientStats
}

// ClientStats 客户端统计
type ClientStats struct {
	BytesSent     uint64
	BytesReceived uint64
	ConnectionCount uint64
	mu            sync.RWMutex
}

// Tunnel 隧道信息
type Tunnel struct {
	Name       string
	LocalPort  int
	RemotePort int
	Listener   net.Listener
	Active     bool
}

// Server 服务器
type Server struct {
	config      *ServerConfig
	clients     map[string]*Client
	clientsMu   sync.RWMutex
	bufferPool  *pool.BufferPool
	workerPool  *pool.WorkerPool
	proxyConns  map[string]*ProxyConn
	proxyConnsMu sync.RWMutex
}

// ServerConfig 服务器配置
type ServerConfig struct {
	BindAddr        string
	BindPort        int
	Token           string
	MaxConnections  int
	ReadBufferSize  int
	WriteBufferSize int
	WorkerPoolSize  int
}

// ProxyConn 代理连接
type ProxyConn struct {
	ID         string
	ClientConn net.Conn
	UserConn   net.Conn
	Client     *Client
	TunnelName string
	CreatedAt  time.Time
}

// NewServer 创建服务器
func NewServer(config *ServerConfig) *Server {
	return &Server{
		config:     config,
		clients:    make(map[string]*Client),
		proxyConns: make(map[string]*ProxyConn),
		bufferPool: pool.NewBufferPool(config.ReadBufferSize),
		workerPool: pool.NewWorkerPool(config.WorkerPoolSize),
	}
}

// Start 启动服务器
func (s *Server) Start() error {
	addr := fmt.Sprintf("%s:%d", s.config.BindAddr, s.config.BindPort)
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		return fmt.Errorf("failed to listen: %v", err)
	}
	
	log.Printf("Tunnel server listening on %s", addr)
	
	for {
		conn, err := listener.Accept()
		if err != nil {
			log.Printf("Accept error: %v", err)
			continue
		}
		
		go s.handleConnection(conn)
	}
}

// handleConnection 处理客户端连接
func (s *Server) handleConnection(conn net.Conn) {
	defer conn.Close()
	
	// 设置读取超时
	if err := conn.SetReadDeadline(time.Now().Add(30 * time.Second)); err != nil {
		log.Printf("Failed to set read deadline: %v", err)
		return
	}
	
	// 读取认证消息
	buf := make([]byte, 4096)
	n, err := conn.Read(buf)
	if err != nil {
		log.Printf("Read auth error: %v", err)
		return
	}
	
	msg, err := protocol.DecodeMessage(buf[:n])
	if err != nil || msg == nil || msg.Type != protocol.MsgTypeAuth {
		log.Printf("Invalid auth message")
		return
	}
	
	var authReq protocol.AuthRequest
	if err := json.Unmarshal(msg.Payload, &authReq); err != nil {
		log.Printf("Unmarshal auth error: %v", err)
		return
	}
	
	// 验证token
	if authReq.Token != s.config.Token {
		s.sendAuthResponse(conn, false, "Invalid token", "")
		return
	}
	
	// 创建客户端
	client := &Client{
		ID:       generateID(),
		Name:     authReq.ClientName,
		Conn:     conn,
		Tunnels:  make(map[string]*Tunnel),
		LastSeen: time.Now(),
		stats:    &ClientStats{},
	}
	
	// 注册客户端
	s.clientsMu.Lock()
	s.clients[client.ID] = client
	s.clientsMu.Unlock()
	
	log.Printf("Client connected: %s (%s)", client.Name, client.ID)
	
	// 发送认证成功响应
	s.sendAuthResponse(conn, true, "Authentication successful", client.ID)
	
	// 启动隧道
	for _, tunnelConfig := range authReq.Tunnels {
		if err := s.startTunnel(client, tunnelConfig); err != nil {
			log.Printf("Failed to start tunnel %s: %v", tunnelConfig.Name, err)
		}
	}
	
	// 清除读取超时
	if err := conn.SetReadDeadline(time.Time{}); err != nil {
		log.Printf("Failed to clear read deadline: %v", err)
	}
	
	// 处理客户端消息
	s.handleClientMessages(client)
	
	// 清理客户端
	s.cleanupClient(client)
}

// sendAuthResponse 发送认证响应
func (s *Server) sendAuthResponse(conn net.Conn, success bool, message, clientID string) {
	resp := protocol.AuthResponse{
		Success:  success,
		Message:  message,
		ClientID: clientID,
	}
	
	data, _ := json.Marshal(resp)
	msg := &protocol.Message{
		Type:    protocol.MsgTypeAuthResp,
		Payload: data,
	}
	
	if _, err := conn.Write(msg.Encode()); err != nil {
		log.Printf("Failed to write auth response: %v", err)
	}
}

// startTunnel 启动隧道
func (s *Server) startTunnel(client *Client, config protocol.Tunnel) error {
	addr := fmt.Sprintf("0.0.0.0:%d", config.RemotePort)
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		return err
	}
	
	tunnel := &Tunnel{
		Name:       config.Name,
		LocalPort:  config.LocalPort,
		RemotePort: config.RemotePort,
		Listener:   listener,
		Active:     true,
	}
	
	client.mu.Lock()
	client.Tunnels[config.Name] = tunnel
	client.mu.Unlock()
	
	log.Printf("Tunnel started: %s -> %s:%d (client: %s)", 
		addr, client.Name, config.LocalPort, client.ID)
	
	// 启动监听
	go s.acceptTunnelConnections(client, tunnel)
	
	return nil
}

// acceptTunnelConnections 接受隧道连接
func (s *Server) acceptTunnelConnections(client *Client, tunnel *Tunnel) {
	for tunnel.Active {
		conn, err := tunnel.Listener.Accept()
		if err != nil {
			if tunnel.Active {
				log.Printf("Tunnel accept error: %v", err)
			}
			break
		}
		
		// 使用协程池处理连接
		s.workerPool.Submit(func() {
			s.handleTunnelConnection(client, tunnel, conn)
		})
	}
}

// handleTunnelConnection 处理隧道连接
func (s *Server) handleTunnelConnection(client *Client, tunnel *Tunnel, userConn net.Conn) {
	connID := generateID()
	
	// 创建代理连接
	proxyConn := &ProxyConn{
		ID:         connID,
		UserConn:   userConn,
		Client:     client,
		TunnelName: tunnel.Name,
		CreatedAt:  time.Now(),
	}
	
	s.proxyConnsMu.Lock()
	s.proxyConns[connID] = proxyConn
	s.proxyConnsMu.Unlock()
	
	defer func() {
		userConn.Close()
		s.proxyConnsMu.Lock()
		delete(s.proxyConns, connID)
		s.proxyConnsMu.Unlock()
	}()
	
	// 通知客户端建立新代理
	proxyReq := protocol.ProxyRequest{
		TunnelName: tunnel.Name,
		ConnID:     connID,
	}
	data, _ := json.Marshal(proxyReq)
	msg := &protocol.Message{
		Type:    protocol.MsgTypeNewProxy,
		Payload: data,
	}
	
	client.mu.Lock()
	_, err := client.Conn.Write(msg.Encode())
	client.mu.Unlock()
	
	if err != nil {
		log.Printf("Failed to send proxy request: %v", err)
		return
	}
	
	// 更新统计
	client.stats.mu.Lock()
	client.stats.ConnectionCount++
	client.stats.mu.Unlock()
	
	// 转发数据 (从用户到客户端)
	buf := s.bufferPool.Get()
	defer s.bufferPool.Put(buf)
	
	for {
		n, err := userConn.Read(buf)
		if err != nil {
			if err != io.EOF {
				log.Printf("User conn read error: %v", err)
			}
			break
		}
		
		// 发送数据到客户端
		dataPacket := protocol.DataPacket{
			ConnID: connID,
			Data:   buf[:n],
		}
		data, _ := json.Marshal(dataPacket)
		msg := &protocol.Message{
			Type:    protocol.MsgTypeData,
			Payload: data,
		}
		
		client.mu.Lock()
		_, err = client.Conn.Write(msg.Encode())
		client.mu.Unlock()
		
		if err != nil {
			log.Printf("Failed to send data: %v", err)
			break
		}
		
		// 更新统计
		client.stats.mu.Lock()
		client.stats.BytesSent += uint64(n)
		client.stats.mu.Unlock()
	}
}

// handleClientMessages 处理客户端消息
func (s *Server) handleClientMessages(client *Client) {
	buf := make([]byte, s.config.ReadBufferSize)
	remaining := []byte{}
	
	for {
		n, err := client.Conn.Read(buf)
		if err != nil {
			if err != io.EOF {
				log.Printf("Client read error: %v", err)
			}
			break
		}
		
		// 追加到剩余数据
		data := append(remaining, buf[:n]...)
		
		for len(data) >= 5 {
			msg, err := protocol.DecodeMessage(data)
			if err != nil {
				log.Printf("Decode error: %v", err)
				break
			}
			
			if msg == nil {
				// 需要更多数据
				break
			}
			
			// 处理消息
			s.handleMessage(client, msg)
			
			// 移除已处理的数据
			data = data[5+msg.Length:]
		}
		
		remaining = data
		
		// 更新最后seen时间
		client.LastSeen = time.Now()
	}
}

// handleMessage 处理消息
func (s *Server) handleMessage(client *Client, msg *protocol.Message) {
	switch msg.Type {
	case protocol.MsgTypeHeartbeat:
		// 心跳响应
		client.LastSeen = time.Now()
		
	case protocol.MsgTypeData:
		// 数据传输
		var dataPacket protocol.DataPacket
		if err := json.Unmarshal(msg.Payload, &dataPacket); err != nil {
			log.Printf("Unmarshal data packet error: %v", err)
			return
		}
		
		s.proxyConnsMu.RLock()
		proxyConn, exists := s.proxyConns[dataPacket.ConnID]
		s.proxyConnsMu.RUnlock()
		
		if !exists {
			return
		}
		
		// 写入用户连接
		_, err := proxyConn.UserConn.Write(dataPacket.Data)
		if err != nil {
			log.Printf("User conn write error: %v", err)
			proxyConn.UserConn.Close()
			return
		}
		
		// 更新统计
		client.stats.mu.Lock()
		client.stats.BytesReceived += uint64(len(dataPacket.Data))
		client.stats.mu.Unlock()
		
	case protocol.MsgTypeCloseProxy:
		// 关闭代理
		var proxyReq protocol.ProxyRequest
		if err := json.Unmarshal(msg.Payload, &proxyReq); err != nil {
			return
		}
		
		s.proxyConnsMu.Lock()
		if proxyConn, exists := s.proxyConns[proxyReq.ConnID]; exists {
			proxyConn.UserConn.Close()
			delete(s.proxyConns, proxyReq.ConnID)
		}
		s.proxyConnsMu.Unlock()
	}
}

// cleanupClient 清理客户端
func (s *Server) cleanupClient(client *Client) {
	log.Printf("Client disconnected: %s (%s)", client.Name, client.ID)
	
	// 关闭所有隧道
	client.mu.Lock()
	for _, tunnel := range client.Tunnels {
		tunnel.Active = false
		if tunnel.Listener != nil {
			tunnel.Listener.Close()
		}
	}
	client.mu.Unlock()
	
	// 移除客户端
	s.clientsMu.Lock()
	delete(s.clients, client.ID)
	s.clientsMu.Unlock()
	
	// 关闭所有代理连接
	s.proxyConnsMu.Lock()
	for id, proxyConn := range s.proxyConns {
		if proxyConn.Client == client {
			proxyConn.UserConn.Close()
			delete(s.proxyConns, id)
		}
	}
	s.proxyConnsMu.Unlock()
}

// GetClients 获取所有客户端
func (s *Server) GetClients() []*Client {
	s.clientsMu.RLock()
	defer s.clientsMu.RUnlock()
	
	clients := make([]*Client, 0, len(s.clients))
	for _, client := range s.clients {
		clients = append(clients, client)
	}
	return clients
}

// generateID 生成唯一ID
func generateID() string {
	return fmt.Sprintf("%d", time.Now().UnixNano())
}
