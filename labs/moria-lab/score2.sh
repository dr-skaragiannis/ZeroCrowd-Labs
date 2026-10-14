#!/bin/bash
set +e
echo ---CROND---
docker exec moria ls -l /etc/cron.d
echo ---WEB---
docker exec moria find /var/www/html -type f -printf "%s %p\n"
echo ---KEY---
docker exec moria bash -c "if [ -f /home/Ori/.ssh/id_rsa ]; then echo KEY_PRESENT; else echo KEY_ABSENT; fi"
echo ---SUDOTEST---
docker run --rm --entrypoint yum moria-lab install -y sudo firewalld-0.4.3.2-8.1.el7_3.2
