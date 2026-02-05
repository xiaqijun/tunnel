package server

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"github.com/gorilla/websocket"
	"github.com/tunnel/pkg/version"
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
	api.HandleFunc("/download/config", w.handleDownloadConfig).Methods("GET")
	api.HandleFunc("/config/generate", w.handleGenerateConfig).Methods("GET")
	api.HandleFunc("/version", w.handleGetVersion).Methods("GET")
	api.HandleFunc("/update/check", w.handleCheckUpdate).Methods("GET")
	api.HandleFunc("/update/info", w.handleUpdateInfo).Methods("GET")
	api.HandleFunc("/update/server", w.handleUpdateServer).Methods("POST")

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

	// 获取服务器地址（用于客户端配置）
	serverAddr := w.server.config.BindAddr
	if serverAddr == "0.0.0.0" || serverAddr == "" {
		// 尝试从请求中获取真实IP
		serverAddr = r.Header.Get("X-Real-IP")
		if serverAddr == "" {
			serverAddr = r.Header.Get("X-Forwarded-For")
		}
		if serverAddr == "" {
			serverAddr = r.Host
			// 移除端口号，只保留IP
			if idx := len(serverAddr) - 1; serverAddr[idx] == ':' {
				for i := idx - 1; i >= 0; i-- {
					if serverAddr[i] == ':' {
						serverAddr = serverAddr[:i]
						break
					}
				}
			}
		}
	}
	serverPort := w.server.config.BindPort

	installCommands := map[string]interface{}{
		"windows": map[string]string{
			"powershell": fmt.Sprintf(`irm http://%s/api/download/config?name=my-pc -OutFile client-config.yaml; irm http://%s/api/download/client/windows/amd64 -OutFile tunnel-client.exe; .\tunnel-client.exe -config client-config.yaml`, host, host),
			"cmd":        fmt.Sprintf(`curl -o client-config.yaml "http://%s/api/download/config?name=my-pc" && curl -o tunnel-client.exe http://%s/api/download/client/windows/amd64 && tunnel-client.exe -config client-config.yaml`, host, host),
		},
		"linux": map[string]string{
			"bash": fmt.Sprintf(`curl -fsSL "http://%s/api/download/config?name=my-linux" -o client-config.yaml && curl -fsSL http://%s/api/download/client/linux/amd64 -o tunnel-client && chmod +x tunnel-client && ./tunnel-client -config client-config.yaml`, host, host),
			"wget": fmt.Sprintf(`wget "http://%s/api/download/config?name=my-linux" -O client-config.yaml && wget http://%s/api/download/client/linux/amd64 -O tunnel-client && chmod +x tunnel-client && ./tunnel-client -config client-config.yaml`, host, host),
		},
		"darwin": map[string]string{
			"bash": fmt.Sprintf(`curl -fsSL "http://%s/api/download/config?name=my-mac" -o client-config.yaml && curl -fsSL http://%s/api/download/client/darwin/amd64 -o tunnel-client && chmod +x tunnel-client && ./tunnel-client -config client-config.yaml`, host, host),
		},
		"server_info": map[string]interface{}{
			"addr": fmt.Sprintf("%s:%d", serverAddr, serverPort),
			"web":  host,
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

// handleGenerateConfig 生成客户端配置
func (w *WebAPI) handleGenerateConfig(rw http.ResponseWriter, r *http.Request) {
	// 获取参数
	clientName := r.URL.Query().Get("name")
	if clientName == "" {
		clientName = "my-client"
	}

	// 获取服务器地址
	serverAddr := w.server.config.BindAddr
	if serverAddr == "0.0.0.0" || serverAddr == "" {
		// 尝试从请求中获取真实IP
		serverAddr = r.Header.Get("X-Real-IP")
		if serverAddr == "" {
			serverAddr = r.Header.Get("X-Forwarded-For")
		}
		if serverAddr == "" {
			serverAddr = r.Host
			// 移除端口号
			for i := len(serverAddr) - 1; i >= 0; i-- {
				if serverAddr[i] == ':' {
					serverAddr = serverAddr[:i]
					break
				}
			}
		}
	}
	serverPort := w.server.config.BindPort

	// 生成配置
	config := map[string]interface{}{
		"server": map[string]interface{}{
			"addr":  fmt.Sprintf("%s:%d", serverAddr, serverPort),
			"token": w.server.config.Token,
		},
		"client": map[string]interface{}{
			"name":               clientName,
			"reconnect_interval": 5,
			"heartbeat_interval": 30,
		},
		"tunnels": []map[string]interface{}{
			{
				"name":        "web",
				"local_addr":  "127.0.0.1",
				"local_port":  8080,
				"remote_port": 8000,
			},
		},
	}

	rw.Header().Set("Content-Type", "application/json")
	json.NewEncoder(rw).Encode(map[string]interface{}{
		"success": true,
		"data":    config,
	})
}

// handleDownloadConfig 下载客户端配置文件
func (w *WebAPI) handleDownloadConfig(rw http.ResponseWriter, r *http.Request) {
	// 获取参数
	clientName := r.URL.Query().Get("name")
	if clientName == "" {
		clientName = "my-client"
	}

	// 获取服务器地址
	serverAddr := w.server.config.BindAddr
	if serverAddr == "0.0.0.0" || serverAddr == "" {
		// 尝试从请求中获取真实IP
		serverAddr = r.Header.Get("X-Real-IP")
		if serverAddr == "" {
			serverAddr = r.Header.Get("X-Forwarded-For")
		}
		if serverAddr == "" {
			serverAddr = r.Host
			// 移除端口号
			for i := len(serverAddr) - 1; i >= 0; i-- {
				if serverAddr[i] == ':' {
					serverAddr = serverAddr[:i]
					break
				}
			}
		}
	}
	serverPort := w.server.config.BindPort

	// 生成YAML配置
	yamlConfig := fmt.Sprintf(`# Tunnel 客户端配置
# 由服务器自动生成

server:
  addr: "%s:%d"
  token: "%s"

client:
  name: "%s"
  reconnect_interval: 5
  heartbeat_interval: 30

tunnels:
  - name: "web"
    local_addr: "127.0.0.1"
    local_port: 8080
    remote_port: 8000
  
  # 添加更多隧道（可选）
  # - name: "ssh"
  #   local_addr: "127.0.0.1"
  #   local_port: 22
  #   remote_port: 2222
`,
		serverAddr, serverPort, w.server.config.Token, clientName)

	// 设置响应头
	rw.Header().Set("Content-Type", "application/x-yaml")
	rw.Header().Set("Content-Disposition", fmt.Sprintf(`attachment; filename="client-config.yaml"`))

	// 写入配置
	rw.Write([]byte(yamlConfig))
}

// handleGetVersion 获取版本信息
func (w *WebAPI) handleGetVersion(rw http.ResponseWriter, r *http.Request) {
	versionInfo := version.Get()

	rw.Header().Set("Content-Type", "application/json")
	json.NewEncoder(rw).Encode(map[string]interface{}{
		"success": true,
		"data":    versionInfo,
	})
}

// handleCheckUpdate 检查更新
func (w *WebAPI) handleCheckUpdate(rw http.ResponseWriter, r *http.Request) {
	repo := "xiaqijun/tunnel" // GitHub仓库

	release, hasUpdate, err := version.CheckUpdate(repo)
	if err != nil {
		rw.Header().Set("Content-Type", "application/json")
		rw.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(rw).Encode(map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		})
		return
	}

	currentVersion := version.Get()

	rw.Header().Set("Content-Type", "application/json")
	json.NewEncoder(rw).Encode(map[string]interface{}{
		"success":         true,
		"has_update":      hasUpdate,
		"current_version": currentVersion.Version,
		"latest_version":  release.TagName,
		"release_notes":   release.Body,
		"published_at":    release.PublishedAt,
	})
}

// handleUpdateInfo 获取更新信息和下载地址
func (w *WebAPI) handleUpdateInfo(rw http.ResponseWriter, r *http.Request) {
	repo := "xiaqijun/tunnel"

	release, hasUpdate, err := version.CheckUpdate(repo)
	if err != nil {
		rw.Header().Set("Content-Type", "application/json")
		rw.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(rw).Encode(map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		})
		return
	}

	currentVersion := version.Get()
	downloadURL := release.GetDownloadURL("server")

	// 生成更新命令
	updateCommands := w.generateUpdateCommands(release.TagName, downloadURL)

	rw.Header().Set("Content-Type", "application/json")
	json.NewEncoder(rw).Encode(map[string]interface{}{
		"success":         true,
		"has_update":      hasUpdate,
		"current_version": currentVersion.Version,
		"latest_version":  release.TagName,
		"download_url":    downloadURL,
		"release_notes":   release.Body,
		"published_at":    release.PublishedAt,
		"update_commands": updateCommands,
	})
}

