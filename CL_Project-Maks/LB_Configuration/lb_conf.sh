#!/bin/bash

set -e

apt install nginx -y

systemctl start nginx

mv lb_conf_template /etc/nginx/sites-available

ln -s /etc/nginx/sites-available/lb_conf_template /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default

cat ip_conf_template > /etc/netplan/50-cloud-init.yaml
netplan apply

systemctl restart nginx


apt install lynis -y

mv ../Sec_Scan/audit.sh /usr/local/bin/
chmod +x /usr/local/bin/audit.sh

echo "*/30 * * * * root bash /usr/local/bin/audit.sh" >> /etc/crontab
systemctl restart cron
