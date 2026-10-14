#!/usr/bin/env python3
import socket
targets = ["10.0.2.1", "172.22.224.1", "192.168.10.196", "10.0.0.1", "192.168.234.1"]
for host in targets:
    try:
        conn = socket.create_connection((host, 19191), 3)
        conn.sendall(b"PING")
        conn.close()
        print("REACHED", host)
        break
    except Exception as exc:
        print("FAIL", host, type(exc).__name__)
print("DONE_REACH")
