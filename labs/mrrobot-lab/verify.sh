#!/bin/bash
set -eu
cd /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica
docker compose -f compose.yaml up -d --no-build
sleep 5
docker compose -f compose.yaml ps
echo '## INSPECT'
docker inspect mrrobot --format 'MEM={{.HostConfig.Memory}} IP={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} PORTS={{json .HostConfig.PortBindings}}'
i=0
while [ "$i" -lt 25 ]; do
  if docker exec mrrobot sh -c 'ss -lnt | grep -q ":80"'; then
    break
  fi
  i=$((i+1))
  sleep 2
done
echo '## SS'
docker exec mrrobot ss -lntup || true
echo '## PKG'
docker exec mrrobot dpkg-query -W openssh-server cron sudo vsftpd supervisor
echo '## USERS'
docker exec mrrobot awk -F: '($3==0 || $3>=1000) {print $1, $3, $4, $6, $7}' /etc/passwd
echo '## VISUDO'
docker exec mrrobot visudo -c
echo '## DB'
docker exec mrrobot sh -c 'i=0; while [ ! -S /opt/bitnami/mysql/tmp/mysql.sock ]; do i=$((i+1)); if [ "$i" -gt 20 ]; then exit 1; fi; sleep 2; done; /opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -N -e "SHOW DATABASES;"'
docker exec mrrobot /opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -N -e "SELECT option_name, option_value FROM bitnami_wordpress.wp_options WHERE option_name IN ('siteurl','home');"
echo '## HTTP'
curl -sk -o /dev/null -w 'http %{http_code}\n' http://10.88.10.18/ || true
curl -sk -o /dev/null -w 'https %{http_code}\n' https://10.88.10.18/ || true
curl -sk -o /dev/null -w 'pma %{http_code}\n' http://10.88.10.18/phpmyadmin/ || true
echo '## MYSQL PUBLISH'
ss -lnt | grep 3306 || echo 'no_host_3306'
echo '## LOG'
docker logs mrrobot 2>&1 | tail -n 40
