#!/bin/bash
set -eu
ls -l /dev/mapper /dev/cl 2>&1 || true
echo ---
lvdisplay
