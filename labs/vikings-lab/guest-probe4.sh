#!/bin/sh
{
echo "=== CONTAINERD ==="
tr '\0' ' ' < /proc/1220/cmdline; echo
echo "=== CONTAINERD CONF ==="
ls -la /etc/containerd /etc/docker 2>/dev/null || true
if [ -f /etc/containerd/config.toml ]; then
  wc -c /etc/containerd/config.toml
fi
echo "=== POSTFIX ==="
dpkg-query -W -f='status=${db:Status-Status} pkg=${Package} ver=${Version}\n' postfix 2>&1 || true
echo "=== APACHE SITE ==="
grep -nE 'DocumentRoot|ServerName|Directory|Alias' /etc/apache2/sites-enabled/000-default.conf || true
echo "=== PY DIST ==="
du -sh /usr/local/lib/python3.6/dist-packages 2>/dev/null || true
ls /usr/local/lib/python3.6/dist-packages 2>/dev/null || true
echo "=== HTTP LOCAL ==="
python3 - <<'PY'
import urllib.request
for path in ("/", "/site/", "/site/index.html"):
    try:
        r = urllib.request.urlopen("http://127.0.0.1" + path, timeout=5)
        print(path, r.status, r.geturl())
    except Exception as exc:
        code = getattr(getattr(exc, "code", None), "real", None)
        if hasattr(exc, "code"):
            print(path, exc.code)
        else:
            print(path, type(exc).__name__)
PY
echo "=== ENDP4 ==="
} 
