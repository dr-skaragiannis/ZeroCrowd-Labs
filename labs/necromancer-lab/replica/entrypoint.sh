#!/bin/sh
set -eu
ssh-keygen -A
printf 'PermitRootLogin yes\nPasswordAuthentication yes\n' >> /etc/ssh/sshd_config
if ! awk -F: '($1=="root" || $1=="demonslayer") && $2 ~ /^\$/ {print $1 ":" $2}' /seed/shadow-users.txt | chpasswd -e; then
  echo "guest hash import failed" >&2
  exit 1
fi
if [ -s /seed/operator.pass ]; then
  chpasswd < /seed/operator.pass
fi
crontab /root/scripts/root.cron
exec supervisord -n -c /etc/supervisor/supervisord.conf
