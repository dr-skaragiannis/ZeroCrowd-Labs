#!/bin/sh
set -eu
rm -rf /root/seed
mkdir -p /root/seed/webroot /root/seed/pylib /root/seed/cron.d /root/seed/sudoers.d
tar -C /var/www/html -cf - . | tar -C /root/seed/webroot -xf -
cp -a /usr/local/lib/python3.6/dist-packages/. /root/seed/pylib/
cp -a /usr/local/bin/rpyc_classic.py /root/seed/rpyc_classic.py
cp -a /etc/sudoers.d/bloodraven /root/seed/sudoers.d/bloodraven
if [ -f /etc/sudoers.d/99-snapd.conf ]; then
  cp -a /etc/sudoers.d/99-snapd.conf /root/seed/sudoers.d/99-snapd.conf
fi
crontab -u root -l > /root/seed/root.crontab
cp -a /etc/apache2/sites-enabled/000-default.conf /root/seed/000-default.conf
cp -a /etc/crontab /root/seed/crontab
for f in dma cron-apt mdadm popularity-contest; do
  if [ -f "/etc/cron.d/$f" ]; then
    cp -a "/etc/cron.d/$f" "/root/seed/cron.d/$f"
  fi
done
{
  echo "=== HTML ==="
  ls -la /var/www/html
  echo "=== MODS ==="
  ls /etc/apache2/mods-enabled
  echo "=== CONTAINERD FD ==="
  ls -l /proc/1220/fd/12 2>/dev/null || true
  echo "=== CONTAINERD ENV ==="
  tr '\0' '\n' < /proc/1220/environ | grep -E '^(PATH|NOTIFY_SOCKET|CONTAINERD_|DOCKER_)=' || true
} > /root/seed/notes.txt
tar -C /root/seed -cf /root/seed.tar .
echo "PACKED $(wc -c < /root/seed.tar)"
