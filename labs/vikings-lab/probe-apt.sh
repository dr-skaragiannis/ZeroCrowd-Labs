#!/bin/bash
set -eu
urls="
http://archive.ubuntu.com/ubuntu/dists/bionic/Release
http://archive.ubuntu.com/ubuntu/dists/bionic-updates/Release
http://archive.ubuntu.com/ubuntu/dists/bionic-security/Release
http://security.ubuntu.com/ubuntu/dists/bionic-security/Release
"
for u in $urls; do
  echo "== $u"
  curl -fsSL "$u" | awk '/^(Origin|Suite|Codename|Date|Valid-Until|Architectures):/'
  echo
done
echo "== apache pool"
curl -fsSL -o /tmp/bionic-updates.gz http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/binary-amd64/Packages.gz || echo UPDATES_FAIL
if [ -f /tmp/bionic-updates.gz ]; then
  gzip -dc /tmp/bionic-updates.gz | awk '
    $0=="Package: apache2" {p=1}
    p && $0=="" {exit}
    p {print}
  '
fi
