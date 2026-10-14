#!/bin/bash
set -eu
command -v fsstat
for p in /dev/loop0p4 /dev/loop0p5 /dev/loop0p6 /dev/loop0p7 /dev/loop0p8; do
  echo "==== $p"
  fsstat "$p" 2>&1 | head -12 || true
done
echo TSK_DONE
