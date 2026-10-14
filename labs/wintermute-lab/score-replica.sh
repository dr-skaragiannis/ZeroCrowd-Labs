#!/bin/bash
set -eu
sleep 8
for c in straylight neuromancer; do
  echo "===== $c INSPECT ====="
  docker inspect "$c" --format 'mem={{.HostConfig.Memory}} ip={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} ports={{json .HostConfig.PortBindings}}'
  echo "===== $c SS ====="
  docker exec "$c" ss -lntup || true
  echo "===== $c SUP ====="
  docker exec "$c" supervisorctl status || true
done
echo "===== STRAY PKGS ====="
docker exec straylight dpkg-query -W -f='${Package}\t${Version}\n' apache2 apache2-bin php7.0 mariadb-server-10.1 postfix redis-server snmpd cron sudo
echo "===== NEURO PKGS ====="
docker exec neuromancer dpkg-query -W -f='${Package}\t${Version}\n' openssh-server sudo cron
echo "===== NEURO JAVA ====="
docker exec neuromancer /usr/lib/jvm/jdk1.8.0_171/bin/java -version
echo "===== USERS ====="
docker exec straylight awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1,$3,$4,$7}' /etc/passwd
docker exec neuromancer awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1,$3,$4,$7}' /etc/passwd
echo "===== VISUDO ====="
docker exec straylight visudo -c
docker exec neuromancer visudo -c
echo "===== HTTP ====="
curl -s -o /dev/null -w 'stray80 %{http_code}\n' http://10.88.10.13/
curl -s -o /dev/null -w 'stray3000 %{http_code}\n' http://10.88.10.13:3000/ || true
curl -s -o /dev/null -w 'neuro8080 %{http_code}\n' http://10.88.10.14:8080/ || true
echo "===== CRON ====="
docker exec neuromancer crontab -u root -l | awk 'NF && $1 !~ /^#/ {print}'
echo ENDSCORE
