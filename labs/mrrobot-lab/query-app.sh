#!/bin/sh
set -eu
cfg=/opt/bitnami/apps/wordpress/htdocs/wp-config.php
user=$(sed -n "s/.*'DB_USER', '\\([^']*\\)'.*/\\1/p" "$cfg")
pass=$(sed -n "s/.*'DB_PASSWORD', '\\([^']*\\)'.*/\\1/p" "$cfg")
/opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -u "$user" -p"$pass" -N -e "SHOW DATABASES;"
/opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -u "$user" -p"$pass" -N -e "SELECT option_name, option_value FROM bitnami_wordpress.wp_options WHERE option_name IN ('siteurl','home');"
curl -sk -o /dev/null -w 'in_http %{http_code}\n' http://127.0.0.1/ || true
