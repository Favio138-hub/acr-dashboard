#!/usr/bin/env python3
"""Un ping al health check de Render (para Tarea programada de Windows)."""
from __future__ import annotations

import sys
import urllib.error
import urllib.request

URL = "https://acr-dashboard-5iqz.onrender.com/api/health"
TIMEOUT = 120


def main() -> int:
    req = urllib.request.Request(URL, headers={"User-Agent": "ACR-Dashboard-KeepAlive/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            body = resp.read(500).decode("utf-8", errors="replace")
            print(f"OK HTTP {resp.status} — {body[:120]}")
            return 0 if resp.status == 200 else 1
    except urllib.error.HTTPError as e:
        print(f"HTTP {e.code}")
        return 1
    except Exception as e:
        print(f"ERROR: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
