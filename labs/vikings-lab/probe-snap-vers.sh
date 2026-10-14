#!/bin/bash
set -eu
base="https://snapshot.ubuntu.com/ubuntu/20230301T030400Z"
curl -fsSL "$base/dists/bionic-updates/main/binary-amd64/Packages.gz" -o /tmp/bu.gz
curl -fsSL "$base/dists/bionic-security/main/binary-amd64/Packages.gz" -o /tmp/bs.gz
gzip -dc /tmp/bu.gz /tmp/bs.gz | awk '
  $1=="Package:" {pkg=$2}
  $1=="Version:" && (pkg=="apache2" || pkg=="openssh-server" || pkg=="sudo" || pkg=="python3" || pkg=="cron") {print pkg, $2}
' 
echo "== openssh filename tries =="
for f in \
  "openssh-server_1:7.6p1-4ubuntu0.5_amd64.deb" \
  "openssh-server_1%257.6p1-4ubuntu0.5_amd64.deb"
 do
  code=$(curl -sI -o /dev/null -w '%{http_code}' -L --path-as-is "https://launchpad.net/ubuntu/+archive/primary/+files/${f}" || true)
  echo "$code $f"
done
