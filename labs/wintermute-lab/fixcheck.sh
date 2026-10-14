#!/bin/bash
set -eu
echo "===== NTOP LOG ====="
docker exec straylight sh -c 'ls /var/log/supervisor; tail -40 /var/log/supervisor/ntopng-stderr.log /var/log/supervisor/supervisord.log' || true
echo "===== NTOP LDD ====="
docker exec straylight ldd /usr/local/bin/ntopng | head -40 || true
echo "===== NEURO TCP ====="
docker exec neuromancer cat /proc/net/tcp
echo "===== NEURO TCP6 ====="
docker exec neuromancer cat /proc/net/tcp6
echo "===== SNMP CONF GUEST WAS REPLACED; REPLICA PS ====="
docker exec straylight ps aux | head -40
echo DONE_FIXCHECK
