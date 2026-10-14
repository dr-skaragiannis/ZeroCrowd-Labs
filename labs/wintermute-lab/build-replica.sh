#!/bin/bash
set -eu
sed -i 's/\r$//' /mnt/c/Users/bloodraven/Projects/wintermute-lab/prep-host.sh
bash /mnt/c/Users/bloodraven/Projects/wintermute-lab/prep-host.sh
find /mnt/c/Users/bloodraven/Projects/wintermute-lab/replica -type f \( -name '*.sh' -o -name 'Dockerfile' -o -name '*.conf' -o -name '*.yaml' -o -name '*.crontab' \) -print0 | xargs -0 sed -i 's/\r$//'
docker info >/tmp/docker-info.txt
docker compose version
cd /mnt/c/Users/bloodraven/Projects/wintermute-lab/replica
docker compose -p wintermute-lab build
echo BUILD_DONE
