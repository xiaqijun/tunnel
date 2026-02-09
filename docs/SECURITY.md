# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please follow these steps:

### 1. DO NOT create a public GitHub issue

Security vulnerabilities should be reported privately to protect users.

### 2. Report via Email

Send an email to: **security@yourproject.com** (replace with your actual email)

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### 3. Wait for Response

We will respond within **48 hours** to acknowledge receipt.

We aim to:
- Validate the issue within 7 days
- Provide a fix within 30 days (depending on severity)
- Credit you in the release notes (if you wish)

### 4. Coordinated Disclosure

Please allow us time to fix the issue before public disclosure.

We will:
1. Develop and test a fix
2. Release a security patch
3. Publish a security advisory
4. Credit the reporter (with permission)

## Security Best Practices

When deploying Tunnel:

### 1. Use Strong Tokens

```yaml
auth:
  token: "use-a-long-random-token-here"  # At least 32 characters
```

Generate a secure token:
```bash
# Linux/Mac
openssl rand -hex 32

# Windows (PowerShell)
[Convert]::ToBase64String((1..32|%{Get-Random -Max 256}))
```

### 2. Enable TLS (Coming Soon)

Currently, Tunnel does not encrypt traffic. Deploy behind a reverse proxy with TLS:

```nginx
server {
    listen 443 ssl;
    server_name tunnel.example.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 3. Firewall Configuration

Only expose necessary ports:

```bash
# Allow only specific IPs to connect
iptables -A INPUT -p tcp --dport 7000 -s 1.2.3.4 -j ACCEPT
iptables -A INPUT -p tcp --dport 7000 -j DROP

# Allow web interface only from specific network
iptables -A INPUT -p tcp --dport 8080 -s 192.168.1.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j DROP
```

### 4. Run with Limited Permissions

Don't run as root:

```bash
# Create dedicated user
useradd -r -s /bin/false tunnel

# Run as that user
sudo -u tunnel ./tunnel-server -config config.yaml
```

### 5. Keep Updated

Always use the latest version:

```bash
# Check for updates
git pull origin main
make build
```

### 6. Monitor Logs

Regularly review logs for suspicious activity:

```bash
# Check for failed authentication attempts
grep "authentication failed" /var/log/tunnel.log

# Monitor unusual traffic patterns
grep "bytes_sent\|bytes_received" /var/log/tunnel.log
```

### 7. Rate Limiting

Configure rate limiting in your reverse proxy:

```nginx
limit_req_zone $binary_remote_addr zone=tunnel:10m rate=10r/s;

server {
    location / {
        limit_req zone=tunnel burst=20;
        proxy_pass http://localhost:8080;
    }
}
```

## Known Security Considerations

### Current Limitations

1. **No Built-in Encryption** - Traffic is not encrypted by default
   - **Mitigation**: Use TLS reverse proxy

2. **Simple Token Authentication** - Single shared token
   - **Mitigation**: Use strong, unique tokens per deployment

3. **No API Rate Limiting** - API endpoints have no rate limits
   - **Mitigation**: Use reverse proxy rate limiting

4. **No Request Validation** - Limited input validation
   - **Mitigation**: Deploy behind WAF

## Planned Security Enhancements

### v1.1.0
- [ ] TLS/SSL support
- [ ] Per-client tokens
- [ ] API rate limiting
- [ ] Request validation

### v1.2.0
- [ ] JWT authentication
- [ ] Role-based access control
- [ ] Audit logging
- [ ] IP whitelisting

## Vulnerability Disclosure Timeline

1. **Day 0**: Receive report
2. **Day 1-2**: Acknowledge receipt
3. **Day 3-7**: Validate and assess severity
4. **Day 8-30**: Develop and test fix
5. **Day 31**: Release patch
6. **Day 32**: Publish advisory
7. **Day 45**: Full public disclosure

## Security Advisories

Security advisories will be published at:
- GitHub Security Advisories
- Project README
- Release notes

## Bug Bounty

Currently, we do not have a bug bounty program.

## Contact

For security concerns: **security@yourproject.com**

For general questions: Use GitHub Issues

---

Thank you for helping keep Tunnel and its users safe! 🔒
