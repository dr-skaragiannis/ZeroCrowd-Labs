#!/bin/bash
set -eu
M=/mnt/gaara
echo "===== PORTS ====="
grep -nE 'Listen|VirtualHost|DocumentRoot|ServerName|ServerAlias' "$M"/etc/apache2/ports.conf "$M"/etc/apache2/sites-enabled/* 2>/dev/null || true
echo "===== MODS ====="
ls "$M/etc/apache2/mods-enabled" | head -40
echo "===== WWW ====="
find "$M/var/www" -maxdepth 3 -printf '%y %s %p\n' | head -80
echo "===== PACKAGES ====="
awk -F': ' '
  $1=="Package" {p=$2}
  $1=="Status" {s=$2}
  $1=="Version" && s ~ /install ok installed/ && p ~ /^(apache2|libapache2-mod-php|php[0-9.]*|openssh-server|sudo|cron|mariadb-server|mysql-server|postfix|exim4|sendmail|nginx|vsftpd|proftpd|bind9|samba|postgresql)$/ {print p, $2}
' "$M/var/lib/dpkg/status"
echo "===== PHP PKGS ====="
awk -F': ' '
  $1=="Package" {p=$2}
  $1=="Status" {s=$2}
  $1=="Version" && s ~ /install ok installed/ && p ~ /php/ {print p, $2}
' "$M/var/lib/dpkg/status"
echo "===== DB DIRS ====="
ls -d "$M"/var/lib/mysql "$M"/var/lib/postgresql "$M"/etc/mysql 2>/dev/null || true
echo "===== CRON ====="
ls "$M/etc/cron.d" "$M/var/spool/cron/crontabs" 2>/dev/null || true
echo "===== SUDOERS TAIL ====="
tail -20 "$M/etc/sudoers"
echo "===== SUDOERS.D ====="
ls "$M/etc/sudoers.d" 2>/dev/null || true
echo "===== SSH DEFAULTS ====="
grep -nE 'Port |PermitRoot|PasswordAuth|ListenAddress' "$M/etc/ssh/sshd_config" | head -20
echo LOOK3_DONE
