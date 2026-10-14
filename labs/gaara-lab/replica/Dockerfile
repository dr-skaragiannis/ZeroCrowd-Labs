FROM debian:10

RUN printf 'deb http://archive.debian.org/debian buster main\ndeb http://archive.debian.org/debian buster-updates main\ndeb http://archive.debian.org/debian-security buster/updates main\n' > /etc/apt/sources.list \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
      apache2 \
      openssh-server \
      cron \
      anacron \
      sudo \
      supervisor \
      curl \
      procps \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -u 1001 -s /bin/bash gaara \
 && useradd -m -u 1002 -G sudo -s /bin/bash bloodraven \
 && mkdir -p /var/run/sshd /seed

COPY html/ /var/www/html/
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY sudoers-replica /etc/sudoers.d/replica
COPY shadow-users.txt /seed/shadow-users.txt
COPY operator.pass /seed/operator.pass
COPY entrypoint.sh /entrypoint.sh

RUN chmod 755 /entrypoint.sh \
 && chmod 440 /etc/sudoers.d/replica \
 && chmod 600 /seed/shadow-users.txt /seed/operator.pass \
 && chown -R www-data:www-data /var/www/html

ENTRYPOINT ["/entrypoint.sh"]
