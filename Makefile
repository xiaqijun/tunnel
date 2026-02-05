.PHONY: all build server client clean test deps run-server run-client

# 默认目标
all: build

# 安装依赖
deps:
	go mod download
	go mod tidy

# 编译所有
build: server client

# 编译服务器
server:
	@echo "Building server..."
	go build -ldflags="-s -w" -o bin/tunnel-server.exe ./cmd/server

# 编译客户端
client:
	@echo "Building client..."
	go build -ldflags="-s -w" -o bin/tunnel-client.exe ./cmd/client

# 运行服务器
run-server:
	go run ./cmd/server -config config.yaml

# 运行客户端
run-client:
	go run ./cmd/client -config client-config.yaml

# 测试
test:
	go test -v ./...

# 清理
clean:
	@echo "Cleaning..."
	@if exist bin rmdir /s /q bin
	@if exist *.exe del /q *.exe

# 格式化代码
fmt:
	go fmt ./...

# 代码检查
vet:
	go vet ./...

# 生成文档
doc:
	godoc -http=:6060
