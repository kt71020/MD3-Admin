# 使用官方 Perl 運行環境作為父映像檔
# 使用官方 NGINX 作為基礎 image
FROM nginx:alpine

# 刪除預設的 nginx 靜態網站內容
# RUN rm -rf /usr/share/nginx/html/*


# 複製自定義 NGINX 設定檔（專案中的 MD3-Admin/Docker/nginx/nginx.conf）
# COPY Docker/nginx/nginx.conf /etc/nginx/conf.d/default.conf






