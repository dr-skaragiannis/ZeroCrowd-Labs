#!/bin/bash
set -eu
mkdir -p /var/tmp/mrrobot-disk
cd /var/tmp/mrrobot-disk
if [ ! -f mrRobot-disk1.vmdk ]; then
  tar -xf /mnt/c/Users/bloodraven/Downloads/Temp/mrRobot.ova mrRobot-disk1.vmdk
fi
ls -lh mrRobot-disk1.vmdk
if [ ! -f disk.raw ]; then
  qemu-img convert -O raw mrRobot-disk1.vmdk disk.raw
fi
qemu-img info disk.raw
ls -lh disk.raw
