const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = 8080;

// 啟用 CORS - 支援所有來源
app.use(
  cors({
    origin: [
      'http://localhost:8081',
      'http://127.0.0.1:8081',
      'http://localhost:52076',
      'http://127.0.0.1:52076',
    ],
    credentials: true,
  })
);

// 🔧 圖片代理端點
app.get('/api/proxy', async (req, res) => {
  const { url } = req.query;

  if (!url) {
    return res.status(400).json({ error: 'Missing url parameter' });
  }

  console.log(`🖼️ Proxying image: ${url}`);

  try {
    // 使用 axios 獲取圖片
    const response = await axios.get(url, {
      responseType: 'stream',
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
        Accept: 'image/webp,image/apng,image/*,*/*;q=0.8',
      },
      timeout: 30000,
    });

    // 設定正確的 headers
    res.set({
      'Content-Type': response.headers['content-type'] || 'image/jpeg',
      'Content-Length': response.headers['content-length'],
      'Cache-Control': 'public, max-age=3600',
      'Access-Control-Allow-Origin': '*',
    });

    console.log(`✅ Image proxy success: ${response.headers['content-length']} bytes`);

    // 直接 pipe 圖片數據
    response.data.pipe(res);
  } catch (error) {
    console.error(`❌ Image proxy error:`, error.message);
    res.status(500).json({
      error: 'Failed to fetch image',
      details: error.message,
      url: url,
    });
  }
});

// 創建 API 代理中間件
const apiProxy = createProxyMiddleware('/api/v2', {
  target: 'http://dev.uirapuka.com:5120',
  changeOrigin: true,
  logLevel: 'debug',
  onError: (err, req, res) => {
    console.error('API Proxy error:', err);
    res.status(500).json({ error: 'API Proxy error', details: err.message });
  },
});

// 使用 API 代理
app.use('/api/v2', apiProxy);

// 健康檢查端點
app.get('/health', (req, res) => {
  res.json({
    status: 'CORS Proxy server is running',
    target: 'http://dev.uirapuka.com:5120',
    imageProxy: 'http://localhost:8080/api/proxy',
    time: new Date().toISOString(),
  });
});

app.listen(PORT, () => {
  console.log(`🚀 CORS Proxy server running on http://localhost:${PORT}`);
  console.log(`📡 Proxying /api/* to http://dev.uirapuka.com:5120`);
  console.log(`🔧 Update your Flutter app to use: http://localhost:${PORT}`);
  console.log(`🌐 Test URL: http://localhost:${PORT}/api/v2/adm/user/login_check`);
});
