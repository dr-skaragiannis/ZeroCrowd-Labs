#!/bin/bash
set -eu
D=/var/tmp/mrrobot-shadow
rm -rf "$D"
mkdir -p "$D"
cp /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica/Dockerfile.shadow "$D/Dockerfile"
cp /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica/set-shadow.sh "$D/set-shadow.sh"
cp /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica/shadow-users.txt "$D/shadow-users.txt"
cp /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica/operator.pass "$D/operator.pass"
sed -i 's/\r$//' "$D/Dockerfile" "$D/set-shadow.sh"
printf '%s\n' 'name: mrrobot-shadow-build' 'services:' '  mrrobot:' '    image: mrrobot-lab' '    build: .' > "$D/compose.yaml"
chmod 700 "$D"
cd "$D"
DOCKER_BUILDKIT=1 docker compose -f compose.yaml build
