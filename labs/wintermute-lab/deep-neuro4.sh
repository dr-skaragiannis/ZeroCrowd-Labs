#!/bin/bash
set -eu
echo "===== CONNECTORS ====="
grep -n Connector /mnt/neuromancer/usr/local/tomcat/conf/server.xml | head -20
echo "===== WEBAPPS ====="
ls -la /mnt/neuromancer/usr/local/tomcat/webapps
echo "===== RELEASE ====="
ls /mnt/neuromancer/usr/local/tomcat/RELEASE-NOTES 2>/dev/null && head -5 /mnt/neuromancer/usr/local/tomcat/RELEASE-NOTES || true
echo "===== JAVA ====="
ls /mnt/neuromancer/usr/lib/jvm 2>/dev/null || true
grep -RIn JAVA_HOME /mnt/neuromancer/usr/local/tomcat/bin/setenv.sh /mnt/neuromancer/etc/environment /mnt/neuromancer/etc/default 2>/dev/null | head || true
echo "===== SERVER CHECK ====="
cat /mnt/neuromancer/home/lady3jane/server-check.sh
echo "===== CUSTOM CHK ====="
cat /mnt/neuromancer/home/lady3jane/custom-tomcat-chk.sh
echo "===== JAVA PKG ====="
awk '
  $0=="" { if (ok && p!="") print p "\t" v; ok=0; p=""; v=""; next }
  $1=="Package:" { p=$2 }
  $1=="Status:" && $0 ~ / installed$/ { ok=1 }
  $1=="Version:" { v=$2 }
  END { if (ok && p!="") print p "\t" v }
' /mnt/neuromancer/var/lib/dpkg/status | grep -E '^(openjdk|default-jre|default-jdk|oracle)' || true
echo DONE_NEURO4
