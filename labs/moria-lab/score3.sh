#!/bin/bash
set +e
sleep 2
echo ---PORTS---
docker exec moria awk "NR>1 {split(\$2,a,\":\"); print \"tcp\", a[1], strtonum(\"0x\" a[2]), \$4}" /proc/net/tcp /proc/net/tcp6
echo ---UDP---
docker exec moria awk "NR>1 {split(\$2,a,\":\"); print \"udp\", a[1], strtonum(\"0x\" a[2]), \$4}" /proc/net/udp /proc/net/udp6
echo ---RPM---
docker exec moria rpm -q httpd php php-cli openssh-server cronie postfix vsftpd chrony firewalld sudo
echo ---SUDO---
docker exec moria bash -c "grep -E '^root|^%wheel' /etc/sudoers; visudo -c"
echo ---CRON---
docker exec moria bash -c "ls /etc/cron.d; crontab -l"
echo ---CURL---
curl -s -o /dev/null -w "WSL:%{http_code}\n" http://127.0.0.1/
echo ---PUB---
docker port moria
echo ---KERN---
docker exec moria uname -r
echo ---LOG---
docker logs moria 2>&1 | grep -E "Fatal|error|chronyd" | tail -n 15
