#!/bin/bash

# 환경 변수로 DOMAINS를 사용하여 배열 정의
IFS=' ' read -r -a domains <<< "$DOMAINS"  # 띄어쓰기로 구분하여 배열로 변환

rsa_key_size=4096
data_path="./data/certbot"
staging=0  # Set to 1 if you're testing your setup to avoid hitting request limits

# 도메인 배열을 반복하면서 심볼릭 링크 삭제
for domain in "${domains[@]}"; do
  echo "### Deleting dummy certificate for $domain ..."
  docker-compose run --rm --entrypoint "\
    rm -Rf /etc/letsencrypt/live/$domain && \
    rm -Rf /etc/letsencrypt/archive/$domain && \
    rm -Rf /etc/letsencrypt/renewal/$domain.conf" certbot
  echo
done

# 이메일이 설정되어 있지 않으면 --register-unsafely-without-email 사용
case "$EMAIL" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $EMAIL" ;;
esac

# 도메인 배열을 -d 인자 형태로 변환
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# 스테이징 모드를 사용할 경우 --staging 인자 추가
if [ $staging != "0" ]; then staging_arg="--staging"; fi

# Let's Encrypt 인증서 요청
echo "### Requesting Let's Encrypt certificate for $domains ..."
docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
echo

# Nginx 재시작
echo "### Reloading nginx ..."
docker-compose exec nginx nginx -s reload

# 크론 작업을 추가 (매일 오전 3시마다 인증서 갱신을 시도)
(crontab -l 2>/dev/null; echo "0 3 * * * EMAIL=\"$EMAIL\" DOMAINS=\"$DOMAINS\" /bin/bash /usr/local/bin/renew_certificates.sh >> /usr/local/bin/renew_certificates.log 2>&1") | crontab -