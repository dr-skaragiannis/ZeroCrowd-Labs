#!/bin/bash
set -e
mkdir -p /var/run/sshd /run/httpd /var/run/vsftpd
ssh-keygen -A >/dev/null 2>&1 || true
newaliases >/dev/null 2>&1 || true
/usr/sbin/sshd -D &
/usr/sbin/httpd -D FOREGROUND &
/usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf &
/usr/sbin/crond -n &
/usr/sbin/chronyd -d -n &
/usr/libexec/postfix/master &
wait
