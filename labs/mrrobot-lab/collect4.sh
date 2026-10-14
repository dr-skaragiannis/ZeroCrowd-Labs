#!/bin/bash
set -eu
M=/mnt/mrrobot
echo '## PREFIX'
cat "$M/opt/bitnami/apache2/conf/bitnami/bitnami-apps-prefix.conf"
echo '## WP PREFIX'
cat "$M/opt/bitnami/apps/wordpress/conf/httpd-prefix.conf"
echo '## PMA PREFIX'
cat "$M/opt/bitnami/apps/phpmyadmin/conf/httpd-prefix.conf"
echo '## TABLE PREFIX'
grep -n 'table_prefix' "$M/opt/bitnami/apps/wordpress/htdocs/wp-config.php"
echo '## INIT BITNAMI HEAD'
sed -n '1,80p' "$M/etc/init.d/bitnami" 2>/dev/null || ls "$M/etc/init.d" | head
echo '## PHP FPM LISTEN'
grep -nE 'listen|user|group' "$M/opt/bitnami/apps/wordpress/conf/php-fpm/pool.conf" | head -n 20
echo '## MONIT SET'
grep -nE '^[[:space:]]*set httpd|^[[:space:]]*set daemon' "$M/etc/monit/monitrc" || echo 'monit httpd not set'
