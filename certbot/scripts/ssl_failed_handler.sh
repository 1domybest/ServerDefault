#!/bin/bash

DOMAIN=$DOMAIN
SSL_CONFIG_PATH="./nginx/sites-available/$DOMAIN/ssl_$DOMAIN.conf"

> $SSL_CONFIG_PATH
docker exec -it main_nginx nginx -s reload


