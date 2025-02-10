#!/bin/bash

chmod -R +x /usr/local/bin

# 환경 변수로 DOMAINS를 사용하여 배열 정의 [컴포스에서 정의한 변수]
IFS=' ' read -r -a domains <<< "$DOMAINS"  # 띄어쓰기로 구분하여 배열로 변환

# 배열을 반복하면서 심볼릭 링크 생성
for domain in "${domains[@]}"; do
  ln -s /etc/nginx/sites-available/$domain/$domain.conf /etc/nginx/sites-enabled/$domain.conf
done

# Nginx를 포그라운드 모드로 실행 [로그를 위해]
nginx -g 'daemon off;'
