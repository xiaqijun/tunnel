package server

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
)

// WebAPI Web管理接口
type WebAPI struct {
	server   *Server
	upgrader websocket.Upgrader
}

// NewWebAPI 创建Web API
func NewWebAPI(server *Server) *WebAPI {
	return &WebAPI{
		server: server,
		upgrader: websocket.Upgrader{
			CheckOrigin: func(r *http.Request) bool {
				return true // 允许所有来源
			},
		},
	}
}

// Start 启动Web服务
func (w *WebAPI) Start(addr string, port int) error {
	r := mux.NewRouter()

	// API路由
	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/clients", w.handleGetClients).Methods("GET")
	api.HandleFunc("/clients/{id}", w.handleGetClient).Methods("GET")
	api.HandleFunc("/stats", w.handleGetStats).Methods("GET")
	api.HandleFunc("/ws", w.handleWebSocket).Methods("GET")
	api.HandleFunc("/install", w.handleGetInstallCommand).Methods("GET")
	api.HandleFunc("/download/client/{os}/{arch}", w.handleDownloadClient).Methods("GET")

	// 静态文件
	r.PathPrefix("/").Handler(http.FileServer(http.Dir("./web")))

	address := fmt.Sprintf("%s:%d", addr, port)
	log.Printf("Web API listening on http://%s", address)

	return http.ListenAndServe(address, r)
}

// ClientInfo 客户端信息
type ClientInfo struct {
	ID              string       `json:"id"`
	Name            string       `json:"name"`
	Connected       bool         `json:"connected"`
	LastSeen        time.Time    `json:"last_seen"`
	Tunnels         []TunnelInfo `json:"tunnels"`
	BytesSent       uint64       `json:"bytes_sent"`
	BytesReceived   uint64       `json:"bytes_received"`
	ConnectionCount uint64       `json:"connection_count"`
}

// TunnelInfo 隧道信息
type TunnelInfo struct {
	Name       string `json:"name"`
	LocalPort  int    `json:"local_port"`
	RemotePort int    `json:"remote_port"`
	Active     bool   `json:"active"`
}

// handleGetClients 获取所有客户端
func (w *WebAPI) handleGetClients(rw http.ResponseWriter, r *http.Request) {
	clients := w.server.GetClients()

	clientInfos := make([]ClientInfo, 0, len(clients))
	for _, client := range clients {
		client.mu.RLock()
		tunnels := make([]TunnelInfo, 0, len(client.Tunnels))
		for _, tunnel := range client.Tunnels {
			tunnels = append(tunnels, TunnelInfo{
				Name:       tunnel.Name,
				LocalPort:  tunnel.LocalPort,
				RemotePort: tunnel.RemotePort,
				Active:     tunnel.Active,
			})
		}
		client.mu.RUnlock()

		client.stats.mu.RLock()
		info := ClientInfo{
			ID:              client.ID,
			Name:            client.Name,
			Connected:       true,
			LastSeen:        client.LastSeen,
			Tunnels:         tunnels,
			BytesSent:       client.stats.BytesSent,
			BytesReceived:   client.stats.BytesReceived,
			ConnectionCount: client.stats.ConnectionCount,
		}
		client.stats.mu.RUnlock()

		clientInfos = append(clientInfos, info)
	}

	rw.Header().Set("Content-Type", "application/json")
	json.NewEncoder(rw).Encode(map[string]interface{}{
		"success": true,
		"data":    clientInfos,
	})
}

// handleGetClient 获取单个客户端
func (w *WebAPI) handleGetClient(rw http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	clientID := vars["id"]

	w.server.clientsMu.RLock()
	client, exists := w.server.clients[clientID]
	w.server.clientsMu.RUnlock()

	if !exists {
		rw.WriteHeader(http.StatusNotFound)
		json.NewEncoder(rw).Encode(map[string]interface{}{
			"success": false,
			"message": "Client not found",
		})
		return
	}

	client.mu.RLock()
	tunnels := make([]TunnelInfo, 0, len(client.Tunnels))
	for _, tunnel := range client.Tunnels {
		tunnels = append(tunnels, TunnelInfo{
			Name:       tunnel.Name,
			LocalPort:  tunnel.LocalPort,
			RemotePort: tunnel.RemotePort,
			Active:     tunnel.Active,
		})
	}
	client.mu.RUnlock()

	client.stats.mu.RLock()
	info := ClientInfo{
		ID:              client.ID,
		Name:            client.Name,
		Connected:       true,
		LastSeen:        client.LastSeen,
		Tunnels:         tunnels,
		BytesSent:       client.stats.BytesSent,
		BytesReceived:   client.stats.BytesReceived,
		ConnectionCount: client.stats.ConnectionCount,
	}
	client.stats.mu.RUnlock()

	rw.Header().Set("Content-Type", "application/json")
	json.NewEncoder(rw).Encode(map[string]interface{}{
		"success": true,
		"data":    info,
	})
}

