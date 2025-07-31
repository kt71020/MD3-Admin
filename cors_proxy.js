const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');

const app = express();
const PORT = 8080;

// 啟用 CORS
app.use(
  cors({
    origin: ['http://localhost:52076', 'http://127.0.0.1:52076'],
    credentials: true,
  })
);

// 創建代理中間件
const apiProxy = createProxyMiddleware('/api', {
  target: 'http://dev.uirapuka.com:5120',
  changeOrigin: true,
  logLevel: 'debug',
  onError: (err, req, res) => {
    console.error('Proxy error:', err);
    res.status(500).json({ error: 'Proxy error', details: err.message });
  },
});

// 使用代理
app.use('/api', apiProxy);

// 健康檢查端點
app.get('/health', (req, res) => {
  res.json({ status: 'Proxy server is running', target: 'http://dev.uirapuka.com:5120' });
});

app.listen(PORT, () => {
  console.log(`🚀 CORS Proxy server running on http://localhost:${PORT}`);
  console.log(`📡 Proxying /api/* to http://dev.uirapuka.com:5120`);
  console.log(`🔧 Update your Flutter app to use: http://localhost:${PORT}`);
  console.log(`🌐 Test URL: http://localhost:${PORT}/api/v2/adm/user/login_check`);
});
