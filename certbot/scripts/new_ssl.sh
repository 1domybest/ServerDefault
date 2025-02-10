#!/bin/bash
# 도메인 환경 변수 받기
echo "$domain 갱신 시작중 ============================"

domain=$DOMAIN
email=$EMAIL

# 인증서가 이미 존재하는지 확인
if docker exec -it certbot [ -d /etc/letsencrypt/live/$domain ]; then
    echo "인증서가 이미 존재합니다. 갱신 중..."
    # 인증서 갱신
    docker exec -it certbot certbot renew --quiet --agree-tos --no-eff-email --email $email
else
    echo "인증서가 존재하지 않으므로 새로 발급합니다."
    # 기존 인증서 삭제
    docker exec -it certbot rm -rf /etc/letsencrypt/live/$domain
    docker exec -it certbot rm -rf /etc/letsencrypt/archive/$domain
    docker exec -it certbot rm -rf /etc/letsencrypt/renewal/$domain.conf

    # 인증서 새로 발급
    docker exec -it certbot certbot certonly --webroot --webroot-path=/var/www/certbot -d $domain --email $email --agree-tos --no-eff-email
fi

# 인증서 발급 또는 갱신 결과 확인
if [ $? -eq 0 ]; then
    echo "인증서 발급/갱신 성공: $domain"

    DOMAIN=$domain ./ssl_succeed_handler.sh

    # nginx에 인증서 파일 복사
    docker cp certbot:/etc/letsencrypt ./config/etc/letsencrypt
    # nginx 재시작
    docker exec -it main_nginx nginx -s reload

else
    echo "인증서 발급/갱신 실패: $domain"
    # 실패 시 실행할 작업 (예: 오류 알림, 재시도 등)
    DOMAIN=$domain ./ssl_failed_handler.sh

    # nginx 재시작
    docker exec -it main_nginx nginx -s reload
fi
