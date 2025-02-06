#!/bin/bash


# 환경 변수로 DOMAINS와 EMAIL을 받아서 사용
IFS=' ' read -r -a domains <<< "$DOMAINS"  # 띄어쓰기로 구분하여 배열로 변환

rsa_key_size=4096
staging=0  # Set to 1 if you're testing your setup to avoid hitting request limits

# 도메인 배열을 -d 인자 형태로 변환
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# 이메일 처리
case "$EMAIL" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $EMAIL" ;;
esac

# 스테이징 모드를 사용할 경우 --staging 인자 추가
if [ $staging != "0" ]; then staging_arg="--staging"; fi

# 인증서 갱신
echo "### Renewing Let's Encrypt certificate for $domains ..."
certbot renew --webroot -w /var/www/certbot \
  $staging_arg \
  $email_arg \
  $domain_args
echo

# Nginx 재시작
echo "### Reloading nginx ..."
#nginx -s reload