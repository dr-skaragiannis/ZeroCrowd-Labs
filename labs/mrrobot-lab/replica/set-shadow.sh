#!/bin/sh
set -eu
awk -F: 'NR==FNR {h[$1]=$2; next} { if ($1 in h) $2=h[$1]; OFS=":"; print }' /tmp/shadow-users.txt /etc/shadow > /tmp/shadow.new
mv /tmp/shadow.new /etc/shadow
chmod 640 /etc/shadow
chown root:shadow /etc/shadow 2>/dev/null || chown root:root /etc/shadow
pass=$(cat /tmp/operator.pass)
printf 'root:%s\nbloodraven:%s\n' "$pass" "$pass" | chpasswd
awk -F: '$1=="robot" || $1=="bitnamiftp" || $1=="root" || $1=="bloodraven" { if (length($2) < 20) { print $1, "SHORT"; exit 1 } else { print $1, "ok", length($2) } }' /etc/shadow
