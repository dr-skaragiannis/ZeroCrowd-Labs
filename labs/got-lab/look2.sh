#!/bin/bash
set -eu
M=/mnt/got
echo "===== SSH ====="
grep -nE '^[Pp]ort |^[Ll]istenAddress |^[Pp]ermitRootLogin |^[Pp]asswordAuthentication ' "$M/etc/ssh/sshd_config" || true
echo "===== RSYNC ====="
ls "$M/etc/rsyncd.conf" "$M/etc/default/rsync" 2>/dev/null || true
if [ -f "$M/etc/default/rsync" ]; then grep -nE '^RSYNC_ENABLE' "$M/etc/default/rsync" || true; fi
echo "===== DOCKER UNITS ====="
ls "$M/etc/systemd/system/docker.service.d" 2>/dev/null || true
ls "$M/lib/systemd/system/docker.service" 2>/dev/null || true
echo "===== CONTAINERS ====="
find "$M/var/lib/docker/containers" -name hostconfig.json -o -name config.v2.json 2>/dev/null | head -40
echo "===== COMPOSE ====="
find "$M/home" "$M/root" "$M/opt" "$M/etc" -name 'docker-compose*.yml' -o -name 'compose.yaml' 2>/dev/null | head
echo "===== PKGS ====="
awk -F': ' '
  $1=="Package" {p=$2}
  $1=="Status" {s=$2}
  $1=="Version" && s ~ /install ok installed/ && p ~ /^(docker|docker.io|docker-ce|openssh-server|sudo|cron|fail2ban|rsync|apache2|nginx|mariadb-server|mysql-server|postfix)$/ {print p, $2}
' "$M/var/lib/dpkg/status"
echo LOOK2_DONE
