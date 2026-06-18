#!/usr/bin/env python3
"""
Mantiene Render despierto: ping cada 5 min en horario laboral (lun-vie 07:00-20:00).
Ejecutar en segundo plano con pythonw (sin ventana).
"""
from __future__ import annotations

import time
import urllib.error
import urllib.request
from datetime import datetime

URL = "https://acr-dashboard-5iqz.onrender.com/api/health"
INTERVAL_SEC = 5 * 60
TIMEOUT = 120
LOG_PATH = None  # ruta opcional vía env ACR_KEEPALIVE_LOG


def _log_path() -> str | None:
    import os
    return os.environ.get("ACR_KEEPALIVE_LOG") or LOG_PATH


def en_horario_laboral() -> bool:
    now = datetime.now()
    if now.weekday() >= 5:  # sáb, dom
        return False
    return 7 <= now.hour < 20


def ping() -> bool:
    req = urllib.request.Request(URL, headers={"User-Agent": "ACR-Dashboard-KeepAlive/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
            ok = resp.status == 200
            msg = f"{datetime.now():%Y-%m-%d %H:%M:%S} HTTP {resp.status}\n"
            lp = _log_path()
            if lp:
                try:
                    with open(lp, "a", encoding="utf-8") as f:
                        f.write(msg)
                except OSError:
                    pass
            return ok
    except Exception as e:
        lp = _log_path()
        if lp:
            try:
                with open(lp, "a", encoding="utf-8") as f:
                    f.write(f"{datetime.now():%Y-%m-%d %H:%M:%S} ERROR {e}\n")
            except OSError:
                pass
        return False


def main() -> None:
    while True:
        if en_horario_laboral():
            ping()
        time.sleep(INTERVAL_SEC)


if __name__ == "__main__":
    main()
