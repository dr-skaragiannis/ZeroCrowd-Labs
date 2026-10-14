#!/bin/bash
set -eu
echo "===== TOMCAT UNIT ====="
cat /mnt/neuromancer/etc/systemd/system/tomcat.service
echo "===== ROOT CRON ====="
cat /mnt/neuromancer/var/spool/cron/crontabs/root
echo "===== FIND TOMCAT ====="
find /mnt/neuromancer -iname '*tomcat*' -o -iname 'server.xml' 2>/dev/null | head -40
echo DONE_NEURO3
