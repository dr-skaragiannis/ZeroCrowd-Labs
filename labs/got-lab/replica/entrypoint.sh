#!/bin/sh
set -eu
if [ ! -f /var/lib/replica/users.ready ]; then
  ssh-keygen -A >/dev/null 2>&1 || true
  if ! awk -F: '($1=="root" || $1=="daenerystargaryen" || $1=="branstark") && $2 ~ /^\$/ {print $1 ":" $2}' /seed/shadow-users.txt | chpasswd -e; then
    echo "guest hash import failed" >&2
    exit 1
  fi
  if [ -s /seed/operator.pass ]; then
    chpasswd < /seed/operator.pass
  fi
  touch /var/lib/replica/users.ready
fi
exec "$@"
