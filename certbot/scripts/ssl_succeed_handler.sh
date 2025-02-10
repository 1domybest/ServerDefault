#!/bin/bash

DOMAIN=$DOMAIN
CERT_PATH=".certbot/config/etc/letsencrypt/live/$DOMAIN/fullchain.pem"
KEY_PATH="./certbot/config/etc/letsencrypt/live/$DOMAIN/privkey.pem"
SSL_CONFIG_PATH="../..//nginx/sites-available/$DOMAIN/ssl_$DOMAIN.conf"

cat <<EOF > $SSL_CONFIG_PATH
server {
   listen 443 ssl;
   listen [::]:443 ssl;
   server_name $DOMAIN;

   ssl_certificate /etc/letsencrypt/live/$DOMAIN/fullchain.pem;
   ssl_certificate_key /etc/letsencrypt/live/$DOMAIN/privkey.pem;

   ssl_protocols TLSv1.2 TLSv1.3;
   ssl_ciphers HIGH:!aNULL:!MD5;

   access_log  /var/log/nginx/$DOMAIN.access.log;
   error_log   /var/log/nginx/$DOMAIN.error.log;

   #    # HTTPS 요청은 로컬 서버로만 전달
   location / {
      proxy_pass http://localhost:81;  # React 앱 또는 프론트엔드 서버로 전달
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto \$scheme;
   }
}
EOF
