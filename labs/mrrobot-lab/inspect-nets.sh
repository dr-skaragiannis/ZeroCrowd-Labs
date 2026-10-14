#!/bin/bash
set -eu
for n in gaara-lab_lab got-lab_lab matrix-lab_matrix-net moria-lab_moria-net necromancer-lab_lab raven-lab_raven-net replica_vikings-net wintermute-lab_lab; do
  echo "== $n"
  docker network inspect "$n" --format '{{range .IPAM.Config}}{{.Subnet}} {{.Gateway}}{{end}}'
done
