#!/bin/bash
set -eu
M=/mnt/mrrobot
if ! mountpoint -q "$M"; then
  mkdir -p "$M"
  mount /dev/loop0p1 "$M"
fi
OUT=/mnt/c/Users/bloodraven/Projects/mrrobot-lab/collect-out.txt
{
  echo '## OS'
  cat "$M/etc/os-release" 2>/dev/null || true
  echo
  uname -a || true
  echo 'KERNEL_FILE'
  ls "$M/boot"/vmlinuz* 2>/dev/null || true
  echo
  echo '## HOSTNAME'
  cat "$M/etc/hostname" 2>/dev/null || true
  echo
  echo '## PASSWD'
  awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1, $3, $4, $6, $7}' "$M/etc/passwd"
  echo '## SERVICE ACCOUNTS'
  awk -F: '$1 ~ /^(www-data|mysql|sshd|daemon)$/ {print $1, $3, $4, $6, $7}' "$M/etc/passwd"
  echo '## GROUPS'
  grep -E '^(sudo|wheel|admin|www-data|mysql):' "$M/etc/group" || true
  echo '## SHADOW KIND'
  awk -F: '{
    p=$2
    if (p ~ /^!/ || p ~ /^\*/) k="locked"
    else if (p ~ /^\$6\$/) k="sha512"
    else if (p ~ /^\$5\$/) k="sha256"
    else if (p ~ /^\$1\$/) k="md5"
    else if (p == "") k="empty"
    else k="other"
    print $1, k
  }' "$M/etc/shadow"
  echo '## SUDOERS'
  if [ -f "$M/etc/sudoers" ]; then
    grep -vE '^#|^$' "$M/etc/sudoers" || true
  fi
  echo '## SUDOERS.D'
  ls -la "$M/etc/sudoers.d" 2>/dev/null || true
  for f in "$M"/etc/sudoers.d/*; do
    [ -f "$f" ] || continue
    echo "-- $f"
    grep -vE '^#|^$' "$f" || true
  done
  echo '## DPKG'
  if [ -f "$M/var/lib/dpkg/status" ]; then
    awk '
      /^Package: / {p=$2}
      /^Status: / {s=$0}
      /^Version: / {v=$2}
      /^$/{
        if (p ~ /^(apache2|apache2-bin|openssh-server|openssh-client|mysql-server|mysql-server-5.5|mysql-server-5.6|mysql-server-core-5.5|mysql-server-core-5.6|mariadb-server|php5|php5-mysql|libapache2-mod-php5|cron|anacron|sudo|postfix|exim4|sendmail|bsd-mailx|vsftpd|pure-ftpd|bind9|nginx|wordpress)$/ && s ~ /install ok installed/)
          print p "\t" v
        p=s=v=""
      }
    ' "$M/var/lib/dpkg/status"
  fi
  echo '## LISTEN CONFIG'
  echo '-- ports.conf'
  [ -f "$M/etc/apache2/ports.conf" ] && grep -vE '^#|^$' "$M/etc/apache2/ports.conf" || true
  echo '-- sites'
  ls -la "$M/etc/apache2/sites-enabled" 2>/dev/null || true
  for f in "$M"/etc/apache2/sites-enabled/*; do
    [ -f "$f" ] || continue
    echo "-- $f"
    grep -vE '^[[:space:]]*#' "$f" || true
  done
  echo '-- sshd'
  if [ -f "$M/etc/ssh/sshd_config" ]; then
    grep -E '^(Port|ListenAddress|PermitRootLogin|PasswordAuthentication|PubkeyAuthentication)' "$M/etc/ssh/sshd_config" || true
  fi
  echo '-- mysql cnf bind'
  grep -RIn --include='*.cnf' -E 'bind-address|port|datadir|socket' "$M/etc/mysql" 2>/dev/null | head -n 80 || true
  echo '## INIT LINKS'
  ls "$M/etc/rc2.d" 2>/dev/null | head -n 200 || true
  echo '## WEB ROOTS'
  if [ -d "$M/var/www" ]; then
    find "$M/var/www" -maxdepth 3 -printf '%y %s %p\n' | head -n 200
  fi
  echo '## CRON'
  ls -la "$M/etc/crontab" "$M/etc/cron.d" "$M/etc/cron.daily" "$M/etc/cron.hourly" "$M/var/spool/cron" "$M/var/spool/cron/crontabs" 2>/dev/null || true
  echo '-- crontab'
  grep -vE '^#|^$' "$M/etc/crontab" 2>/dev/null || true
  echo '-- cron.d names'
  ls "$M/etc/cron.d" 2>/dev/null || true
  for f in "$M"/etc/cron.d/*; do
    [ -f "$f" ] || continue
    echo "-- $f"
    grep -vE '^#|^$' "$f" || true
  done
  echo '## MAIL'
  ls "$M/etc/postfix" >/dev/null 2>&1 && echo postfix_present || echo postfix_absent
  ls "$M/var/mail" 2>/dev/null | head || true
  echo '## SIZES'
  du -xhd1 "$M/var" "$M/home" "$M/opt" "$M/srv" "$M/usr/share" 2>/dev/null || true
  echo '## FSTAB'
  grep -vE '^#|^$' "$M/etc/fstab" || true
} > "$OUT"
echo WROTE
wc -l "$OUT"
