package main

import (
	"flag"
	"log"
	"os"
	"os/signal"
	"syscall"
	
	"github.com/tunnel/internal/server"
	"github.com/tunnel/pkg/config"
)

func main() {
	configPath := flag.String("config", "config.yaml", "Path to configuration file")
	flag.Parse()
	
	// 加载配置
	cfg, err := config.LoadServerConfig(*configPath)
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}
	
	// 创建服务器配置
	serverConfig := &server.ServerConfig{
		BindAddr:        cfg.Server.BindAddr,
		BindPort:        cfg.Server.BindPort,
		Token:           cfg.Auth.Token,
		MaxConnections:  cfg.Performance.MaxConnections,
		ReadBufferSize:  cfg.Performance.ReadBufferSize,
		WriteBufferSize: cfg.Performance.WriteBufferSize,
		WorkerPoolSize:  cfg.Performance.WorkerPoolSize,
	}
	
	// 创建服务器
	srv := server.NewServer(serverConfig)
	
	// 创建Web API
	webAPI := server.NewWebAPI(srv)
	
	// 启动Web服务
	go func() {
		if err := webAPI.Start(cfg.Web.BindAddr, cfg.Web.BindPort); err != nil {
			log.Fatalf("Failed to start web API: %v", err)
		}
	}()
	
	// 启动隧道服务器
	go func() {
		if err := srv.Start(); err != nil {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()
	
	// 等待信号
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	<-sigChan
	
	log.Println("Shutting down server...")
}
