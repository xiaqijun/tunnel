# API 文档

## 概述

Tunnel 服务器提供 RESTful API 和 WebSocket 接口用于管理和监控。

基础 URL: `http://your-server:8080/api`

## 认证

当前版本不需要 API 认证。建议在生产环境中添加认证机制。

## 端点

### 1. 获取所有客户端

**请求**

```
GET /api/clients
```

**响应**

```json
{
  "success": true,
  "data": [
    {
      "id": "1706861234567890123",
      "name": "client-1",
      "connected": true,
      "last_seen": "2026-02-05T10:30:45Z",
      "tunnels": [
        {
          "name": "web-service",
          "local_port": 8080,
          "remote_port": 8000,
          "active": true
        }
      ],
      "bytes_sent": 1048576,
      "bytes_received": 524288,
      "connection_count": 42
    }
  ]
}
```

### 2. 获取单个客户端

**请求**

```
GET /api/clients/{client_id}
```

**参数**

- `client_id`: 客户端 ID

**响应**

```json
{
  "success": true,
  "data": {
    "id": "1706861234567890123",
    "name": "client-1",
    "connected": true,
    "last_seen": "2026-02-05T10:30:45Z",
    "tunnels": [
      {
        "name": "web-service",
        "local_port": 8080,
        "remote_port": 8000,
        "active": true
      }
    ],
    "bytes_sent": 1048576,
    "bytes_received": 524288,
    "connection_count": 42
  }
}
```

**错误响应**

```json
{
  "success": false,
  "message": "Client not found"
}
```

### 3. 获取统计信息

**请求**

```
GET /api/stats
```

**响应**

```json
{
  "success": true,
  "data": {
    "total_clients": 3,
    "active_connections": 127,
    "total_bytes_sent": 10485760,
    "total_bytes_received": 5242880,
    "total_connections": 1543
  }
}
```

### 4. WebSocket 实时更新

**连接**

```
WS /api/ws
```

**消息格式**

服务器每 2 秒推送一次客户端列表更新：

```json
[
  {
    "id": "1706861234567890123",
    "name": "client-1",
    "connected": true,
    "last_seen": "2026-02-05T10:30:45Z",
    "tunnels": [...],
    "bytes_sent": 1048576,
    "bytes_received": 524288,
    "connection_count": 42
  }
]
```

## 数据模型

### ClientInfo

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 客户端唯一标识 |
| name | string | 客户端名称 |
| connected | boolean | 连接状态 |
| last_seen | timestamp | 最后活动时间 |
| tunnels | array | 隧道列表 |
| bytes_sent | integer | 发送字节数 |
| bytes_received | integer | 接收字节数 |
| connection_count | integer | 总连接数 |

### TunnelInfo

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 隧道名称 |
| local_port | integer | 本地端口 |
| remote_port | integer | 远程端口 |
| active | boolean | 活动状态 |

### Stats

| 字段 | 类型 | 说明 |
|------|------|------|
| total_clients | integer | 客户端总数 |
| active_connections | integer | 活动连接数 |
| total_bytes_sent | integer | 总发送字节 |
| total_bytes_received | integer | 总接收字节 |
| total_connections | integer | 历史连接总数 |

## 使用示例

### cURL

```bash
# 获取所有客户端
curl http://localhost:8080/api/clients

# 获取特定客户端
curl http://localhost:8080/api/clients/1706861234567890123

# 获取统计信息
curl http://localhost:8080/api/stats
```

### JavaScript (Fetch)

```javascript
// 获取客户端列表
fetch('http://localhost:8080/api/clients')
  .then(response => response.json())
  .then(data => {
    console.log('Clients:', data.data);
  });

// WebSocket 连接
const ws = new WebSocket('ws://localhost:8080/api/ws');
ws.onmessage = (event) => {
  const clients = JSON.parse(event.data);
  console.log('Updated clients:', clients);
};
```

### Python

```python
import requests
import json

# 获取客户端列表
response = requests.get('http://localhost:8080/api/clients')
clients = response.json()['data']
print(f"Total clients: {len(clients)}")

# 获取统计信息
response = requests.get('http://localhost:8080/api/stats')
stats = response.json()['data']
print(f"Active connections: {stats['active_connections']}")
```

### Go

```go
package main

import (
    "encoding/json"
    "fmt"
    "net/http"
)

type Response struct {
    Success bool        `json:"success"`
    Data    interface{} `json:"data"`
}

func main() {
    resp, err := http.Get("http://localhost:8080/api/stats")
    if err != nil {
        panic(err)
    }
    defer resp.Body.Close()
    
    var result Response
    json.NewDecoder(resp.Body).Decode(&result)
    
    fmt.Printf("Stats: %+v\n", result.Data)
}
```

## 错误代码

| 状态码 | 说明 |
|--------|------|
| 200 | 成功 |
| 404 | 资源未找到 |
| 500 | 服务器内部错误 |

## 限制

- WebSocket 连接会每 2 秒推送一次更新
- API 无速率限制（建议在生产环境中添加）
- 所有时间戳使用 RFC3339 格式

## 未来计划

- [ ] 添加 API 认证（JWT/Token）
- [ ] 添加速率限制
- [ ] 支持客户端踢出功能
- [ ] 支持动态添加/删除隧道
- [ ] 提供更详细的流量统计
- [ ] 支持按时间范围查询统计数据
