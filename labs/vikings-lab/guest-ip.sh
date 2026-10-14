#!/bin/sh
echo "=== IP ==="
hostname -I
echo "=== HTTP ==="
python3 - <<'PY'
import urllib.request
print(urllib.request.urlopen("http://127.0.0.1/", timeout=5).status)
PY
echo "=== ENDIP ==="
