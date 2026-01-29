#!/bin/bash

set -eu

#Set variables based on argument passed
export VM_NAME="$1"

if [[ "$VM_NAME" != app[12] ]]; then
  echo "Invalid argument. Valid arguments: 'app1', 'app2'."
  exit 1
fi

if [[ "$VM_NAME" == "app1" ]]; then
  export IP="10.0.2.4/24"
elif [[ "$VM_NAME" == "app2" ]]; then
  export IP="10.0.2.5/24"
fi

#Set static ip
envsubst < static_ip_tpl.yaml > 01-netcfg.yaml
sudo mv 01-netcfg.yaml /etc/netplan
sudo chmod 600 /etc/netplan/01-netcfg.yaml
sudo netplan apply


#Install packages
sudo apt install python3 python3-pip python3-venv -y

sudo apt install nginx -y


#Install python packages
python3 -m venv /home/nda/FlaskBirdApp/.venv
source /home/nda/FlaskBirdApp/.venv/bin/activate
pip install --upgrade pip
pip install flask
pip install gunicorn
deactivate


#Change permitions for application folder
sudo chmod 755 /home/nda
sudo chmod -R 755 /home/nda/FlaskBirdApp


#Create systemd service for python application
sudo cp FlaskBirdApp.service /etc/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable FlaskBirdApp.service
sudo systemctl start FlaskBirdApp.service


#Change default NGINX config
sudo cp default_applicaiton default
sudo mv -f default /etc/nginx/sites-available/
sudo systemctl restart nginx


#Lynis configuration
sudo apt install lynis -y

sudo mkdir /var/log/lynis

envsubst '${VM_NAME}' < lynis-cronjob-tmp.sh > lynis-cronjob.sh
sudo mv lynis-cronjob.sh /usr/local/bin
sudo chmod +x /usr/local/bin/lynis-cronjob.sh

sudo tee -a /etc/crontab << EOF
0,30 * * * * root /usr/local/bin/lynis-cronjob.sh
EOF
