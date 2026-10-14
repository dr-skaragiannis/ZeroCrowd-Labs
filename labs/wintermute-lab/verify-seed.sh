#!/bin/bash
set -eu
awk -F: '$1=="bloodraven" || $1=="wintermute" || $1=="turing-police" || $1=="ta" || $1=="lady3jane" {print FILENAME, $1, $3, $4, $7}' /mnt/straylight/etc/passwd /mnt/neuromancer/etc/passwd
wc -l /mnt/c/Users/bloodraven/Projects/wintermute-lab/replica/straylight/shadow-users.txt /mnt/c/Users/bloodraven/Projects/wintermute-lab/replica/neuromancer/shadow-users.txt
echo JDK $(test -x /mnt/c/Users/bloodraven/Projects/wintermute-lab/replica/neuromancer/opt/jdk1.8.0_171/bin/java && echo ok)
echo TOMCAT $(test -f /mnt/c/Users/bloodraven/Projects/wintermute-lab/replica/neuromancer/opt/tomcat/bin/catalina.sh && echo ok)
echo WEB $(test -f /mnt/c/Users/bloodraven/Projects/wintermute-lab/replica/straylight/webroot/index.html && echo ok)
echo NTOP $(test -x /mnt/c/Users/bloodraven/Projects/wintermute-lab/replica/straylight/ntopng/ntopng && echo ok)
curl -fsSL --max-time 30 "https://snapshot.debian.org/package/apache2/2.4.25-3+deb9u4/" | grep -o 'https://snapshot.debian.org/archive/debian/[0-9T]*Z/' | head -3 || echo SNAP_FAIL
