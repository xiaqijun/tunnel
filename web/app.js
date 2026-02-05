// WebSocket连接
let ws = null;
let reconnectInterval = null;

// 初始化
document.addEventListener('DOMContentLoaded', () => {
    connectWebSocket();
    loadStats();
    loadInstallCommands();
    initInstallTabs();
    loadServerVersion();
    // 每5秒刷新统计信息
    setInterval(loadStats, 5000);
    // 每30分钟检查一次更新
    setInterval(checkServerUpdate, 30 * 60 * 1000);
});

// 连接WebSocket
function connectWebSocket() {
    const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsUrl = `${protocol}//${window.location.host}/api/ws`;
    
    ws = new WebSocket(wsUrl);
    
    ws.onopen = () => {
        console.log('WebSocket connected');
        updateStatus(true);
        if (reconnectInterval) {
            clearInterval(reconnectInterval);
            reconnectInterval = null;
        }
    };
    
    ws.onmessage = (event) => {
        try {
            const clients = JSON.parse(event.data);
            updateClients(clients);
        } catch (e) {
            console.error('Failed to parse WebSocket message:', e);
        }
    };
    
    ws.onerror = (error) => {
        console.error('WebSocket error:', error);
        updateStatus(false);
    };
    
    ws.onclose = () => {
        console.log('WebSocket disconnected');
        updateStatus(false);
        // 尝试重连
        if (!reconnectInterval) {
            reconnectInterval = setInterval(() => {
                console.log('Attempting to reconnect...');
                connectWebSocket();
            }, 5000);
        }
    };
}

// 更新连接状态
function updateStatus(connected) {
    const statusDot = document.getElementById('statusDot');
    const statusText = document.getElementById('statusText');
    
    if (connected) {
        statusDot.classList.add('connected');
        statusText.textContent = '已连接';
    } else {
        statusDot.classList.remove('connected');
        statusText.textContent = '未连接';
    }
}

// 加载统计信息
async function loadStats() {
    try {
        const response = await fetch('/api/stats');
        const data = await response.json();
        
        if (data.success) {
            const stats = data.data;
            document.getElementById('totalClients').textContent = stats.total_clients || 0;
            document.getElementById('activeConnections').textContent = stats.active_connections || 0;
            document.getElementById('bytesSent').textContent = formatBytes(stats.total_bytes_sent || 0);
            document.getElementById('bytesReceived').textContent = formatBytes(stats.total_bytes_received || 0);
        }
    } catch (e) {
        console.error('Failed to load stats:', e);
    }
}

// 更新客户端列表
function updateClients(clients) {
    const container = document.getElementById('clientsContainer');
    const noClients = document.getElementById('noClients');
    
    if (!clients || clients.length === 0) {
        container.innerHTML = '';
        noClients.classList.add('show');
        return;
    }
    
    noClients.classList.remove('show');
    
    container.innerHTML = clients.map(client => `
        <div class="client-card">
            <div class="client-header">
                <div>
                    <div class="client-name">${escapeHtml(client.name)}</div>
                    <div class="client-id">ID: ${escapeHtml(client.id)}</div>
                </div>
                <div class="client-status">
                    <span class="client-status-dot"></span>
                    <span>在线</span>
                </div>
            </div>
            
            <div class="client-stats">
                <div class="client-stat">
                    <div class="client-stat-label">发送流量</div>
                    <div class="client-stat-value">${formatBytes(client.bytes_sent)}</div>
                </div>
                <div class="client-stat">
                    <div class="client-stat-label">接收流量</div>
                    <div class="client-stat-value">${formatBytes(client.bytes_received)}</div>
                </div>
                <div class="client-stat">
                    <div class="client-stat-label">连接数</div>
                    <div class="client-stat-value">${client.connection_count}</div>
                </div>
                <div class="client-stat">
                    <div class="client-stat-label">最后活动</div>
                    <div class="client-stat-value">${formatTime(client.last_seen)}</div>
                </div>
            </div>
            
            ${client.tunnels && client.tunnels.length > 0 ? `
                <div class="tunnels-section">
                    <div class="tunnels-title">隧道列表 (${client.tunnels.length})</div>
                    <div class="tunnel-list">
                        ${client.tunnels.map(tunnel => `
                            <div class="tunnel-item">
                                <div>
                                    <div class="tunnel-name">${escapeHtml(tunnel.name)}</div>
                                    <div class="tunnel-ports">远程端口: ${tunnel.remote_port} → 本地端口: ${tunnel.local_port}</div>
                                </div>
                                <span class="tunnel-badge">${tunnel.active ? '活动' : '未活动'}</span>
                            </div>
                        `).join('')}
                    </div>
                </div>
            ` : ''}
        </div>
    `).join('');
}

