#!/bin/bash

set -e

#Set static ip
sudo tee /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 10.0.2.6/24
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
sudo apt install postgresql -y

sudo apt install nginx -y


#Lynis configuration
sudo apt install lynis -y

sudo mkdir /var/log/lynis

sudo tee /usr/local/bin/lynis-cronjob.sh << 'EOF'
#!/bin/bash

set -u
DATE=$(date +%Y%m%d_%H%M%S)
HOST="postgresql"
REPORT="/var/log/lynis/report-${HOST}_${DATE}.txt"

lynis audit system --cronjob > "${REPORT}"
sftp -o StrictHostKeyChecking=accept-new -i /home/nda/.ssh/host_machine nda@10.0.2.1:/home/nda/reports/ <<< $"put ${REPORT}"
EOF
sudo chmod +x /usr/local/bin/lynis-cronjob.sh

sudo tee -a /etc/crontab << EOF
0,30 * * * * root /usr/local/bin/lynis-cronjob.sh
EOF
