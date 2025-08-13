# Use official Nginx as base image for production serving
FROM nginx:alpine


# 添加一个不缓存的标记
ARG CACHEBUST=1

# 移除官方預設站台設定，確保只使用我們的主設定檔
RUN rm -f /etc/nginx/conf.d/default.conf || true \
    && rm -rf /usr/share/nginx/html/*

# 覆蓋 Nginx 主設定檔（包含 COOP/COEP 與 wasm MIME、/canvaskit/ 設定）
COPY Docker/nginx/nginx.conf /etc/nginx/nginx.conf

# 複製 Flutter Web build 後的檔案到 nginx 的根目錄
COPY build/web /usr/share/nginx/html

# 複製自託管的 CanvasKit 檔案到同網域路徑
COPY web/canvaskit /usr/share/nginx/html/canvaskit


# 開放 Web 預設 port
EXPOSE 80

# 啟動 nginx
CMD ["nginx", "-g", "daemon off;"]

