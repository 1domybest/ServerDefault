#!/bin/bash

# 도메인 환경 변수 받기
domains=$DOMAINS

# 도메인 목록을 출력
echo "DOMAINS 환경 변수 값: $DOMAINS"
echo "배열로 변환된 DOMAINS:"
IFS=' ' read -r -a domain_array <<< "$domains"
for domain in "${domain_array[@]}"; do
  echo "  $domain"
done

rsa_key_size=4096

staging=0  # 테스트 모드 설정 (0: 실제 인증서 발급, 1: 테스트 발급)

# 더미 인증서 삭제
for domain in "${domain_array[@]}"; do
  echo "### Deleting dummy certificate for $domain ..."
  rm -Rf /etc/letsencrypt/live/$domain && \
  rm -Rf /etc/letsencrypt/archive/$domain && \
  rm -Rf /etc/letsencrypt/renewal/$domain.conf
  echo
done

# 이메일 인자 설정 (이메일이 없다면 --register-unsafely-without-email 사용)
if [ -z "$EMAIL" ]; then
  email_arg="--register-unsafely-without-email"
else
  email_arg="--email $EMAIL"
fi

# 도메인 인자를 -d 형식으로 변환
domain_args=""
for domain in "${domain_array[@]}"; do
  domain_args="$domain_args -d $domain"
done

# 스테이징 모드를 사용할 경우 --staging 인자 추가
if [ $staging != "0" ]; then
  staging_arg="--staging"
fi

# Let's Encrypt 인증서 요청
echo "### Requesting Let's Encrypt certificate for $domains ..."
certbot certonly --webroot -w /var/www/certbot \
  $staging_arg \
  $email_arg \
  $domain_args \
  --rsa-key-size $rsa_key_size \
  --agree-tos \
  --force-renewal
echo

# Nginx 재시작
echo "### Reloading nginx ..."
#nginx -s reload

# 크론 작업 추가 (매일 오전 3시마다 인증서 갱신을 시도)
(crontab -l 2>/dev/null; echo "0 3 * * * EMAIL=\"$EMAIL\" DOMAINS=\"$DOMAINS\" /bin/bash /scripts/renew_certificates.sh >> /scripts/renew_certificates.log 2>&1") | crontab -
