#!/bin/bash

# 도메인 배열 정의
domains=("seoktae.duckdns.org")
#domains=("example1.com" "example2.com" "example3.com")

# 배열을 반복하면서 심볼릭 링크 생성
for domain in "${domains[@]}"; do
  ln -s /etc/nginx/sites-available/$domain/$domain.conf /etc/nginx/sites-enabled/$domain.conf
done

# Nginx를 포그라운드 모드로 실행
nginx -g 'daemon off;'
