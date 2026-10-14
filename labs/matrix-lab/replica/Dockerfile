FROM python:2.7.14

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod 755 /usr/sbin/policy-rc.d \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive \
 && printf '%s\n' \
      'deb [trusted=yes] http://archive.debian.org/debian jessie main' \
      'deb [trusted=yes] http://archive.debian.org/debian-security jessie/updates main' \
      > /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y --force-yes --no-install-recommends openssh-server sudo supervisor \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /bin/bash /bin/rbash

RUN getent group 100 >/dev/null || groupadd -g 100 users \
 && groupadd -g 1001 trinity \
 && useradd -u 1000 -g 100 -m -s /bin/rbash guest \
 && useradd -u 1001 -g 1001 -m -s /bin/bash trinity \
 && groupadd -g 1002 bloodraven \
 && useradd -u 1002 -g 1002 -m -s /bin/bash bloodraven \
 && usermod -aG wheel bloodraven || true

COPY sudoers.d/bloodraven /etc/sudoers.d/bloodraven
RUN chmod 440 /etc/sudoers.d/bloodraven && visudo -c

COPY shadow-users.txt /tmp/shadow-users.txt
RUN awk -F: '{print $1 ":" $2}' /tmp/shadow-users.txt | chpasswd -e \
 && rm -f /tmp/shadow-users.txt

COPY server/ /tmp/server/
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh \
 && mkdir -p /var/run/sshd /var/log/supervisor \
 && printf '\nPermitRootLogin yes\nPasswordAuthentication yes\n' >> /etc/ssh/sshd_config

EXPOSE 80 22 31337
ENTRYPOINT ["/entrypoint.sh"]
