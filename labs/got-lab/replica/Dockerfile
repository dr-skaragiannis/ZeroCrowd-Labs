FROM debian:9

RUN printf 'deb http://archive.debian.org/debian stretch main\ndeb http://archive.debian.org/debian-security stretch/updates main\n' > /etc/apt/sources.list \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      openssh-server \
      apache2 \
      nginx \
      bind9 \
      dovecot-imapd \
      mariadb-server \
      postgresql \
      pure-ftpd \
      cron \
      sudo \
      fail2ban \
      curl \
      procps \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -u 1000 -s /bin/bash daenerystargaryen \
 && useradd -m -u 1001 -s /bin/bash branstark \
 && useradd -m -u 1002 -G sudo -s /bin/bash bloodraven \
 && mkdir -p /var/run/sshd /seed /var/www/html2 /var/lib/replica

COPY nginx-1337.conf /etc/nginx/nginx-1337.conf
COPY nginx-10000.conf /etc/nginx/nginx-10000.conf
COPY winterfell.conf /etc/apache2/sites-enabled/winterfell.conf
COPY sudoers-replica /etc/sudoers.d/replica
COPY shadow-users.txt /seed/shadow-users.txt
COPY operator.pass /seed/operator.pass
COPY entrypoint.sh /entrypoint.sh

RUN chmod 755 /entrypoint.sh \
 && chmod 440 /etc/sudoers.d/replica \
 && chmod 600 /seed/shadow-users.txt /seed/operator.pass \
 && mkdir -p /var/www/gitlist /var/run/pure-ftpd \
 && printf '<html><body>winterfell</body></html>\n' > /var/www/html2/index.html

ENTRYPOINT ["/entrypoint.sh"]
