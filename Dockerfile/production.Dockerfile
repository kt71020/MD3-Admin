# Use an official Perl runtime as a parent image
FROM kt71020/md3-admin-base:latest_version


# 添加一个不缓存的标记
ARG CACHEBUST=1


# 複製 Flutter Web build 後的檔案到 nginx 的根目錄
# COPY build/web /usr/share/nginx/html


# 開放 Web 預設 port
EXPOSE 80

# 啟動 nginx
CMD ["nginx", "-g", "daemon off;"]

