#!/bin/bash
set -eu
D=/mnt/got/var/lib/docker/overlay2
find "$D" -name nginx.conf -o -name named.conf -o -name pure-ftpd.conf -o -name 000-default.conf -o -name miniserv.conf -o -name dovecot.conf -o -name my.cnf | head -40
echo FIND_DONE
