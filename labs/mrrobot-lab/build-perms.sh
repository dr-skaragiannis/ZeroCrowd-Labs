#!/bin/bash
set -eu
D=/var/tmp/mrrobot-perms
rm -rf "$D"
mkdir -p "$D"
cp /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica/Dockerfile.perms "$D/Dockerfile"
sed -i 's/\r$//' "$D/Dockerfile"
printf '%s\n' 'name: mrrobot-perms-build' 'services:' '  mrrobot:' '    image: mrrobot-lab' '    build: .' > "$D/compose.yaml"
cd "$D"
DOCKER_BUILDKIT=1 docker compose -f compose.yaml build
cd /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica
docker compose -f compose.yaml up -d --no-build --force-recreate
sleep 12
docker exec mrrobot ss -lnt
echo '## HTTP'
curl -sk -o /dev/null -w 'http %{http_code}\n' http://10.88.10.18/
curl -sk -o /dev/null -w 'https %{http_code}\n' https://10.88.10.18/
echo '## CRON'
docker exec mrrobot grep agent.bin /etc/crontab
echo '## HOST3306'
ss -lnt | grep '10.88.10.18:3306' || echo '3306_not_published'
