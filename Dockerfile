# 서버설정
# 베이스 이미지 선택 (필요에 따라 변경 가능)
FROM nginx:latest

RUN mkdir -p /etc/nginx/sites-enabled /etc/nginx/sites-available

CMD ["nginx", "-g", "daemon off;"]