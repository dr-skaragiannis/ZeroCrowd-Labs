#!/bin/sh
set -eu
ssh-keygen -A
if ! awk -F: '($1=="root" || $1=="gaara") && $2 ~ /^\$/ {print $1 ":" $2}' /seed/shadow-users.txt | chpasswd -e; then
  echo "guest hash import failed" >&2
  exit 1
fi
if [ -s /seed/operator.pass ]; then
  chpasswd < /seed/operator.pass
fi
exec supervisord -n -c /etc/supervisor/supervisord.conf
