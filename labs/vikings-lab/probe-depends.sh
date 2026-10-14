#!/bin/bash
set -eu
mkdir -p /tmp/vkdebs
cd /tmp/vkdebs
base="https://launchpad.net/ubuntu/+archive/primary/+files"
for f in \
  apache2_2.4.29-1ubuntu4.16_amd64.deb \
  apache2-bin_2.4.29-1ubuntu4.16_amd64.deb \
  apache2-data_2.4.29-1ubuntu4.16_all.deb \
  apache2-utils_2.4.29-1ubuntu4.16_amd64.deb \
  sudo_1.8.21p2-3ubuntu1.4_amd64.deb
 do
  if [ ! -f "$f" ]; then
    curl -fsSL -o "$f" "$base/$f"
  fi
  echo "== $f"
  dpkg-deb -f "$f" Package Version Depends Pre-Depends
  echo
done
