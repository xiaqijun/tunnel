package main

import (
	"flag"
	"log"
	"os"
	"os/signal"
	"syscall"
	
	"github.com/tunnel/internal/client"
	"github.com/tunnel/pkg/config"
)

func main() {
	configPath := flag.String("config", "client-config.yaml", "Path to configuration file")
	flag.Parse()
	
	// 加载配置
	cfg, err := config.LoadClientConfig(*configPath)
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}
	
	// 创建客户端
	c := client.NewClient(cfg)
	
	// 启动客户端
	go func() {
		if err := c.Start(); err != nil {
			log.Fatalf("Failed to start client: %v", err)
		}
	}()
	
	// 等待信号
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)
	<-sigChan
	
	log.Println("Shutting down client...")
	c.Stop()
}
