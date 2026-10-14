#!/bin/bash
{
echo '=== CMDLINE ==='
tr '\0' ' ' < /proc/1232/cmdline; echo
ls -l /proc/1232/cwd /proc/1232/exe 2>/dev/null || true
echo '=== APACHE CONF ==='
grep -E 'DocumentRoot|ServerName|ServerAlias|Directory' /etc/apache2/sites-enabled/000-default.conf
echo '=== WEB TOP ==='
find /var/www/html -maxdepth 2 -printf '%y %p\n' | head -80
echo '=== CRON ROOT ==='
crontab -u root -l 2>/dev/null | sed -E 's/(pass(word)?|secret|flag)[^ ]*/<redacted>/Ig'
echo '=== CRON FLOKI ==='
crontab -u floki -l 2>/dev/null | sed -E 's/(pass(word)?|secret|flag)[^ ]*/<redacted>/Ig'
echo '=== DMA ==='
dpkg-query -W -f '${Package} ${Version}\n' dma postfix 2>/dev/null || true
echo '=== DU ==='
du -xhd1 /var /home /opt /srv 2>/dev/null | head -40
echo '=== ENDINV2 ==='
} > /root/inv2.txt 2>&1
echo WROTE_INV2
