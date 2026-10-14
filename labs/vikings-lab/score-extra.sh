#!/bin/bash
set -eu
docker exec vikings ls -l /etc/sudoers.d
echo "=== CRON.D ==="
docker exec vikings ls /etc/cron.d
echo "=== APACHE ==="
docker exec vikings apachectl -S
echo "=== EXTRA PKGS ==="
docker exec vikings sh -c 'dpkg-query -W systemd rsyslog containerd docker.io 2>&1 || true'
echo "=== RESOLVED BIN ==="
docker exec vikings sh -c 'command -v systemd-resolved || true; ls /lib/systemd/systemd-resolved 2>/dev/null || true'
echo "=== MAIL ==="
docker exec vikings sh -c 'ss -lnt | grep -E ":25|:587" || echo no-mail-listener; dpkg-query -W dma'
