#!/bin/bash
set -eu
M=/mnt/straylight
mkdir -p "$M"
mount /dev/loop0p1 "$M"
echo "===== OS ====="
cat "$M/etc/os-release" || true
echo "===== KERNEL ====="
ls "$M/lib/modules" 2>/dev/null || true
echo "===== PASSWD ====="
awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1, $3, $4, $6, $7}' "$M/etc/passwd"
echo "===== GROUPS ====="
grep -E '^(sudo|wheel|admin):' "$M/etc/group" || true
echo "===== SHADOW PREFIX ====="
awk -F: '{split($2,a,"$"); print $1, (a[2]?"$"a[2]"$":$2)}' "$M/etc/shadow"
echo "===== SUDOERS ====="
grep -vE '^#|^$' "$M/etc/sudoers" || true
echo "===== SUDOERS.D ====="
ls -la "$M/etc/sudoers.d" || true
echo "===== SSHD ====="
grep -E '^(Port|ListenAddress|PermitRootLogin|PasswordAuthentication)' "$M/etc/ssh/sshd_config" || true
echo "===== INIT ====="
ls "$M/etc/rc*.d" 2>/dev/null | head -5 || true
ls "$M/etc/systemd/system/multi-user.target.wants" 2>/dev/null || true
echo "===== PACKAGES ====="
awk '
  $0=="" { if (ok && p!="") print p "\t" v; ok=0; p=""; v=""; next }
  $1=="Package:" { p=$2 }
  $1=="Status:" && $0 ~ / installed$/ { ok=1 }
  $1=="Version:" { v=$2 }
  END { if (ok && p!="") print p "\t" v }
' "$M/var/lib/dpkg/status" | grep -E '^(apache2|nginx|openssh-server|openssh-client|sudo|cron|mysql-server|mariadb-server|postfix|sendmail|exim4|dma|php5|php7|python|python3|vsftpd|bind9|samba|dovecot|proftpd|lighttpd|nodejs|ruby|postgresql)([[:space:]]|$)' || true
echo MOUNTED_STRAY
