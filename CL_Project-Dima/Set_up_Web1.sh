#!/bin/bash

apt update -y

apt install nginx -y

systemctl start nginx

echo "
<!DOCTYPE html>
<html>
<head>
  <title>VM1</title>
</head>
<body>
  <h1>Bird from VM1</h1>
  <img src="https://npgallery.nps.gov/GetAsset/30d618f9-9791-48c1-af04-80c154876417/proxyhires?" width="400">
</body>
</html>
" > /var/www/html/index.html

nginx -t
systemctl restart nginx
