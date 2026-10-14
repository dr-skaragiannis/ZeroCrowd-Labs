#!/bin/sh
set -eu
mkdir -p /var/run/sshd /var/log/supervisor /usr/local/tomcat/logs /usr/local/tomcat/temp
export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_171
export PATH="$JAVA_HOME/bin:$PATH"
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -A
fi
exec supervisord -n -c /etc/supervisor/supervisord.conf
