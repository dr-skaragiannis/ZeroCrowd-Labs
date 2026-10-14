#!/bin/bash
set -eu
check() {
  code=$(curl -sI -o /dev/null -w '%{http_code}' -L "$1" || true)
  echo "$code $1"
}
echo "== snapshot dates =="
for d in 20230301T030400Z 20241013T000000Z 20251013T000000Z; do
  check "https://snapshot.ubuntu.com/ubuntu/${d}/dists/bionic-updates/Release"
done
echo "== launchpad =="
for f in \
  apache2_2.4.29-1ubuntu4.16_amd64.deb \
  apache2-bin_2.4.29-1ubuntu4.16_amd64.deb \
  apache2-data_2.4.29-1ubuntu4.16_all.deb \
  openssh-server_1%3a7.6p1-4ubuntu0.5_amd64.deb \
  openssh-client_1%3a7.6p1-4ubuntu0.5_amd64.deb \
  openssh-sftp-server_1%3a7.6p1-4ubuntu0.5_amd64.deb \
  sudo_1.8.21p2-3ubuntu1.4_amd64.deb
 do
  check "https://launchpad.net/ubuntu/+archive/primary/+files/${f}"
done
