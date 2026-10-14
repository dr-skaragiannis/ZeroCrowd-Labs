FROM ubuntu:16.04

RUN printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d \
 && printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive \
 && printf 'deb http://archive.ubuntu.com/ubuntu xenial main universe\ndeb http://archive.ubuntu.com/ubuntu xenial-updates main universe\ndeb http://security.ubuntu.com/ubuntu xenial-security main universe\n' > /etc/apt/sources.list

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-server sudo cron supervisor ca-certificates \
 && rm -rf /var/lib/apt/lists/*

RUN getent group ta || groupadd -g 1000 ta \
 && getent group lady3jane || groupadd -g 1001 lady3jane \
 && id ta || useradd -u 1000 -g 1000 -m -s /bin/bash ta \
 && id lady3jane || useradd -u 1001 -g 1001 -m -s /bin/bash lady3jane \
 && getent group bloodraven || groupadd -g 1002 bloodraven \
 && id bloodraven || useradd -u 1002 -g 1002 -G sudo -m -s /bin/bash bloodraven

COPY bloodraven /etc/sudoers.d/bloodraven
RUN chmod 440 /etc/sudoers.d/bloodraven && visudo -c

COPY shadow-users.txt /tmp/shadow-users.txt
RUN awk -F: '{print $1 ":" $2}' /tmp/shadow-users.txt | chpasswd -e && rm -f /tmp/shadow-users.txt

COPY opt/jdk1.8.0_171/ /usr/lib/jvm/jdk1.8.0_171/
COPY opt/tomcat/ /usr/local/tomcat/
COPY home-lady3jane/ /home/lady3jane/
RUN chown -R 1000:1000 /usr/local/tomcat /usr/lib/jvm/jdk1.8.0_171 \
 && chown -R 1001:1001 /home/lady3jane \
 && printf '\nPort 34483\nPermitRootLogin prohibit-password\nPasswordAuthentication yes\n' >> /etc/ssh/sshd_config \
 && sed -i 's/^Port 22/#Port 22/' /etc/ssh/sshd_config \
 && printf 'JAVA_HOME=/usr/lib/jvm/jdk1.8.0_171\n' > /etc/environment
COPY root.crontab /tmp/root.crontab
RUN crontab -u root /tmp/root.crontab && rm -f /tmp/root.crontab

COPY supervisord.conf /etc/supervisor/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/tomcat/bin/*.sh
EXPOSE 34483 8080 8009
ENTRYPOINT ["/entrypoint.sh"]
