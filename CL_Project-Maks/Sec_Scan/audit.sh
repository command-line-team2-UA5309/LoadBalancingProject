#!/bin/bash

DATE=$(date +"%Y_%m_%d_%H_%M")

lynis audit system && cat /var/log/lynis-report.dat > /mnt/Sec_reports/$DATE.report