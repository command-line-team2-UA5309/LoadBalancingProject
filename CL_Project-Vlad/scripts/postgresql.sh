#!/bin/bash

set -e

#Set variables for configuration files
export VM_NAME="load_balancer"
export IP="10.0.2.3/24"

#Set static ip
envsubst < static_ip_tpl.yaml > 01-netcfg.yaml
sudo mv 01-netcfg.yaml /etc/netplan
sudo chmod 600 /etc/netplan/01-netcfg.yaml
sudo netplan apply


#Install packages
sudo apt install postgresql -y

sudo apt install nginx -y


#Lynis configuration
sudo apt install lynis -y

sudo mkdir /var/log/lynis

envsubst '${VM_NAME}' < lynis-cronjob-tmp.sh > lynis-cronjob.sh
sudo mv lynis-cronjob.sh /usr/local/bin
sudo chmod +x /usr/local/bin/lynis-cronjob.sh

sudo tee -a /etc/crontab << EOF
0,30 * * * * root /usr/local/bin/lynis-cronjob.sh
EOF
