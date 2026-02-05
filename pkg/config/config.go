package config

import (
	"os"
	"gopkg.in/yaml.v3"
)

// ServerConfig 服务器配置
type ServerConfig struct {
	Server struct {
		BindAddr string `yaml:"bind_addr"`
		BindPort int    `yaml:"bind_port"`
	} `yaml:"server"`
	
	Web struct {
		BindAddr string `yaml:"bind_addr"`
		BindPort int    `yaml:"bind_port"`
	} `yaml:"web"`
	
	Auth struct {
		Token string `yaml:"token"`
	} `yaml:"auth"`
	
	Performance struct {
		MaxConnections  int `yaml:"max_connections"`
		PoolSize        int `yaml:"pool_size"`
		ReadBufferSize  int `yaml:"read_buffer_size"`
		WriteBufferSize int `yaml:"write_buffer_size"`
		WorkerPoolSize  int `yaml:"worker_pool_size"`
	} `yaml:"performance"`
}

// ClientConfig 客户端配置
type ClientConfig struct {
	Server struct {
		Addr  string `yaml:"addr"`
		Token string `yaml:"token"`
	} `yaml:"server"`
	
	Client struct {
		Name              string `yaml:"name"`
		ReconnectInterval int    `yaml:"reconnect_interval"`
		HeartbeatInterval int    `yaml:"heartbeat_interval"`
	} `yaml:"client"`
	
	Tunnels []TunnelConfig `yaml:"tunnels"`
}

// TunnelConfig 隧道配置
type TunnelConfig struct {
	Name       string `yaml:"name"`
	LocalAddr  string `yaml:"local_addr"`
	LocalPort  int    `yaml:"local_port"`
	RemotePort int    `yaml:"remote_port"`
}

// LoadServerConfig 加载服务器配置
func LoadServerConfig(path string) (*ServerConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	
	var config ServerConfig
	if err := yaml.Unmarshal(data, &config); err != nil {
		return nil, err
	}
	
	return &config, nil
}

// LoadClientConfig 加载客户端配置
func LoadClientConfig(path string) (*ClientConfig, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	
	var config ClientConfig
	if err := yaml.Unmarshal(data, &config); err != nil {
		return nil, err
	}
	
	return &config, nil
}
