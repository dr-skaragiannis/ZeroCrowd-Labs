#!/bin/bash
set -eu
sleep 3
echo "=== INSPECT ==="
docker inspect matrix --format 'mem={{.HostConfig.Memory}} ip={{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}} ports={{json .HostConfig.PortBindings}}'
echo "=== SS ==="
docker exec matrix ss -lntup || docker exec matrix netstat -lntup
echo "=== PY ==="
docker exec matrix python -V
echo "=== PKGS ==="
docker exec matrix dpkg-query -W -f='${Package}\t${Version}\n' openssh-server sudo python2.7 supervisor || true
echo "=== USERS ==="
docker exec matrix awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1, $3, $4, $6, $7}' /etc/passwd
echo "=== VISUDO ==="
docker exec matrix visudo -c
echo "=== HTTP ==="
curl -s -o /dev/null -w 'p80 %{http_code}\n' http://10.88.10.12/
curl -s -o /dev/null -w 'p31337 %{http_code}\n' http://10.88.10.12:31337/
echo "=== ENDSCORE ==="
