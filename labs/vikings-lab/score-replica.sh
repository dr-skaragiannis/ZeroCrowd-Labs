#!/bin/bash
set -eu
sleep 4
echo "=== INSPECT ==="
docker inspect vikings --format 'mem={{.HostConfig.Memory}} ip={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} ports={{json .HostConfig.PortBindings}}'
echo "=== SS ==="
docker exec vikings ss -lntup || true
echo "=== PKGS ==="
docker exec vikings dpkg-query -W -f='${Package}\t${Version}\n' apache2 apache2-bin apache2-data apache2-utils openssh-server cron sudo python3 dma
echo "=== RPYC ==="
docker exec vikings python3 -c 'import rpyc; print(rpyc.__version__)'
echo "=== USERS ==="
docker exec vikings awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1, $3, $4, $6, $7}' /etc/passwd
docker exec vikings getent group sudo lxd
echo "=== VISUDO ==="
docker exec vikings visudo -c
echo "=== CRON ==="
docker exec vikings crontab -u root -l | awk 'NF && $1 !~ /^#/'
echo "=== HTTP ==="
curl -s -o /dev/null -w 'root %{http_code}\n' http://10.88.10.11/
curl -s -o /dev/null -w 'site %{http_code}\n' http://10.88.10.11/site/
curl -s -o /dev/null -w 'index %{http_code}\n' http://10.88.10.11/site/index.html
echo "=== UNPUBLISHED ==="
docker exec vikings ss -lnt | awk 'NR>1 {print $4}' | grep -E '18812|:25|:587|:53' || true
echo "=== SUPER ==="
docker exec vikings supervisorctl status || true
echo "=== ENDSCORE ==="
