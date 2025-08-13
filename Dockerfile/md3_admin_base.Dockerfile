# 使用官方 Perl 運行環境作為父映像檔
# 使用官方 NGINX 作為基礎 image
FROM nginx:alpine


# 複製完整的 NGINX 主設定檔到正確位置，避免在 conf.d 中出現不允許的頂層指令
COPY Docker/nginx/nginx.conf /etc/nginx/nginx.conf






