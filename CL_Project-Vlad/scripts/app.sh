#!/bin/bash

set -eu

#Set variables based on argument passed
VM_NAME="$1"

if [[ "$VM_NAME" != app[12] ]]; then
  echo "Invalid argument. Valid arguments: 'app1', 'app2'."
  exit 1
fi

if [[ "$VM_NAME" == "app1" ]]; then
  IP="10.0.2.4/24"
elif [[ "$VM_NAME" == "app2" ]]; then
  IP="10.0.2.5/24"
fi

#Set static ip
sudo tee /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - $IP
      routes:
        - to: default
          via: 10.0.2.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
EOF
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
sudo tee /etc/systemd/system/FlaskBirdApp.service << EOF
[Unit]
Description=Gunicorn instance to serve FlaskBirdApp
After=network.target

[Service]
User=nda
Group=www-data
WorkingDirectory=/home/nda/FlaskBirdApp
Environment="PATH=/home/nda/FlaskBirdApp/.venv/bin"
ExecStart=/home/nda/FlaskBirdApp/.venv/bin/gunicorn --workers 3 --bind unix:FlaskBirdApp.sock -m 007 app:app

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable FlaskBirdApp.service
sudo systemctl start FlaskBirdApp.service


#Change default NGINX config
sudo tee /etc/nginx/sites-available/default << EOF
server {
    listen 80 default_server;

    location / {
        include proxy_params;
        proxy_pass http://unix:/home/nda/FlaskBirdApp/FlaskBirdApp.sock;
    }
}
EOF
sudo systemctl restart nginx


#Lynis configuration
sudo apt install lynis -y

sudo mkdir /var/log/lynis

sudo tee /usr/local/bin/lynis-cronjob.sh << EOF
#!/bin/bash

set -u
HOST=$VM_NAME
EOF
sudo tee -a /usr/local/bin/lynis-cronjob.sh << 'EOF'
DATE=$(date +%Y%m%d_%H%M%S)
REPORT="/var/log/lynis/report-${HOST}_${DATE}.txt"

lynis audit system --cronjob > "${REPORT}"
sftp -o StrictHostKeyChecking=accept-new -i /home/nda/.ssh/host_machine nda@10.0.2.1:/home/nda/reports/ <<< $"put ${REPORT}"
EOF
sudo chmod +x /usr/local/bin/lynis-cronjob.sh

sudo tee -a /etc/crontab << EOF
0,30 * * * * root /usr/local/bin/lynis-cronjob.sh
EOF
