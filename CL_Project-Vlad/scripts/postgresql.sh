#!/bin/sh

sudo apt install postgresql

sudo apt install nginx

#Lynis configuration

sudo apt install lynis -y

sudo mkdir /var/log/lynis
sudo mkdir /usr/local/sbin/lynis

sudo tee /usr/local/sbin/lynis/cronjob.sh << 'EOF'
#!/bin/sh

set -u
DATE=$(date +%Y%m%d_%H%M%S)
HOST="postgresql"
REPORT="/var/log/lynis/report-${HOST}_${DATE}.txt"

lynis audit system --cronjob > "${REPORT}"
scp -o StrictHostKeyChecking=accept-new -i /home/nda/.ssh/host_machine "${REPORT}" nda@10.0.2.1:/home/nda/reports/
EOF
sudo chmod +x /usr/local/sbin/lynis/cronjob.sh

sudo tee -a /etc/crontab << EOF
0,30 * * * * root cd /usr/local/sbin/lynis && ./cronjob.sh
EOF
