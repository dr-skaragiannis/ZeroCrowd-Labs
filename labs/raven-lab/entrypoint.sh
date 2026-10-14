#!/bin/bash
set -e
mkdir -p /var/run/mysqld /var/run/sshd
chown mysql:mysql /var/run/mysqld
chmod 755 /var/run/sshd

if [ ! -d /var/lib/mysql/mysql ]; then
  mysql_install_db --user=mysql --datadir=/var/lib/mysql >/tmp/mysql-install.log
fi

mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
mpid=$!
ready=0
for _ in $(seq 1 60); do
  if mysqladmin --protocol=socket ping >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 1
done
if [ "$ready" != 1 ]; then
  echo "MySQL did not become ready" >&2
  exit 1
fi

DBPASS=$(awk -F"'" '/DB_PASSWORD/ {print $4; exit}' /var/www/html/wordpress/wp-config.php)
if mysql --protocol=socket -uroot -e "SELECT 1" >/dev/null 2>&1; then
  mysql --protocol=socket -uroot <<SQL
UPDATE mysql.user SET plugin='mysql_native_password' WHERE User='root';
UPDATE mysql.user SET Password=PASSWORD('${DBPASS}') WHERE User='root';
FLUSH PRIVILEGES;
SQL
elif ! mysql --protocol=socket -uroot -p"${DBPASS}" -e "SELECT 1" >/dev/null 2>&1; then
  echo "MySQL root login failed" >&2
  exit 1
fi

if ! mysql --protocol=socket -uroot -p"${DBPASS}" -N -e "SHOW DATABASES LIKE 'wordpress'" | grep -q wordpress; then
  mysql --protocol=socket -uroot -p"${DBPASS}" < /opt/raven/wordpress.sql
fi

if ! crontab -l 2>/dev/null | grep -q 'service sendmail start'; then
  printf '%s\n' '@reboot service sendmail start' | crontab -
fi

mysqladmin --protocol=socket -uroot -p"${DBPASS}" shutdown >/dev/null
wait "$mpid" || true
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
