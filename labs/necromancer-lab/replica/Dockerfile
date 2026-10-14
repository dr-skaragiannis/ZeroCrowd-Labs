FROM debian:11

RUN printf 'deb http://archive.debian.org/debian bullseye main\ndeb http://archive.debian.org/debian bullseye-updates main\ndeb http://archive.debian.org/debian-security bullseye-security main\n' > /etc/apt/sources.list \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-server \
      nginx \
      snmpd \
      cron \
      sudo \
      python2 \
      ksh \
      netcat-openbsd \
      athena-jot \
      supervisor \
      curl \
      iproute2 \
      procps \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/bin/python2 /usr/local/bin/python \
 && ln -sf /bin/nc /usr/bin/nc \
 && groupadd -g 1000 demonslayer \
 && groupadd -g 1001 bloodraven \
 && useradd -m -u 1000 -g 1000 -s /bin/ksh demonslayer \
 && useradd -m -u 1001 -g 1001 -s /bin/ksh bloodraven \
 && usermod -s /bin/ksh root \
 && mkdir -p /root/scripts /var/www/htdocs /seed /var/run/sshd

COPY htdocs/ /var/www/htdocs/
COPY scripts/listenu666.py scripts/netcatsend.sh scripts/broadcastmsg.txt scripts/flag1.sh scripts/root.cron /root/scripts/
COPY snmpd.conf /etc/snmp/snmpd.conf
COPY nginx-site.conf /etc/nginx/sites-enabled/default
COPY ifconfig-fmt /sbin/ifconfig
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY sudoers-replica /etc/sudoers.d/replica
COPY shadow-users.txt /seed/shadow-users.txt
COPY operator.pass /seed/operator.pass
COPY entrypoint.sh /entrypoint.sh

RUN chmod 755 /sbin/ifconfig /entrypoint.sh /root/scripts/netcatsend.sh /root/scripts/flag1.sh \
 && chmod 644 /root/scripts/listenu666.py /root/scripts/root.cron /etc/snmp/snmpd.conf \
 && chmod 440 /etc/sudoers.d/replica \
 && chmod 600 /seed/shadow-users.txt /seed/operator.pass /root/scripts/broadcastmsg.txt

ENTRYPOINT ["/entrypoint.sh"]
