package protocol

import (
	"encoding/json"
	"testing"
)

// TestMessageEncodeDecode 测试消息编码解码
func TestMessageEncodeDecode(t *testing.T) {
	payload := []byte("Hello, World!")
	msg := &Message{
		Type:    MsgTypeData,
		Payload: payload,
	}
	
	encoded := msg.Encode()
	
	decoded, err := DecodeMessage(encoded)
	if err != nil {
		t.Fatalf("Failed to decode message: %v", err)
	}
	
	if decoded.Type != msg.Type {
		t.Errorf("Expected type %d, got %d", msg.Type, decoded.Type)
	}
	
	if string(decoded.Payload) != string(payload) {
		t.Errorf("Expected payload %s, got %s", payload, decoded.Payload)
	}
}

// TestAuthRequestMarshal 测试认证请求序列化
func TestAuthRequestMarshal(t *testing.T) {
	req := AuthRequest{
		Token:      "test-token",
		ClientName: "test-client",
		Tunnels: []Tunnel{
			{
				Name:       "tunnel1",
				LocalPort:  8080,
				RemotePort: 8000,
			},
		},
	}
	
	data, err := json.Marshal(req)
	if err != nil {
		t.Fatalf("Failed to marshal auth request: %v", err)
	}
	
	var decoded AuthRequest
	if err := json.Unmarshal(data, &decoded); err != nil {
		t.Fatalf("Failed to unmarshal auth request: %v", err)
	}
	
	if decoded.Token != req.Token {
		t.Errorf("Expected token %s, got %s", req.Token, decoded.Token)
	}
	
	if decoded.ClientName != req.ClientName {
		t.Errorf("Expected client name %s, got %s", req.ClientName, decoded.ClientName)
	}
	
	if len(decoded.Tunnels) != len(req.Tunnels) {
		t.Errorf("Expected %d tunnels, got %d", len(req.Tunnels), len(decoded.Tunnels))
	}
}

// BenchmarkMessageEncode 基准测试消息编码
func BenchmarkMessageEncode(b *testing.B) {
	payload := make([]byte, 1024)
	msg := &Message{
		Type:    MsgTypeData,
		Payload: payload,
	}
	
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_ = msg.Encode()
	}
}

// BenchmarkMessageDecode 基准测试消息解码
func BenchmarkMessageDecode(b *testing.B) {
	payload := make([]byte, 1024)
	msg := &Message{
		Type:    MsgTypeData,
		Payload: payload,
	}
	
	encoded := msg.Encode()
	
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		_, _ = DecodeMessage(encoded)
	}
}
