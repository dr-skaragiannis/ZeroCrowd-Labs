#!/bin/bash
set -eu
for u in \
  http://old-releases.ubuntu.com/ubuntu/dists/trusty/Release \
  http://archive.ubuntu.com/ubuntu/dists/trusty/Release \
  http://old-releases.ubuntu.com/ubuntu/dists/trusty/main/binary-amd64/Packages.gz \
  http://security.ubuntu.com/ubuntu/dists/trusty-security/Release
 do
  code=$(curl -sI -o /dev/null -w '%{http_code}' "$u" || true)
  echo "$code $u"
done
