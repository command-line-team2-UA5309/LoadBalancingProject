#!/bin/bash

set -u
DATE=$(date +%Y%m%d_%H%M%S)
HOST="$VM_NAME"
REPORT="/var/log/lynis/report-${HOST}_${DATE}.txt"

lynis audit system --cronjob > "${REPORT}"
sftp -o StrictHostKeyChecking=accept-new -i /home/nda/.ssh/host_machine nda@10.0.2.1:/home/nda/reports/ <<< $"put ${REPORT}"
