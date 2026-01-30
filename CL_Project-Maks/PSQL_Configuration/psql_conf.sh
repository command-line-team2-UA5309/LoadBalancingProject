#!/bin/bash

set -e

cat ip_conf_template > /etc/netplan/50-cloud-init.yaml
netplan apply

apt install postgresql -y


apt install lynis -y

mv ../Sec_Scan/audit.sh /usr/local/bin/
chmod +x /usr/local/bin/audit.sh

echo "*/30 * * * * root bash /usr/local/bin/audit.sh" >> /etc/crontab
systemctl restart cron