// 格式化字节
function formatBytes(bytes) {
    if (bytes === 0) return '0 B';
    
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// 格式化时间
function formatTime(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = Math.floor((now - date) / 1000); // 秒
    
    if (diff < 60) return `${diff}秒前`;
    if (diff < 3600) return `${Math.floor(diff / 60)}分钟前`;
    if (diff < 86400) return `${Math.floor(diff / 3600)}小时前`;
    return `${Math.floor(diff / 86400)}天前`;
}

// HTML转义
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return String(text).replace(/[&<>"']/g, m => map[m]);
}

// 加载安装命令
async function loadInstallCommands() {
    try {
        const response = await fetch('/api/install');
        const data = await response.json();
        
        if (data.success) {
            const commands = data.data;
            
            // Windows
            if (commands.windows) {
                document.getElementById('cmd-windows-powershell').textContent = commands.windows.powershell || '';
                document.getElementById('cmd-windows-cmd').textContent = commands.windows.cmd || '';
            }
            
            // Linux
            if (commands.linux) {
                document.getElementById('cmd-linux-bash').textContent = commands.linux.bash || '';
                document.getElementById('cmd-linux-wget').textContent = commands.linux.wget || '';
            }
            
            // macOS
            if (commands.darwin) {
                document.getElementById('cmd-darwin-bash').textContent = commands.darwin.bash || '';
            }
        }
    } catch (e) {
        console.error('Failed to load install commands:', e);
    }
}

// 初始化安装标签
function initInstallTabs() {
    const tabs = document.querySelectorAll('.install-tab');
    const panels = document.querySelectorAll('.install-panel');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            const os = tab.getAttribute('data-os');
            
            // 更新标签状态
            tabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            
            // 更新面板显示
            panels.forEach(panel => {
                if (panel.getAttribute('data-panel') === os) {
                    panel.classList.add('active');
                } else {
                    panel.classList.remove('active');
                }
            });
        });
    });
}

// 复制命令
function copyCommand(elementId) {
    const element = document.getElementById(elementId);
    const text = element.textContent;
    
    navigator.clipboard.writeText(text).then(() => {
        // 显示复制成功提示
        const btn = element.nextElementSibling;
        const originalText = btn.textContent;
        btn.textContent = '✅ 已复制';
        btn.style.background = '#10b981';
        
        setTimeout(() => {
            btn.textContent = originalText;
            btn.style.background = '';
        }, 2000);
    }).catch(err => {
        console.error('Failed to copy:', err);
        alert('复制失败，请手动复制');
    });
}

// 加载服务器版本
async function loadServerVersion() {
    try {
        const response = await fetch('/api/version');
        const data = await response.json();
        
        if (data.success && data.data) {
            const version = data.data.version || '0.0.0';
            document.getElementById('serverVersion').textContent = 'v' + version;
        }
    } catch (e) {
        console.error('Failed to load server version:', e);
    }
}

// 检查服务器更新
async function checkServerUpdate() {
    const btn = document.getElementById('checkUpdateBtn');
    const icon = document.getElementById('updateIcon');
    
    try {
        btn.disabled = true;
        icon.textContent = '⏳';
        
        const response = await fetch('/api/update/check');
        const data = await response.json();
        
        if (data.success) {
            if (data.has_update) {
                // 有更新可用
                btn.classList.add('has-update');
                icon.textContent = '🎉';
                showUpdateAlert(data.latest_version, data.release_notes);
            } else {
                // 已是最新版本
                icon.textContent = '✅';
                setTimeout(() => {
                    icon.textContent = '🔄';
                    btn.disabled = false;
                }, 2000);
            }
        } else {
            throw new Error(data.message || '检查更新失败');
        }
    } catch (e) {
        console.error('Failed to check update:', e);
        icon.textContent = '❌';
        setTimeout(() => {
            icon.textContent = '🔄';
            btn.disabled = false;
        }, 2000);
        alert('检查更新失败: ' + e.message);
    }
}

// 显示更新提示
function showUpdateAlert(version, notes) {
    const alert = document.getElementById('updateAlert');
    const message = document.getElementById('updateMessage');
    
    message.textContent = `发现新版本 ${version}！`;
    alert.style.display = 'block';
}

// 关闭更新提示
function closeUpdateAlert() {
    const alert = document.getElementById('updateAlert');
    alert.style.display = 'none';
}

// 立即更新服务器
async function updateServerNow() {
    if (!confirm('确定要更新服务器吗？\n更新过程中服务器会短暂重启。')) {
        return;
    }
    
    const btn = document.getElementById('updateNowBtn');
    const originalText = btn.textContent;
    
    try {
        btn.disabled = true;
        btn.textContent = '更新中...';
        
        const response = await fetch('/api/update/server', {
            method: 'POST'
        });
        
        const data = await response.json();
        
        if (data.success) {
            alert('更新成功！服务器将在数秒后重启。\n请稍后刷新页面。');
            closeUpdateAlert();
            
            // 5秒后刷新页面
            setTimeout(() => {
                window.location.reload();
            }, 5000);
        } else {
            throw new Error(data.message || '更新失败');
        }
    } catch (e) {
        console.error('Failed to update server:', e);
        alert('更新失败: ' + e.message);
        btn.textContent = originalText;
        btn.disabled = false;
    }
}
