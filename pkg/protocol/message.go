package protocol

import "encoding/binary"

// 消息类型
const (
	MsgTypeAuth      = 0x01 // 认证
	MsgTypeAuthResp  = 0x02 // 认证响应
	MsgTypeHeartbeat = 0x03 // 心跳
	MsgTypeNewProxy  = 0x04 // 新建代理
	MsgTypeCloseProxy = 0x05 // 关闭代理
	MsgTypeData      = 0x06 // 数据传输
	MsgTypeError     = 0x07 // 错误
)

// Message 消息结构
type Message struct {
	Type    byte   // 消息类型
	Length  uint32 // 数据长度
	Payload []byte // 数据内容
}

// Encode 编码消息
func (m *Message) Encode() []byte {
	buf := make([]byte, 5+len(m.Payload))
	buf[0] = m.Type
	binary.BigEndian.PutUint32(buf[1:5], uint32(len(m.Payload)))
	copy(buf[5:], m.Payload)
	return buf
}

// DecodeMessage 解码消息
func DecodeMessage(data []byte) (*Message, error) {
	if len(data) < 5 {
		return nil, nil // 需要更多数据
	}
	
	msgType := data[0]
	length := binary.BigEndian.Uint32(data[1:5])
	
	if len(data) < int(5+length) {
		return nil, nil // 需要更多数据
	}
	
	payload := make([]byte, length)
	copy(payload, data[5:5+length])
	
	return &Message{
		Type:    msgType,
		Length:  length,
		Payload: payload,
	}, nil
}

// AuthRequest 认证请求
type AuthRequest struct {
	Token      string   `json:"token"`
	ClientName string   `json:"client_name"`
	Tunnels    []Tunnel `json:"tunnels"`
}

// AuthResponse 认证响应
type AuthResponse struct {
	Success bool   `json:"success"`
	Message string `json:"message"`
	ClientID string `json:"client_id"`
}

// Tunnel 隧道配置
type Tunnel struct {
	Name       string `json:"name"`
	LocalPort  int    `json:"local_port"`
	RemotePort int    `json:"remote_port"`
}

// ProxyRequest 代理请求
type ProxyRequest struct {
	TunnelName string `json:"tunnel_name"`
	ConnID     string `json:"conn_id"`
}

// DataPacket 数据包
type DataPacket struct {
	ConnID string `json:"conn_id"`
	Data   []byte `json:"data"`
}
