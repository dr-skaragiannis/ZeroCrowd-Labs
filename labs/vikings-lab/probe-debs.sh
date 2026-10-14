#!/bin/bash
set -eu
check() {
  url="$1"
  code=$(curl -sI -o /dev/null -w '%{http_code}' "$url" || true)
  echo "$code $url"
}
check "http://archive.ubuntu.com/ubuntu/pool/main/a/apache2/apache2_2.4.29-1ubuntu4.16_amd64.deb"
check "http://archive.ubuntu.com/ubuntu/pool/main/o/openssh/openssh-server_1%3a7.6p1-4ubuntu0.5_amd64.deb"
check "http://archive.ubuntu.com/ubuntu/pool/main/c/cron/cron_3.0pl1-128.1ubuntu1_amd64.deb"
check "http://archive.ubuntu.com/ubuntu/pool/main/s/sudo/sudo_1.8.21p2-3ubuntu1.4_amd64.deb"
check "http://archive.ubuntu.com/ubuntu/pool/main/p/python3.6/python3_3.6.7-1~18.04_amd64.deb"
check "http://archive.ubuntu.com/ubuntu/pool/universe/d/dma/dma_0.11-1build1_amd64.deb"
echo "== snapshot root =="
check "https://snapshot.ubuntu.com/"
check "https://snapshot.ubuntu.com/ubuntu/20210904T000000Z/dists/bionic-updates/Release"
check "http://snapshot.ubuntu.com/ubuntu/20210904T000000Z/dists/bionic-updates/Release"
