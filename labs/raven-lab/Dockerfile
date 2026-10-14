FROM debian:jessie

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d \
 && chmod +x /usr/sbin/policy-rc.d \
 && { for d in 20180626T192607Z 20180420T083935Z 20180403T155817Z 20171120T033452Z 20170909T035115Z 20150611T102714Z; do \
      printf 'deb [trusted=yes] http://snapshot.debian.org/archive/debian/%s/ jessie main\n' "$d"; \
      printf 'deb [trusted=yes] http://snapshot.debian.org/archive/debian-security/%s/ jessie/updates main\n' "$d"; \
    done; \
    printf '%s\n' 'deb [trusted=yes] http://archive.debian.org/debian jessie main' 'deb [trusted=yes] http://archive.debian.org/debian-security jessie/updates main'; \
  } > /etc/apt/sources.list \
 && printf '%s\n' 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99archive \
 && printf '%s\n' 'mysql-server mysql-server/root_password password unused' 'mysql-server mysql-server/root_password_again password unused' | debconf-set-selections \
 && apt-get update \
 && printf '%s\n' \
      'Package: apache2 apache2-bin apache2-data apache2-utils' \
      'Pin: version 2.4.10-10+deb8u12' \
      'Pin-Priority: 1001' \
      '' \
      'Package: php5 php5-common php5-cli libapache2-mod-php5 php5-mysql' \
      'Pin: version 5.6.36+dfsg-0+deb8u1' \
      'Pin-Priority: 1001' \
      '' \
      'Package: mysql-server mysql-server-5.5 mysql-server-core-5.5 mysql-client mysql-client-5.5 libmysqlclient18' \
      'Pin: version 5.5.60-0+deb8u1' \
      'Pin-Priority: 1001' \
      '' \
      'Package: openssh-server openssh-client openssh-sftp-server' \
      'Pin: version 1:6.7p1-5+deb8u4' \
      'Pin-Priority: 1001' \
      '' \
      'Package: sudo' \
      'Pin: version 1.8.10p3-1+deb8u5' \
      'Pin-Priority: 1001' \
      '' \
      'Package: cron' \
      'Pin: version 3.0pl1-127+deb8u1' \
      'Pin-Priority: 1001' \
      '' \
      'Package: sendmail sendmail-base sendmail-bin sendmail-cf sensible-mda' \
      'Pin: version 8.14.4-8+deb8u2' \
      'Pin-Priority: 1001' \
      > /etc/apt/preferences.d/guest-revisions \
 && apt-get install -y --no-install-recommends \
        apache2 \
        php5 \
        libapache2-mod-php5 \
        php5-mysql \
        mysql-server \
        openssh-server \
        python \
        sudo \
        supervisor \
        sendmail \
        cron \
        rpcbind \
        nfs-common \
        ca-certificates \
 && rm -f /usr/sbin/policy-rc.d \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/run/sshd /var/run/mysqld /var/lock/apache2 /opt/raven /var/www/html \
 && chown mysql:mysql /var/run/mysqld \
 && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && echo 'ServerName raven.local' > /etc/apache2/conf-available/servername.conf \
 && a2enconf servername \
 && a2enmod php5

COPY import/var/www/html/ /var/www/html/
COPY import/var/www/flag2.txt /var/www/flag2.txt
COPY import/wordpress.sql /opt/raven/wordpress.sql
COPY import/shadow.snippet /opt/raven/shadow.snippet
COPY supervisord.conf /etc/supervisor/conf.d/raven.conf
COPY mysql-min.cnf /etc/mysql/conf.d/99-small.cnf
COPY mysql-socket.ini /etc/php5/apache2/conf.d/99-mysql-socket.ini
COPY mysql-socket.ini /etc/php5/cli/conf.d/99-mysql-socket.ini
COPY entrypoint.sh /entrypoint.sh

RUN useradd -m -u 1000 -s /bin/bash michael \
 && useradd -m -u 1001 -s /bin/sh steven \
 && useradd -m -u 1002 -s /bin/bash -G sudo bloodraven \
 && awk -F: '{print $1 ":" $2}' /opt/raven/shadow.snippet | chpasswd -e \
 && printf '%s\n' \
        'steven ALL=(ALL) NOPASSWD: /usr/bin/python' \
        'bloodraven ALL=(ALL:ALL) ALL' >> /etc/sudoers \
 && chown -R www-data:www-data /var/www/html \
 && chmod 644 /etc/mysql/conf.d/99-small.cnf \
 && chmod 755 /entrypoint.sh \
 && visudo -c \
 && rm -rf /var/lib/mysql/*

EXPOSE 80 22
ENTRYPOINT ["/entrypoint.sh"]
