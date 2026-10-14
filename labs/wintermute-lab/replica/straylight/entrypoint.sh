#!/bin/sh
set -eu
mkdir -p /var/run/mysqld /var/run/ntopng /var/log/supervisor /var/run/snmp
chown mysql:mysql /var/run/mysqld
if [ ! -d /var/lib/mysql/mysql ]; then
  mysql_install_db --user=mysql --datadir=/var/lib/mysql >/tmp/mysql-install.log
fi
exec supervisord -n -c /etc/supervisor/supervisord.conf
