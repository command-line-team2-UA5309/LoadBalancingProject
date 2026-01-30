#!/bin/bash

set -e

export SERVER="$1"

if [[ "$SERVER" != [12] ]]; then
    echo "Not correct parram"
    exit 1
fi

if [[ "$SERVER" == 1 ]]; then
    export IP="192.168.1.108/24"
else
    export IP="192.168.1.109/24"
fi

apt install nginx -y

systemctl start nginx

cp ws_conf_template /etc/nginx/sites-available

ln -s /etc/nginx/sites-available/ws_conf_template /etc/nginx/sites-enabled/

if [ -f "/etc/nginx/sites-enabled/default" ]; then
    rm /etc/nginx/sites-enabled/default
fi

envsubst < ip_conf_template > /etc/netplan/50-cloud-init.yaml
netplan apply

systemctl restart nginx


apt install lynis -y

mv ../Sec_Scan/audit.sh /usr/local/bin/
chmod +x /usr/local/bin/audit.sh

echo "*/30 * * * * root bash /usr/local/bin/audit.sh" >> /etc/crontab
systemctl restart cron

sudo apt install python3 python3-pip python3-venv -y

python3 -m venv ../bird_app/.venv
. ../bird_app/.venv/bin/activate

pip install -r ../bird_app/requirements.txt

python3 ../bird_app/app.py