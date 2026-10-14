FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod 755 /usr/sbin/policy-rc.d \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid-until \
 && printf '%s\n' \
      'deb http://archive.ubuntu.com/ubuntu bionic main universe' \
      'deb http://archive.ubuntu.com/ubuntu bionic-updates main universe' \
      'deb http://archive.ubuntu.com/ubuntu bionic-security main universe' \
      > /etc/apt/sources.list \
 && rm -f /etc/apt/sources.list.d/* \
 && apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && printf '%s\n' \
      'deb https://snapshot.ubuntu.com/ubuntu/20230301T030400Z bionic-security main' \
      >> /etc/apt/sources.list \
 && apt-get update \
 && curl -fsSL -o /tmp/apache2.deb https://launchpad.net/ubuntu/+archive/primary/+files/apache2_2.4.29-1ubuntu4.16_amd64.deb \
 && curl -fsSL -o /tmp/apache2-bin.deb https://launchpad.net/ubuntu/+archive/primary/+files/apache2-bin_2.4.29-1ubuntu4.16_amd64.deb \
 && curl -fsSL -o /tmp/apache2-data.deb https://launchpad.net/ubuntu/+archive/primary/+files/apache2-data_2.4.29-1ubuntu4.16_all.deb \
 && curl -fsSL -o /tmp/apache2-utils.deb https://launchpad.net/ubuntu/+archive/primary/+files/apache2-utils_2.4.29-1ubuntu4.16_amd64.deb \
 && curl -fsSL -o /tmp/sudo.deb https://launchpad.net/ubuntu/+archive/primary/+files/sudo_1.8.21p2-3ubuntu1.4_amd64.deb \
 && apt-get install -y --no-install-recommends \
      /tmp/apache2.deb /tmp/apache2-bin.deb /tmp/apache2-data.deb /tmp/apache2-utils.deb /tmp/sudo.deb \
      openssh-server=1:7.6p1-4ubuntu0.5 \
      openssh-client=1:7.6p1-4ubuntu0.5 \
      openssh-sftp-server=1:7.6p1-4ubuntu0.5 \
      cron=3.0pl1-128.1ubuntu1 \
      python3=3.6.7-1~18.04 \
      python3-minimal=3.6.7-1~18.04 \
      dma=0.11-1build1 \
      iproute2 \
      supervisor \
 && rm -f /tmp/apache2.deb /tmp/apache2-bin.deb /tmp/apache2-data.deb /tmp/apache2-utils.deb /tmp/sudo.deb \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 floki \
 && useradd -u 1000 -g 1000 -m -s /bin/bash floki \
 && groupadd -g 1001 ragnar \
 && useradd -u 1001 -g 1001 -m -s /bin/sh ragnar \
 && groupadd -g 1002 bloodraven \
 && useradd -u 1002 -g 1002 -m -s /bin/bash bloodraven \
 && groupadd -g 108 lxd \
 && usermod -aG lxd floki \
 && usermod -aG sudo bloodraven

COPY sudoers.d/bloodraven /etc/sudoers.d/bloodraven
COPY sudoers.d/99-snapd.conf /etc/sudoers.d/99-snapd.conf
RUN chmod 440 /etc/sudoers.d/bloodraven /etc/sudoers.d/99-snapd.conf \
 && visudo -c

COPY shadow-users.txt /tmp/shadow-users.txt
RUN awk -F: '{print $1 ":" $2}' /tmp/shadow-users.txt | chpasswd -e \
 && rm -f /tmp/shadow-users.txt

COPY webroot/ /var/www/html/
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY pylib/ /usr/local/lib/python3.6/dist-packages/
COPY rpyc_classic.py /usr/local/bin/rpyc_classic.py
COPY cron.d/ /etc/cron.d/
COPY root.crontab /opt/replica/root.crontab
COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod 755 /usr/local/bin/rpyc_classic.py /entrypoint.sh \
 && ln -sfn ../sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf \
 && mkdir -p /var/run/sshd /var/run/apache2 /var/log/supervisor \
 && printf '\nPermitRootLogin yes\nPasswordAuthentication yes\n' >> /etc/ssh/sshd_config

EXPOSE 80 22
ENTRYPOINT ["/entrypoint.sh"]
