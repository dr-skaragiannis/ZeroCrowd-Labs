#!/bin/bash
set -eu
rm -rf /mnt/c/Users/bloodraven/Projects/moria-lab/import
mkdir -p /mnt/c/Users/bloodraven/Projects/moria-lab/import
tar -C /mnt/c/Users/bloodraven/Projects/moria-lab/import -xzf /mnt/c/Users/bloodraven/Projects/moria-lab/import.tgz
find /mnt/c/Users/bloodraven/Projects/moria-lab/import -type f -printf '%p\n' | sed 's|.ssh/id_rsa$|.ssh/id_rsa REDACTED|' 
echo FILECOUNT
find /mnt/c/Users/bloodraven/Projects/moria-lab/import -type f | wc -l
# confirm private key was excluded
find /mnt/c/Users/bloodraven/Projects/moria-lab/import -name id_rsa -o -name shadow.snippet | wc -l
