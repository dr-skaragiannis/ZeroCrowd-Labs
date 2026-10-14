#!/bin/bash
set -eu
M=/mnt/mrrobot
OUT=/mnt/c/Users/bloodraven/Projects/mrrobot-lab/collect2-out.txt
{
  echo '## PASSWD LINES'
  awk -F: '{print $1, $3, $4, $5, $6, $7}' "$M/etc/passwd"
  echo '## BITNAMI TOP'
  ls -la "$M/opt/bitnami" | awk '{print $1, $3, $4, $5, $9}'
  echo '## PROPERTIES'
  if [ -f "$M/opt/bitnami/properties.ini" ]; then
    sed -E 's/(password|pass|secret|key)[^=]*=.*/\1=<redacted>/I' "$M/opt/bitnami/properties.ini"
  fi
  echo '## HTTPD LISTEN'
  grep -RIn --include='*.conf' -E '^[#[:space:]]*(Listen|ServerName|DocumentRoot|VirtualHost|ProxyPass|jkMount)' "$M/opt/bitnami/apache2/conf" 2>/dev/null | head -n 120 || true
  echo '## MYSQL BIND'
  grep -RIn --include='*.cnf' -E 'bind-address|port|datadir|socket|skip-networking' "$M/opt/bitnami/mysql" 2>/dev/null | head -n 40 || true
  echo '## VSFTPD'
  if [ -f "$M/etc/vsftpd.conf" ]; then
    grep -E '^(listen|listen_ipv6|anonymous_enable|local_enable|write_enable|pasv_|port_|ftpd_banner)' "$M/etc/vsftpd.conf" || true
  else
    echo 'no /etc/vsftpd.conf'
    find "$M" -name 'vsftpd.conf' -o -name 'vsftpd' -type f 2>/dev/null | head
  fi
  echo '## VARNISH'
  ls "$M/opt/bitnami/varnish" 2>/dev/null | head || echo none
  echo '## MONIT'
  grep -RIn -E 'check |port |protocol' "$M/etc/monit" 2>/dev/null | head -n 40 || true
  echo '## WP CONFIG PATHS'
  find "$M/opt/bitnami" -name 'wp-config.php' -o -name 'httpd.conf' -o -name 'bitnami.conf' 2>/dev/null | head -n 40
  echo '## VERSIONS'
  "$M/opt/bitnami/apache2/bin/httpd" -v 2>/dev/null || true
  "$M/opt/bitnami/php/bin/php" -v 2>/dev/null | head -n 2 || true
  "$M/opt/bitnami/mysql/bin/mysqld" --version 2>/dev/null || true
  echo '## SSH DEFAULTS'
  grep -nE 'PasswordAuthentication|UsePAM|AllowUsers|AllowTcpForwarding' "$M/etc/ssh/sshd_config" || true
  echo '## RC LOCAL'
  grep -vE '^#|^$' "$M/etc/rc.local" 2>/dev/null || true
  echo '## BITNAMI CTL'
  ls "$M/opt/bitnami/ctlscript.sh" "$M/opt/bitnami"/*.sh 2>/dev/null || true
} > "$OUT"
echo WROTE
wc -l "$OUT"
