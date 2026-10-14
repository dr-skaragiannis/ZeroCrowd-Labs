FROM centos:7.3.1611

COPY centos7.repo /etc/yum.repos.d/CentOS-Base.repo
RUN rm -f /etc/yum.repos.d/CentOS-CR.repo /etc/yum.repos.d/CentOS-Debuginfo.repo \
      /etc/yum.repos.d/CentOS-fasttrack.repo /etc/yum.repos.d/CentOS-Media.repo \
      /etc/yum.repos.d/CentOS-Sources.repo /etc/yum.repos.d/CentOS-Vault.repo \
 && yum install -y \
      httpd-2.4.6-45.el7.centos \
      php-5.4.16-42.el7 \
      openssh-server-6.6.1p1-33.el7_3 \
      cronie-1.4.11-14.el7_2.1 \
      postfix-2.10.1-6.el7 \
      vsftpd-3.0.2-21.el7 \
      chrony-2.1.1-4.el7.centos \
      sudo \
      firewalld-0.4.3.2-8.1.el7_3.2 \
 && yum clean all \
 && sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

COPY import/var/www/html/ /var/www/html/
COPY import/home/ /home/
COPY import/prison/ /prison/
COPY import/etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf
COPY raid-check /etc/cron.d/raid-check
COPY import/shadow.snippet /opt/moria/shadow.snippet
COPY entrypoint.sh /entrypoint.sh

RUN groupadd -g 1001 prison \
 && groupadd -g 1003 notBalrog \
 && groupadd -g 1004 bloodraven \
 && useradd -u 1000 -g 1003 -M -s /bin/bash abatchy \
 && useradd -u 1001 -g 1001 -M -d /prison -s /sbin/nologin Balrog \
 && useradd -u 1002 -g 1003 -M -s /bin/bash Ori \
 && useradd -u 1003 -g 1004 -G wheel -M -s /bin/bash bloodraven \
 && awk -F: '{print $1 ":" $2}' /opt/moria/shadow.snippet | chpasswd -e \
 && printf '%s\n' '*/3 * * * * /home/abatchy/knockknock.sh' | crontab - \
 && chown -R abatchy:notBalrog /home/abatchy \
 && chown -R Ori:notBalrog /home/Ori \
 && chown -R bloodraven:bloodraven /home/bloodraven \
 && chown -R Balrog:prison /prison \
 && chmod 755 /home/abatchy/knockknock.sh /entrypoint.sh \
 && chmod 644 /etc/cron.d/raid-check \
 && visudo -c \
 && sed -i 's/^listen=.*/listen=YES/' /etc/vsftpd/vsftpd.conf \
 && sed -i 's/^listen_ipv6=.*/listen_ipv6=NO/' /etc/vsftpd/vsftpd.conf \
 && sed -i 's/^background=.*/background=NO/' /etc/vsftpd/vsftpd.conf \
 && grep -q '^background=' /etc/vsftpd/vsftpd.conf || echo 'background=NO' >> /etc/vsftpd/vsftpd.conf

EXPOSE 80 22 21
ENTRYPOINT ["/entrypoint.sh"]