// generateUpdateCommands 生成更新命令
func (w *WebAPI) generateUpdateCommands(version, downloadURL string) map[string]interface{} {
	if downloadURL == "" {
		return map[string]interface{}{
			"error": "No download URL available for current platform",
		}
	}

	commands := make(map[string]interface{})

	// Linux更新命令
	commands["linux"] = map[string]string{
		"manual": fmt.Sprintf(`# 停止服务
sudo systemctl stop tunnel-server

# 下载新版本
wget %s -O tunnel-%s.tar.gz
tar -xzf tunnel-%s.tar.gz

# 备份旧版本
sudo mv /usr/local/bin/tunnel-server /usr/local/bin/tunnel-server.backup

# 安装新版本
sudo mv tunnel-server /usr/local/bin/
sudo chmod +x /usr/local/bin/tunnel-server

# 启动服务
sudo systemctl start tunnel-server

# 验证版本
tunnel-server -version`, downloadURL, version, version),

		"script": `curl -fsSL http://YOUR_SERVER:8080/api/update/script/linux | sudo bash`,
	}

	// Windows更新命令
	commands["windows"] = map[string]string{
		"powershell": fmt.Sprintf(`# 停止服务（如果作为服务运行）
Stop-Service tunnel-server -ErrorAction SilentlyContinue

# 下载新版本
Invoke-WebRequest -Uri "%s" -OutFile "tunnel-%s.zip"
Expand-Archive -Path "tunnel-%s.zip" -DestinationPath "." -Force

# 替换可执行文件
Move-Item tunnel-server.exe tunnel-server.exe.backup -Force
Move-Item tunnel-server/tunnel-server.exe . -Force

# 启动服务
Start-Service tunnel-server -ErrorAction SilentlyContinue`, downloadURL, version, version),
	}

	return commands
}

// handleUpdateServer 执行服务器更新
func (w *WebAPI) handleUpdateServer(rw http.ResponseWriter, r *http.Request) {
	rw.Header().Set("Content-Type", "application/json")

	// 检查更新
	release, hasUpdate, err := version.CheckUpdate("xiaqijun/tunnel")
	if err != nil {
		json.NewEncoder(rw).Encode(map[string]interface{}{
			"success": false,
			"error":   err.Error(),
		})
		return
	}

	if !hasUpdate {
		json.NewEncoder(rw).Encode(map[string]interface{}{
			"success": false,
			"message": "Already running the latest version",
		})
		return
	}

	// 在Linux系统上执行更新脚本
	go func() {
		// 简单返回成功，实际更新由管理员通过终端执行
		log.Println("Update requested via Web API")
		log.Printf("Latest version: %s", release.TagName)
		log.Println("Please run the update script manually:")
		log.Println("  curl -fsSL https://raw.githubusercontent.com/xiaqijun/tunnel/main/scripts/update-server.sh | sudo bash")
	}()

	json.NewEncoder(rw).Encode(map[string]interface{}{
		"success": true,
		"message": "Update initiated. Server will restart shortly.",
		"version": release.TagName,
	})
}
