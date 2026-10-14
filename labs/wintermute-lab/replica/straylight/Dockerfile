FROM debian:stretch

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive \
 && printf 'deb http://archive.debian.org/debian stretch main\ndeb http://archive.debian.org/debian-security stretch/updates main\n' > /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive
RUN echo 'postfix postfix/mailname string straylight' | debconf-set-selections \
 && echo 'postfix postfix/main_mailer_type select Internet Site' | debconf-set-selections \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      apache2 libapache2-mod-php7.0 php7.0 \
      mariadb-server redis-server snmpd postfix cron sudo screen supervisor curl \
 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
 && apt-get install -y --no-install-recommends libpcap0.8 librrd8 libhiredis0.13 libmariadb2 libgeoip1 \
 && rm -rf /var/lib/apt/lists/*

RUN getent group wintermute || groupadd -g 1000 wintermute \
 && getent group turing-police || groupadd -g 1001 turing-police \
 && id wintermute || useradd -u 1000 -g 1000 -m -s /bin/bash wintermute \
 && id turing-police || useradd -u 1001 -g 1001 -m -s /bin/bash turing-police \
 && getent group bloodraven || groupadd -g 1002 bloodraven \
 && id bloodraven || useradd -u 1002 -g 1002 -G sudo -m -s /bin/bash bloodraven

COPY bloodraven /etc/sudoers.d/bloodraven
RUN chmod 440 /etc/sudoers.d/bloodraven && visudo -c

COPY shadow-users.txt /tmp/shadow-users.txt
RUN awk -F: '{print $1 ":" $2}' /tmp/shadow-users.txt | chpasswd -e && rm -f /tmp/shadow-users.txt

COPY webroot/ /var/www/html/
RUN chown -R www-data:www-data /var/www/html

COPY scripts/ /root/scripts/
COPY ntopng/ntopng /usr/local/bin/ntopng
COPY ntopng/ntopng.conf /etc/ntopng/ntopng.conf
COPY ntopng-share/ntopng/ /usr/local/share/ntopng/
RUN chmod 755 /usr/local/bin/ntopng /root/scripts/* \
 && sed -i 's/enp0s8/eth0/; s/enp0s3/eth0/' /etc/ntopng/ntopng.conf \
 && printf 'agentAddress udp:127.0.0.1:161\n' > /etc/snmp/snmpd.conf \
 && postconf -e inet_interfaces=all myhostname=straylight

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 80 3000 25
ENTRYPOINT ["/entrypoint.sh"]
