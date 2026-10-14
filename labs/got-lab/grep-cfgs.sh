#!/bin/bash
set -eu
D=/mnt/got/var/lib/docker/overlay2
echo "===== APACHE ====="
grep -nE 'VirtualHost|DocumentRoot|Listen|ServerName' \
  "$D/a17339b3a0edfb07b1dcac1098efbced52e0a52e2ae9857352dc973b63f3c867/diff/etc/apache2/sites-enabled/000-default.conf" \
  "$D/114fa97b923df4519114016621910960251ac6ceb65a7b5c459781231a85cbef/diff/etc/apache2/sites-enabled/000-default.conf" || true
echo "===== NGINX A ====="
grep -nE 'listen|root |server_name' "$D/ac08c9462ff3fe24e33926a2540211838105f28bf81c51cbf97bc77cd0838c28/diff/etc/nginx.conf" || true
echo "===== NGINX B ====="
grep -nE 'listen|root |server_name' "$D/55f0f585b66c3d796c427ee2256b5fb749474f6dbc15915e589dd9aed961504d/diff/etc/nginx/nginx.conf" || true
echo "===== BIND ====="
grep -nE 'listen-on|port ' "$D/572f8bb022e074941f169cd3fbe87363bc38acf633c2b580809c37aae7493921/diff/etc/bind/named.conf" | head
echo "===== DOVECOT ====="
grep -nE 'listen|protocol|port' "$D/afbf08433e37dc01057bba0121cb79189aa418134773326ca71e79fdaed84442/diff/etc/dovecot/dovecot.conf" | head
echo "===== WEBMIN ====="
grep -nE '^(port|listen|bind|host)=' "$D/b12fc6d5fd6df0b513d16f84bd334e4583f8b0ff762fbd4450bf8253b6838205/diff/etc/webmin/miniserv.conf" || true
echo "===== FTP ====="
grep -nE 'Bind|Port|Passive' "$D/c396d1dc793f0bfd29ef81049e00d164baa361b5e8fc1cec09990d47ba34bc9e/diff/etc/pure-ftpd.conf" | head
echo "===== MYSQL ====="
grep -nE 'bind-address|port' "$D/1839b59d2691ba1c6ea83cbe7d8b57f6000d1ae037ba13ffed375969300a42e0/diff/etc/mysql/my.cnf" | head
echo CFGS_DONE
