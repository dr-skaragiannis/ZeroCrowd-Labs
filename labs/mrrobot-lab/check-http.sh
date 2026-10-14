#!/bin/bash
set -eu
docker exec mrrobot /opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -N -e "SHOW DATABASES;"
docker exec mrrobot /opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -N -e "SELECT option_name, option_value FROM bitnami_wordpress.wp_options WHERE option_name IN ('siteurl','home');"
curl -sk -o /dev/null -w 'http %{http_code}\n' http://10.88.10.18/
curl -sk -o /dev/null -w 'https %{http_code}\n' https://10.88.10.18/
curl -sk -o /dev/null -w 'pma %{http_code}\n' http://10.88.10.18/phpmyadmin/
curl -s -o /dev/null -w 'port3306 %{http_code}\n' --connect-timeout 3 http://10.88.10.18:3306/ || echo 'port3306_closed'
