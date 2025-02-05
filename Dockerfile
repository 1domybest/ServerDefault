# 서버설정
# 서버의 메인 엔진 실행
FROM nginx:latest

# 폴더가 없다면 생성
RUN mkdir -p /etc/nginx/sites-enabled /etc/nginx/sites-available

CMD ["nginx", "-g", "daemon off;"]



#1. nginx  80, 433 포트생성
#2. 인증서 발급을 위한 433 default.conf 변경
#3. 인증서 발급 및 크론으로 재발급 등록
#4. 기존 도메인별로 작업한 것들을 compose volume을통해 이동시키고 nginx 재시동