#!/bin/sh
set -eu
mkdir -p /opt/bitnami/mysql/tmp /opt/bitnami/php/var/run /opt/bitnami/apache2/logs /var/run/sshd /var/lib/replica
chown mysql:mysql /opt/bitnami/mysql/tmp
chown daemon:daemon /opt/bitnami/php/var/run
if [ ! -f /var/lib/replica/db.ready ]; then
  touch /var/lib/replica/db.ready
fi
exec supervisord -n -c /etc/supervisor/supervisord.conf
