#!/bin/bash
set -eu
M=/mnt/mrrobot
OUT=/mnt/c/Users/bloodraven/Projects/mrrobot-lab/collect3-out.txt
{
  echo '## HTTPD INCLUDES'
  grep -nE '^[[:space:]]*Include' "$M/opt/bitnami/apache2/conf/httpd.conf" || true
  echo '## BITNAMI CONF'
  cat "$M/opt/bitnami/apache2/conf/bitnami/bitnami.conf"
  echo '## WORDPRESS APP CONF'
  find "$M/opt/bitnami/apps" -name '*.conf' | head -n 40
  echo '## WP FIELDS'
  python3 - <<'PY'
import re
p="/mnt/mrrobot/opt/bitnami/apps/wordpress/htdocs/wp-config.php"
text=open(p, errors="replace").read()
keys=("DB_NAME","DB_USER","DB_HOST","DB_PASSWORD","table_prefix")
for k in keys:
    m=re.search(r"define\(\s*'"+k+r"'\s*,\s*'([^']*)'\s*\)", text)
    if not m:
        print(k, "MISSING")
        continue
    val=m.group(1)
    if k=="DB_PASSWORD":
        print(k, "<redacted>")
    else:
        print(k, val)
PY
  echo '## HTDOCS TOP'
  find "$M/opt/bitnami/apache2/htdocs" -maxdepth 2 -printf '%y %s %P\n' | head -n 80
  echo '## WP TOP'
  find "$M/opt/bitnami/apps/wordpress/htdocs" -maxdepth 1 -printf '%y %s %f\n' | head -n 40
  echo '## MONIT HTTPD'
  grep -nE 'set httpd|use address|allow |port ' "$M/etc/monit/monitrc" 2>/dev/null | head -n 40 || true
  echo '## MONIT ENABLED'
  ls "$M/etc/monit/monitrc.d" | head
  echo '## VARNISH PORT'
  grep -RIn --include='*.vcl' -E '^\s*\.(port|host)' "$M/opt/bitnami/varnish" 2>/dev/null | head -n 20 || true
  grep -nE 'varnish|6081|DAEMON' "$M/opt/bitnami/ctlscript.sh" | head -n 30 || true
  echo '## VSFTPD INIT'
  ls "$M/etc/rc2.d" | grep -i ftp || echo 'ftp not in rc2'
  ls "$M/etc/init.d/vsftpd" 2>/dev/null || echo 'no vsftpd init'
  echo '## IMAGES'
  find "$M/opt/bitnami/apps/wordpress/htdocs" "$M/opt/bitnami/apache2/htdocs" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.gif' -o -iname '*.webp' -o -iname '*.svg' -o -iname '*.ico' \) -printf '%s %p\n' | head -n 80
  echo '## SITEURL SQL HINT'
  python3 - <<'PY'
import os
root="/mnt/mrrobot/opt/bitnami/mysql/data"
print("datadir_exists", os.path.isdir(root))
if os.path.isdir(root):
    print("schemas", ",".join(sorted(os.listdir(root))[:40]))
PY
} > "$OUT"
echo WROTE
wc -l "$OUT"
