#!/bin/bash
set -eu
docker exec mrrobot chmod 644 /opt/bitnami/mysql/my.cnf
docker exec -d mrrobot /opt/bitnami/mysql/bin/mysqld --user=mysql
sleep 6
docker exec mrrobot ss -lnt
echo '## ERR'
docker exec mrrobot sh -c 'tail -n 30 /opt/bitnami/mysql/data/mysqld.log' || true
