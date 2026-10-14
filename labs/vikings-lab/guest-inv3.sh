#!/bin/sh
{
echo "=== OS ==="
. /etc/os-release
printf '%s %s %s\n' "$ID" "$VERSION_ID" "$VERSION_CODENAME"
uname -r
echo "=== LISTEN ==="
ss -lntup || netstat -lntup
echo "=== CMDLINES ==="
ss -lntup | awk 'NR>1 {print $NF}' | sed 's/.*"\([^"]*\)".*/\1/' | sort -u | while read -r pid; do
  case "$pid" in
    ''|*[!0-9]*) continue ;;
  esac
  if [ -r "/proc/$pid/cmdline" ]; then
    printf 'pid %s ' "$pid"
    tr '\0' ' ' < "/proc/$pid/cmdline"
    echo
  fi
done
echo "=== PASSWD ==="
awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1, $3, $4, $6, $7}' /etc/passwd
echo "=== GROUPS ==="
getent group sudo wheel lxd www-data docker
echo "=== SUDOERS ==="
grep -vE '^#|^$' /etc/sudoers || true
echo "--- dropins ---"
for f in /etc/sudoers.d/*; do
  [ -f "$f" ] || continue
  echo "## $f"
  grep -vE '^#|^$' "$f" || true
done
echo "=== PKGS ==="
for p in apache2 apache2-bin apache2-data openssh-server cron sudo python3 python3-minimal rpyc python3-rpyc dma postfix containerd docker.io rsyslog ufw supervisor systemd; do
  dpkg-query -W -f='${Package}\t${Version}\n' "$p" 2>/dev/null || echo "ABSENT $p"
done
echo "=== RPYC ==="
dpkg -S /usr/local/bin/rpyc_classic.py 2>/dev/null || true
ls -l /usr/local/bin/rpyc_classic.py 2>/dev/null || true
python3 -c 'import rpyc; print(rpyc.__version__); print(rpyc.__file__)' 2>/dev/null || echo "NO_RPYC_MODULE"
echo "=== APACHE ==="
apachectl -S 2>&1 || true
echo "=== WEB ==="
find /var/www -maxdepth 4 \( -type d -o -type f \) -printf '%y %s %p\n' | sort
echo "=== CRON ==="
ls -la /etc/crontab /etc/cron.d /var/spool/cron/crontabs 2>/dev/null || true
for f in /etc/crontab /etc/cron.d/*; do
  [ -f "$f" ] || continue
  echo "## $f"
  sed -E 's/[A-Za-z0-9+/=]{24,}/<redacted>/g' "$f"
done
echo "## root crontab"
crontab -u root -l 2>/dev/null | sed -E 's/[A-Za-z0-9+/=]{24,}/<redacted>/g' || true
echo "## floki crontab"
crontab -u floki -l 2>/dev/null | sed -E 's/[A-Za-z0-9+/=]{24,}/<redacted>/g' || true
echo "## ragnar crontab"
crontab -u ragnar -l 2>/dev/null | sed -E 's/[A-Za-z0-9+/=]{24,}/<redacted>/g' || true
echo "=== MAIL ==="
ss -lnt | grep -E ':25|:587' || echo "no 25/587"
ls -la /var/mail /var/spool/mail 2>/dev/null || true
echo "=== SIZES ==="
du -xhd1 /var /home /opt /srv 2>/dev/null || true
echo "=== ENDINV3 ==="
} > /root/inv3.txt 2>&1

awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1}' /etc/passwd > /root/human-users.txt
: > /root/shadow-users.txt
while read -r u; do
  grep "^${u}:" /etc/shadow >> /root/shadow-users.txt
done < /root/human-users.txt
chmod 600 /root/shadow-users.txt

tar -C /var/www/html -cf /root/web.tar .
cp -a /usr/local/bin/rpyc_classic.py /root/rpyc_classic.py
python3 - <<'PY'
import os, tarfile
try:
    import rpyc
except Exception as exc:
    open("/root/rpyc-note.txt","w").write("import failed: %s\n" % exc)
    raise SystemExit(0)
root = os.path.dirname(rpyc.__file__)
open("/root/rpyc-note.txt","w").write(root + "\n")
with tarfile.open("/root/rpyc.tar","w") as tar:
    tar.add(root, arcname="rpyc")
PY
echo "WROTE_INV3"
wc -c /root/inv3.txt /root/web.tar /root/shadow-users.txt /root/rpyc.tar /root/rpyc_classic.py
