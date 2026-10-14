#!/bin/bash
set -eu
sleep 10
echo "===== STRAY SS ====="
docker exec straylight ss -lntup
echo "===== NTOP ====="
docker exec straylight ldd /usr/local/bin/ntopng | awk '/not found/ {print}' || true
docker exec straylight sh -c 'ps aux | grep -E "ntop|snmp" | grep -v grep' || true
echo "===== HTTP ====="
curl -s -o /dev/null -w 'stray80 %{http_code}\n' http://10.88.10.13/
curl -s -o /dev/null -w 'stray3000 %{http_code}\n' --max-time 5 http://10.88.10.13:3000/ || true
curl -s -o /dev/null -w 'neuro8080 %{http_code}\n' --max-time 5 http://10.88.10.14:8080/ || true
echo "===== NEURO PORTS ====="
docker exec neuromancer cat /proc/net/tcp /proc/net/tcp6 | awk 'NR>1 {print $2}'
echo RESCORE_DONE
