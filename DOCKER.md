# Docker 使用指南

## 快速开始

### 1. 使用 Docker Compose (推荐)

最简单的方式是使用 docker-compose:

```bash
# 启动所有服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

服务将在以下端口运行:
- Server: http://localhost:8080 (Web 管理)
- Tunnel: localhost:7000 (客户端连接)
- Demo: http://localhost:8081 (测试页面)

### 2. 单独运行服务器

```bash
# 构建镜像
docker build -t tunnel-server .

# 运行容器
docker run -d \
  --name tunnel-server \
  -p 7000:7000 \
  -p 8080:8080 \
  -p 8000-8010:8000-8010 \
  -v $(pwd)/config.yaml:/app/config.yaml \
  -v $(pwd)/web:/app/web \
  tunnel-server
```

### 3. 单独运行客户端

```bash
# 构建客户端镜像
docker build -f Dockerfile.client -t tunnel-client .

# 运行客户端
docker run -d \
  --name tunnel-client \
  -v $(pwd)/client-config.yaml:/app/client-config.yaml \
  tunnel-client
```

## 配置说明

### 服务器配置

编辑 `config.yaml`:

```yaml
server:
  bind_addr: "0.0.0.0"
  bind_port: 7000
  
web:
  bind_addr: "0.0.0.0"
  bind_port: 8080
```

### 客户端配置

编辑 `client-config.yaml`:

```yaml
server:
  addr: "tunnel-server:7000"  # Docker 网络中使用服务名
  token: "your-secret-token"
  
tunnels:
  - name: "demo-web"
    local_addr: "demo-web"  # Docker 服务名
    local_port: 80
    remote_port: 8000
```

## 生产环境部署

### 使用环境变量

创建 `.env` 文件:

```env
SERVER_PORT=7000
WEB_PORT=8080
AUTH_TOKEN=your-production-token-here
TZ=Asia/Shanghai
```

修改 `docker-compose.yml`:

```yaml
services:
  tunnel-server:
    environment:
      - SERVER_PORT=${SERVER_PORT}
      - WEB_PORT=${WEB_PORT}
      - AUTH_TOKEN=${AUTH_TOKEN}
      - TZ=${TZ}
```

### 持久化数据

添加数据卷:

```yaml
volumes:
  tunnel-data:
    driver: local

services:
  tunnel-server:
    volumes:
      - tunnel-data:/app/data
```

### 使用 Docker Swarm

```bash
# 初始化 Swarm
docker swarm init

# 部署服务栈
docker stack deploy -c docker-compose.yml tunnel

# 查看服务
docker service ls

# 查看日志
docker service logs tunnel_tunnel-server
```

### 使用 Kubernetes

创建 `k8s-deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tunnel-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tunnel-server
  template:
    metadata:
      labels:
        app: tunnel-server
    spec:
      containers:
      - name: tunnel-server
        image: tunnel-server:latest
        ports:
        - containerPort: 7000
        - containerPort: 8080
        volumeMounts:
        - name: config
          mountPath: /app/config.yaml
          subPath: config.yaml
      volumes:
      - name: config
        configMap:
          name: tunnel-config

---
apiVersion: v1
kind: Service
metadata:
  name: tunnel-server
spec:
  type: LoadBalancer
  ports:
  - name: tunnel
    port: 7000
    targetPort: 7000
  - name: web
    port: 8080
    targetPort: 8080
  selector:
    app: tunnel-server
```

部署:

```bash
# 创建 ConfigMap
kubectl create configmap tunnel-config --from-file=config.yaml

# 部署
kubectl apply -f k8s-deployment.yaml

# 查看状态
kubectl get pods
kubectl get services
```

## 监控和日志

### 查看容器日志

```bash
# 实时查看日志
docker logs -f tunnel-server

# 查看最近 100 行
docker logs --tail 100 tunnel-server

# 带时间戳
docker logs -t tunnel-server
```

### 集成 Prometheus

添加监控端点到服务器代码，然后配置 Prometheus:

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'tunnel'
    static_configs:
      - targets: ['tunnel-server:9090']
```

### 集成 Grafana

```yaml
# docker-compose.yml
services:
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
```

## 故障排除

### 容器无法启动

```bash
# 查看详细日志
docker logs tunnel-server

# 检查配置
docker exec tunnel-server cat /app/config.yaml

# 进入容器调试
docker exec -it tunnel-server /bin/sh
```

### 网络问题

```bash
# 查看网络
docker network ls
docker network inspect tunnel-network

# 测试连通性
docker exec tunnel-client ping tunnel-server
```

### 性能问题

```bash
# 查看资源使用
docker stats

# 限制资源
docker run --memory="512m" --cpus="1.0" tunnel-server
```

## 安全建议

1. **不要在镜像中包含敏感信息**
   - 使用环境变量或密钥管理工具
   - 使用 Docker secrets

2. **定期更新基础镜像**
   ```bash
   docker pull alpine:latest
   docker build --no-cache -t tunnel-server .
   ```

3. **使用非 root 用户**
   ```dockerfile
   RUN addgroup -g 1000 tunnel && \
       adduser -D -u 1000 -G tunnel tunnel
   USER tunnel
   ```

4. **限制容器权限**
   ```bash
   docker run --read-only --cap-drop=ALL tunnel-server
   ```

## 备份和恢复

### 备份配置

```bash
# 备份配置文件
docker cp tunnel-server:/app/config.yaml ./backup/

# 备份数据卷
docker run --rm -v tunnel-data:/data -v $(pwd):/backup alpine tar czf /backup/data-backup.tar.gz -C /data .
```

### 恢复配置

```bash
# 恢复数据
docker run --rm -v tunnel-data:/data -v $(pwd):/backup alpine tar xzf /backup/data-backup.tar.gz -C /data
```
