#!/bin/bash
set +e
blkid /dev/dm-0 /dev/dm-1 /dev/dm-2
echo ---
file -s /dev/dm-1 /dev/dm-2
echo ---
dmsetup table
