#!/bin/bash
set -eu
python3 - <<'PY'
import re
text=open("/mnt/neuromancer/usr/local/tomcat/conf/server.xml").read()
# strip comments
text=re.sub(r"<!--.*?-->","",text,flags=re.S)
for line in text.splitlines():
    if "Connector" in line and "port=" in line:
        print(line.strip())
PY
echo "===== VERSION ====="
grep -m1 "Apache Tomcat Version" /mnt/neuromancer/usr/local/tomcat/RELEASE-NOTES || true
echo "===== DU ====="
du -sh /mnt/neuromancer/usr/local/tomcat /mnt/neuromancer/usr/lib/jvm/jdk1.8.0_171 /mnt/straylight/var/www /mnt/straylight/usr/local/bin/ntopng
echo "===== POSTFIX MASTER ====="
awk 'NF && $1 !~ /^#/ {print}' /mnt/straylight/etc/postfix/master.cf | head -20
echo "===== WWW UID ====="
awk -F: '$1=="www-data" || $1=="mysql" || $1=="redis" {print}' /mnt/straylight/etc/passwd
echo "===== NEURO GROUPS ====="
awk -F: '$1=="ta" || $1=="lady3jane" || $1=="sudo" {print}' /mnt/neuromancer/etc/group
echo FACTS_DONE
