#!/bin/bash
set -eu
M=/mnt/mrrobot
LAB=/mnt/c/Users/bloodraven/Projects/mrrobot-lab
REP="$LAB/replica"
umask 077

# Refresh the application URL inside the copied data directory.
rm -f "$M/opt/bitnami/mysql/tmp/mysql.sock"
mkdir -p "$M/opt/bitnami/mysql/tmp"
mountpoint -q "$M/proc" || mount --bind /proc "$M/proc"
mountpoint -q "$M/dev" || mount --bind /dev "$M/dev"
chroot "$M" /opt/bitnami/mysql/bin/mysqld --user=mysql --skip-networking --skip-grant-tables \
  >/var/tmp/mrrobot-disk/mysqld.log 2>&1 &
echo $! > /var/tmp/mrrobot-disk/mysqld.pid
SOCK="$M/opt/bitnami/mysql/tmp/mysql.sock"
i=0
while [ ! -S "$SOCK" ]; do
  i=$((i+1))
  if [ "$i" -gt 40 ] || ! kill -0 "$(cat /var/tmp/mrrobot-disk/mysqld.pid)" 2>/dev/null; then
    echo MYSQL_START_FAIL
    tail -n 30 /var/tmp/mrrobot-disk/mysqld.log || true
    exit 1
  fi
  sleep 1
done
chroot "$M" /opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -e \
  "UPDATE bitnami_wordpress.wp_options SET option_value='http://10.88.10.18/' WHERE option_name IN ('siteurl','home');"
chroot "$M" /opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -N -e \
  "SELECT option_name, option_value FROM bitnami_wordpress.wp_options WHERE option_name IN ('siteurl','home');"
chroot "$M" /opt/bitnami/mysql/bin/mysqladmin --socket=/opt/bitnami/mysql/tmp/mysql.sock shutdown || true
wait "$(cat /var/tmp/mrrobot-disk/mysqld.pid)" || true

# Local admin on the offline clone.
if ! chroot "$M" id bloodraven >/dev/null 2>&1; then
  chroot "$M" groupadd -g 1003 bloodraven
  chroot "$M" useradd -u 1003 -g 1003 -G admin -m -d /home/bloodraven -s /bin/bash bloodraven
fi
openssl rand -base64 18 > "$REP/operator.pass"
chmod 600 "$REP/operator.pass"
chroot "$M" chpasswd <<EOF
root:$(cat "$REP/operator.pass")
bloodraven:$(cat "$REP/operator.pass")
EOF
echo 'bloodraven ALL=(ALL:ALL) ALL' > "$M/etc/sudoers.d/bloodraven"
chmod 440 "$M/etc/sudoers.d/bloodraven"
chroot "$M" visudo -c

# Shadow extract for the replica. Do not print it.
awk -F: '$1=="robot" || $1=="bitnamiftp" {print}' "$M/etc/shadow" > "$REP/shadow-users.txt"
chmod 600 "$REP/shadow-users.txt"

cp -a "$M/etc/vsftpd.conf" "$REP/vsftpd.conf"
chmod 644 "$REP/vsftpd.conf"

if [ ! -d "$REP/bitnami/apache2" ]; then
  mkdir -p "$REP/bitnami"
  tar -C "$M/opt/bitnami" -cf - . | tar -C "$REP/bitnami" -xf -
fi

IMG="$LAB/resources-staging"
rm -rf "$IMG"
mkdir -p "$IMG/headlines" "$IMG/question" "$IMG/other"
cp -a "$M/opt/bitnami/apps/wordpress/htdocs/admin/images/headlines/." "$IMG/headlines/"
cp -a "$M/opt/bitnami/apps/wordpress/htdocs/admin/images/question/." "$IMG/question/"
cp -a "$M/opt/bitnami/apps/wordpress/htdocs/admin/images/420/420.jpg" "$IMG/other/420.jpg"
cp -a "$M/opt/bitnami/apps/wordpress/htdocs/admin/images/btn-play.png" "$IMG/other/btn-play.png"
if [ -f "$M/opt/bitnami/apps/wordpress/htdocs/favicon.ico" ]; then
  cp -a "$M/opt/bitnami/apps/wordpress/htdocs/favicon.ico" "$IMG/other/favicon.ico"
fi
find "$IMG" -type f ! -regex '.*\.\(png\|jpg\|jpeg\|gif\|webp\|svg\|ico\)' -delete
echo PREPARE_OK
find "$IMG" -type f | wc -l
