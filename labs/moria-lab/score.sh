#!/bin/bash
set +e
echo ---SS---
docker exec moria bash -c "command -v ss; ss -lntup 2>/dev/null || netstat -lntup 2>/dev/null || cat /proc/net/tcp /proc/net/tcp6" | head -n 80
echo ---RPM---
docker exec moria rpm -q httpd php php-cli openssh-server cronie postfix vsftpd chrony mariadb-server mysql-server
echo ---USERS---
docker exec moria awk -F: "(\$3==0 || \$3>=1000) {print \$1, \$3, \$4, \$6, \$7}" /etc/passwd
echo ---SUDO---
docker exec moria bash -c "grep -E 'ALL=' /etc/sudoers | grep -v '^#'"
echo ---GROUPS---
docker exec moria bash -c "id abatchy; id Ori; id Balrog; id bloodraven"
echo ---HTTP---
docker exec moria bash -c "httpd -S 2>&1 | head -n 20"
echo ---CRON---
docker exec moria crontab -l
echo ---PHP---
docker exec moria bash -c "httpd -M 2>/dev/null | grep -i php"
echo ---CURL---
curl -s -o /dev/null -w "HTTP:%{http_code}\n" http://127.0.0.1/
echo ---LOG---
docker logs moria 2>&1 | tail -n 30
