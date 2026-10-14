#!/bin/bash
set -eu
M=/mnt/neuromancer
echo "===== WANTS ====="
ls "$M/etc/systemd/system/multi-user.target.wants" 2>/dev/null || true
echo "===== SUDOERS ====="
grep -vE '^#|^$' "$M/etc/sudoers" || true
echo "===== SUDOERS.D ====="
ls -la "$M/etc/sudoers.d" || true
echo "===== SSHD ====="
grep -E '^(Port|ListenAddress|PermitRootLogin|PasswordAuthentication)' "$M/etc/ssh/sshd_config" || true
echo "===== PKGS ====="
awk '
  $0=="" { if (ok && p!="") print p "\t" v; ok=0; p=""; v=""; next }
  $1=="Package:" { p=$2 }
  $1=="Status:" && $0 ~ / installed$/ { ok=1 }
  $1=="Version:" { v=$2 }
  END { if (ok && p!="") print p "\t" v }
' "$M/var/lib/dpkg/status" | grep -Ei 'apache|nginx|ssh|sudo|cron|mysql|maria|postfix|redis|php|postgres|ftp|samba|bind|dovecot|exim|sendmail|lighttp|nodejs|openbsd-inetd|xinetd|vsftpd|python|snmp' || true
echo "===== APACHE ====="
cat "$M/etc/apache2/ports.conf" 2>/dev/null || echo no-apache-ports
ls "$M/etc/apache2/sites-enabled" 2>/dev/null || true
echo "===== WEB ====="
ls -la "$M/var/www/html" 2>/dev/null || echo no-html
echo DONE_NEURO_DEEP
