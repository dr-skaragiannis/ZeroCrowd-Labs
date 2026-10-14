#!/bin/bash
set -eu
M=/mnt/neuromancer
echo "===== SSH REST ====="
grep -nE 'Port|Listen|Password|Permit|UsePAM' "$M/etc/ssh/sshd_config" | grep -v '^[[:space:]]*#' || true
echo "===== TOMCAT UNIT ====="
find "$M" -name 'tomcat.service' 2>/dev/null
echo "===== TOMCAT HOME ====="
ls -d "$M"/opt/tomcat* "$M"/usr/share/tomcat* "$M"/var/lib/tomcat* 2>/dev/null || true
echo "===== SERVER XML PORTS ====="
grep -nE 'Connector|port=' "$M"/etc/tomcat*/server.xml "$M"/opt/tomcat*/conf/server.xml "$M"/usr/share/tomcat*/conf/server.xml 2>/dev/null | head -40 || true
echo "===== CRON ====="
ls "$M/etc/cron.d" "$M/var/spool/cron/crontabs" 2>/dev/null || true
echo "===== MAIL ====="
ls "$M/var/mail" 2>/dev/null || true
echo DONE_NEURO2
