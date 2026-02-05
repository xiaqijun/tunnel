package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	
	"github.com/tunnel/internal/client"
	"github.com/tunnel/pkg/config"
	"github.com/tunnel/pkg/version"
)

func main() {
	configPath := flag.String("config", "client-config.yaml", "Path to configuration file")
	showVersion := flag.Bool("version", false, "Show version information")
	flag.Parse()
	
	// 显示版本信息
	if *showVersion {
		v := version.Get()
		fmt.Println(v.String())
		if v.BuildDate != "" {
			fmt.Printf("Build Date: %s\n", v.BuildDate)
		}
		if v.GitCommit != "" {
			fmt.Printf("Git Commit: %s\n", v.GitCommit)
		}
		fmt.Printf("Go Version: %s\n", v.GoVersion)
		return
	}
	
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