// handleGetStats 获取统计信息
func (w *WebAPI) handleGetStats(rw http.ResponseWriter, r *http.Request) {
	clients := w.server.GetClients()

	var totalBytesSent, totalBytesReceived, totalConnections uint64

	for _, client := range clients {
		client.stats.mu.RLock()
		totalBytesSent += client.stats.BytesSent
		totalBytesReceived += client.stats.BytesReceived
		totalConnections += client.stats.ConnectionCount
		client.stats.mu.RUnlock()
	}

	w.server.proxyConnsMu.RLock()
	activeConnections := len(w.server.proxyConns)
	w.server.proxyConnsMu.RUnlock()

	stats := map[string]interface{}{
		"total_clients":        len(clients),
		"active_connections":   activeConnections,
		"total_bytes_sent":     totalBytesSent,
		"total_bytes_received": totalBytesReceived,
		"total_connections":    totalConnections,
	}

	rw.Header().Set("Content-Type", "application/json")
	json.NewEncoder(rw).Encode(map[string]interface{}{
		"success": true,
		"data":    stats,
	})
}

// handleWebSocket 处理WebSocket连接
func (w *WebAPI) handleWebSocket(rw http.ResponseWriter, r *http.Request) {
	conn, err := w.upgrader.Upgrade(rw, r, nil)
	if err != nil {
		log.Printf("WebSocket upgrade error: %v", err)
		return
	}
	defer conn.Close()

	// 定时推送更新
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for range ticker.C {
		clients := w.server.GetClients()

		clientInfos := make([]ClientInfo, 0, len(clients))
		for _, client := range clients {
			client.mu.RLock()
			tunnels := make([]TunnelInfo, 0, len(client.Tunnels))
			for _, tunnel := range client.Tunnels {
				tunnels = append(tunnels, TunnelInfo{
					Name:       tunnel.Name,
					LocalPort:  tunnel.LocalPort,
					RemotePort: tunnel.RemotePort,
					Active:     tunnel.Active,
				})
			}
			client.mu.RUnlock()

			client.stats.mu.RLock()
			info := ClientInfo{
				ID:              client.ID,
				Name:            client.Name,
				Connected:       true,
				LastSeen:        client.LastSeen,
				Tunnels:         tunnels,
				BytesSent:       client.stats.BytesSent,
				BytesReceived:   client.stats.BytesReceived,
				ConnectionCount: client.stats.ConnectionCount,
			}
			client.stats.mu.RUnlock()

			clientInfos = append(clientInfos, info)
		}

		if err := conn.WriteJSON(clientInfos); err != nil {
			log.Printf("WebSocket write error: %v", err)
			break
		}
	}
}

// handleGetInstallCommand 获取安装命令
func (w *WebAPI) handleGetInstallCommand(rw http.ResponseWriter, r *http.Request) {
	host := r.Host
	if host == "" {
		host = "localhost:8080"
	}

	installCommands := map[string]interface{}{
		"windows": map[string]string{
			"powershell": fmt.Sprintf(`irm http://%s/api/download/client/windows/amd64 -OutFile tunnel-client.exe; .\tunnel-client.exe -config client-config.yaml`, host),
			"cmd":        fmt.Sprintf(`curl -o tunnel-client.exe http://%s/api/download/client/windows/amd64 && tunnel-client.exe -config client-config.yaml`, host),
		},
		"linux": map[string]string{
			"bash": fmt.Sprintf(`curl -fsSL http://%s/api/download/client/linux/amd64 -o tunnel-client && chmod +x tunnel-client && ./tunnel-client -config client-config.yaml`, host),
			"wget": fmt.Sprintf(`wget http://%s/api/download/client/linux/amd64 -O tunnel-client && chmod +x tunnel-client && ./tunnel-client -config client-config.yaml`, host),
		},
		"darwin": map[string]string{
			"bash": fmt.Sprintf(`curl -fsSL http://%s/api/download/client/darwin/amd64 -o tunnel-client && chmod +x tunnel-client && ./tunnel-client -config client-config.yaml`, host),
		},
		"config_template": map[string]interface{}{
			"server": "SERVER_ADDRESS:7000",
			"token":  "YOUR_TOKEN",
			"client": map[string]interface{}{
				"name": "my-client",
			},
			"tunnels": []map[string]interface{}{
				{
					"name":        "web",
					"local_port":  8080,
					"remote_port": 8080,
				},
			},
		},
	}

	rw.Header().Set("Content-Type", "application/json")
	json.NewEncoder(rw).Encode(map[string]interface{}{
		"success": true,
		"data":    installCommands,
	})
}

// handleDownloadClient 下载客户端
func (w *WebAPI) handleDownloadClient(rw http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	osType := vars["os"]
	_ = vars["arch"] // 目前仅使用 os 参数，arch 保留给未来使用

	// 构建客户端文件路径
	var clientPath string
	if osType == "windows" {
		clientPath = "./bin/tunnel-client.exe"
	} else {
		clientPath = "./bin/tunnel-client"
	}

	// 检查文件是否存在
	http.ServeFile(rw, r, clientPath)
}
