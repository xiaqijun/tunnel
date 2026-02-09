# 构建阶段
FROM golang:1.21-alpine AS builder

# 安装必要的工具
RUN apk add --no-cache git make

# 设置工作目录
WORKDIR /app

# 复制 go mod 文件
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 编译服务器
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-s -w" -o tunnel-server ./cmd/server

# 运行阶段
FROM alpine:latest

# 安装 ca-certificates
RUN apk --no-cache add ca-certificates

WORKDIR /app

# 从构建阶段复制二进制文件
COPY --from=builder /app/tunnel-server .
COPY --from=builder /app/web ./web

# 复制配置文件（如果存在）
COPY config.yaml ./config.yaml

# 暴露端口
EXPOSE 7000 8080

# 运行服务器
CMD ["./tunnel-server", "-config", "config.yaml"]
