#!/bin/bash
set -eu
ROOT=/dev/loop0p4
USR=/dev/loop0p7
echo "===== SCRIPTS ====="
fls "$ROOT" 25829
echo "===== HTDOCS ====="
fls "$ROOT" 77250
echo "===== PKG ====="
fls "$ROOT" 77201
echo "===== LOCAL ====="
fls "$USR" 77954
echo FIND3
