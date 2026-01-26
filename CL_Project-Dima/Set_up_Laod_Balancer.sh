#!/bin/bash

apt update -y

apt install nginx -y

echo "
upstream samplecluster {
    server 192.168.0.51;
    server 192.168.0.52;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;

    location / {
        proxy_pass http://samplecluster;
    }
}
" > /etc/nginx/sites-available/default

nginx -t

systemctl restart nginx
