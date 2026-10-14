#!/bin/sh
set -eu
mkdir -p /var/run/sshd /var/log/supervisor
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
fi
exec supervisord -n -c /etc/supervisor/supervisord.conf
