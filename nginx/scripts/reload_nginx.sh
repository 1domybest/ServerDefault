#!/bin/bash

#docker cp main_nginx:/etc/nginx/sites-available ./sites-available

docker exec -it main_nginx nginx -s reload


#docker restart main_nginx
