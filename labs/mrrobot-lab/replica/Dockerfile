FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive

RUN rm -f /etc/apt/sources.list.d/* \
    && printf '%s\n' \
      'deb http://archive.ubuntu.com/ubuntu trusty main universe' \
      'deb http://archive.ubuntu.com/ubuntu trusty-updates main universe' \
      'deb http://security.ubuntu.com/ubuntu trusty-security main universe' \
      > /etc/apt/sources.list \
    && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive \
    && printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d \
    && chmod 755 /usr/sbin/policy-rc.d \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
         openssh-server cron sudo supervisor ca-certificates \
    && apt-get install -y --no-install-recommends vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY bitnami /opt/bitnami
COPY sudoers-replica /etc/sudoers.d/replica
COPY vsftpd.conf /etc/vsftpd.conf
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY set-shadow.sh /set-shadow.sh

RUN groupadd -g 1000 bitnamiftp \
    && groupadd -g 1001 mysql \
    && groupadd -g 1002 robot \
    && groupadd -g 1003 bloodraven \
    && (getent group admin >/dev/null || groupadd -g 107 admin || groupadd admin) \
    && ftp_shell=/bin/false \
    && if [ -x /bin/bitnami_ftp_false ]; then ftp_shell=/bin/bitnami_ftp_false; fi \
    && useradd -u 1000 -g 1000 -d /opt/bitnami/apps -s "$ftp_shell" bitnamiftp \
    && useradd -u 1001 -g 1001 -d /home/mysql -s /bin/false mysql \
    && useradd -u 1002 -g 1002 -d /home/robot -M -s /bin/sh robot \
    && useradd -u 1003 -g 1003 -G admin -m -d /home/bloodraven -s /bin/bash bloodraven \
    && mkdir -p /home/mysql /home/robot /var/run/sshd /var/lib/replica \
    && chown mysql:mysql /home/mysql \
    && chown robot:robot /home/robot \
    && chmod 440 /etc/sudoers.d/replica \
    && visudo -c \
    && chmod 755 /entrypoint.sh \
    && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin without-password/' /etc/ssh/sshd_config \
    && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && ssh-keygen -A \
    && mkdir -p /opt/bitnami/mysql/tmp /opt/bitnami/php/var/run /opt/bitnami/apache2/logs \
    && chown -R mysql:mysql /opt/bitnami/mysql/data /opt/bitnami/mysql/tmp \
    && chmod 644 /opt/bitnami/mysql/my.cnf \
    && grep -q 'agent.bin' /etc/crontab || printf '%s\n' '16 * * * * bitnami cd /opt/bitnami/stats && ./agent.bin --run -D' >> /etc/crontab \
    && chown daemon:daemon /opt/bitnami/php/var/run \
    && if ! grep -q 'innodb_buffer_pool_size' /opt/bitnami/mysql/my.cnf; then \
         printf '\ninnodb_buffer_pool_size=64M\nperformance_schema=OFF\n' >> /opt/bitnami/mysql/my.cnf; \
       fi \
    && touch /var/lib/replica/db.ready

RUN --mount=type=bind,source=shadow-users.txt,target=/tmp/shadow-users.txt \
    --mount=type=bind,source=operator.pass,target=/tmp/operator.pass \
    sh /set-shadow.sh

EXPOSE 22 80 443
ENTRYPOINT ["/entrypoint.sh"]
