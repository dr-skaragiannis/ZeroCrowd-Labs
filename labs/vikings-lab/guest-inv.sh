#!/bin/bash
{
echo '=== OS ==='
. /etc/os-release
echo "$PRETTY_NAME $VERSION_CODENAME $(uname -r)"
echo '=== LISTEN ==='
ss -lntup || netstat -lntup
echo '=== PASSWD ==='
awk -F: '($3==0 || $3>=1000) {print $1,$3,$4,$6,$7}' /etc/passwd
echo '=== GROUP ==='
getent group sudo docker lxd
echo '=== SUDO ==='
grep -vE '^#|^$' /etc/sudoers
echo '=== SUDOD ==='
for f in /etc/sudoers.d/*; do echo "-- $f"; grep -vE '^#|^$' "$f"; done
echo '=== PKG ==='
dpkg-query -W -f '${Package} ${Version}\n' apache2 openssh-server docker.io docker-ce containerd cron sudo rsyslog nginx mysql-server mariadb-server php php7.2 php7.2-cli libapache2-mod-php7.2 2>/dev/null
echo '=== DOCKER ==='
docker ps -a --format '{{.Names}} {{.Image}} {{.Ports}} {{.Status}}' 2>/dev/null || true
echo '=== APACHE ==='
apachectl -S 2>/dev/null || true
echo '=== SITES ==='
ls /etc/apache2/sites-enabled 2>/dev/null || true
echo '=== CRON ==='
ls /etc/cron.d /var/spool/cron/crontabs 2>/dev/null || true
echo '=== MAIL ==='
dpkg-query -W -f '${Package} ${Version}\n' postfix sendmail 2>/dev/null || true
echo '=== ENDINV ==='
} > /root/inv.txt 2>&1
echo WROTE_INV
