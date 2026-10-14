#!/bin/sh
set -eu
mkdir -p /var/run/sshd /var/run/apache2 /var/log/supervisor /var/spool/cron/crontabs
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
fi
crontab -u root /opt/replica/root.crontab
exec supervisord -n -c /etc/supervisor/supervisord.conf
