#!/bin/bash

# Cloudflare 계정 정보
ZONE_ID="9a16c4c9526f6248514bd2a2e4ab0a62"    # Cloudflare에서 확인 가능
API_KEY="gW4co6h3zmrPQ2ttDi9D5x9cxw1E1fsI4dnhfe38"    # Cloudflare에서 발급한 API 키
EMAIL="dhstjrxo123@gmail.com"               # Cloudflare 계정 이메일
DOMAIN_NAME="seoktae.online"         # 사용할 도메인

# 현재 공인 IP 가져오기
CURRENT_IP=$(curl -s http://checkip.amazonaws.com)

# Cloudflare에서 현재 설정된 IP 확인
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$DOMAIN_NAME" \
    -H "X-Auth-Email: $EMAIL" \
    -H "X-Auth-Key: $API_KEY" \
    -H "Content-Type: application/json" | jq -r '.result[0].id')

CF_IP=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
    -H "X-Auth-Email: $EMAIL" \
    -H "X-Auth-Key: $API_KEY" \
    -H "Content-Type: application/json" | jq -r '.result.content')

# IP 변경 감지 후 업데이트
if [ "$CURRENT_IP" != "$CF_IP" ]; then
    curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        -H "X-Auth-Email: $EMAIL" \
        -H "X-Auth-Key: $API_KEY" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$DOMAIN_NAME\",\"content\":\"$CURRENT_IP\",\"ttl\":1,\"proxied\":false}"
    echo "Cloudflare DNS 레코드 업데이트 완료: $CURRENT_IP"
else
    echo "IP 변경 없음. 업데이트 필요 없음."
fi
