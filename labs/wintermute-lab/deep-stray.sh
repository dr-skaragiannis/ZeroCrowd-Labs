#!/bin/bash
set -eu
M=/mnt/straylight
echo "===== WANTED UNITS ====="
ls "$M/etc/systemd/system/multi-user.target.wants"
echo "===== UNIT FILES ====="
for s in bolo free fside apache2 mariadb postfix redis-server ntopng snmpd cron; do
  echo "--- $s ---"
  find "$M/etc/systemd" "$M/lib/systemd/system" -name "${s}.service" -o -name "${s}*.service" 2>/dev/null | head -5
done
echo "===== PKG HITS ====="
awk '
  $0=="" { if (ok && p!="") print p "\t" v; ok=0; p=""; v=""; next }
  $1=="Package:" { p=$2 }
  $1=="Status:" && $0 ~ / installed$/ { ok=1 }
  $1=="Version:" { v=$2 }
  END { if (ok && p!="") print p "\t" v }
' "$M/var/lib/dpkg/status" | grep -Ei 'apache|nginx|ssh|sudo|cron|mysql|maria|postfix|redis|ntop|snmp|php|postgres|bolo|ftp|samba|bind|dovecot|exim|sendmail|lighttp|nodejs|ruby' || true
echo "===== APACHE PORTS ====="
cat "$M/etc/apache2/ports.conf" 2>/dev/null || true
echo "===== SITES ====="
ls "$M/etc/apache2/sites-enabled" 2>/dev/null || true
echo "===== MARIADB BIND ====="
grep -RIn --include='*.cnf' -E 'bind-address|port|socket' "$M/etc/mysql" 2>/dev/null | head -40 || true
echo "===== POSTFIX ====="
grep -E '^(inet_interfaces|inet_protocols|mydestination|myhostname)' "$M/etc/postfix/main.cf" 2>/dev/null || true
echo "===== REDIS ====="
grep -E '^(bind|port|protected-mode)' "$M/etc/redis/redis.conf" 2>/dev/null || true
echo "===== SNMP ====="
grep -E '^(agentAddress|rocommunity|rwcommunity)' "$M/etc/snmp/snmpd.conf" 2>/dev/null || true
echo "===== NTOP ====="
ls "$M/etc/ntopng" 2>/dev/null || true
echo "===== CRON D ====="
ls "$M/etc/cron.d" 2>/dev/null || true
echo "===== SPOOL CRON ====="
ls -la "$M/var/spool/cron/crontabs" 2>/dev/null || true
echo DONE_DEEP
