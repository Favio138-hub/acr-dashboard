"""
Arranque del dashboard: instala dependencias, inicia uvicorn y abre el navegador
solo cuando http://127.0.0.1:8000/api/health responde.
Ejecutar desde la carpeta del proyecto:  python run_server.py
"""
from __future__ import annotations

import os
import subprocess
import sys
import threading
import time
import webbrowser
from pathlib import Path
from urllib.error import URLError
from urllib.request import urlopen

ROOT = Path(__file__).resolve().parent
BACKEND = ROOT / "backend_python"
VENV_PY = ROOT / ".venv" / "Scripts" / "python.exe"
REQ = BACKEND / "requirements.txt"
LOG = ROOT / "server_log.txt"
HOST = "127.0.0.1"
PORT = 8000
URL = f"http://{HOST}:{PORT}"


def log(msg: str) -> None:
    line = f"[{time.strftime('%H:%M:%S')}] {msg}"
    print(line, flush=True)
    with open(LOG, "a", encoding="utf-8") as f:
        f.write(line + "\n")


def python_exe() -> Path:
    if VENV_PY.exists():
        return VENV_PY
    return Path(sys.executable)


def ensure_venv() -> Path:
    py = python_exe()
    if VENV_PY.exists():
        return py
    log("Creando entorno virtual .venv ...")
    for cmd in (["py", "-3", "-m", "venv", str(ROOT / ".venv")], [sys.executable, "-m", "venv", str(ROOT / ".venv")]):
        try:
            subprocess.run(cmd, cwd=str(ROOT), check=True, capture_output=True)
            if VENV_PY.exists():
                return VENV_PY
        except (subprocess.CalledProcessError, FileNotFoundError):
            continue
    log("ERROR: No se pudo crear .venv. Instale Python 3.11+ y marque Add to PATH.")
    sys.exit(1)


def install_deps(py: Path) -> None:
    log("Instalando dependencias (solo lo necesario para el servidor)...")
    r = subprocess.run(
        [str(py), "-m", "pip", "install", "-q", "-r", str(REQ)],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
    )
    if r.returncode != 0:
        log("pip fallo:")
        if r.stderr:
            log(r.stderr.strip()[:2000])
        sys.exit(1)


def wait_ready(timeout: int = 120) -> bool:
    health = f"{URL}/api/health"
    log(f"Esperando servidor en {health} ...")
    deadline = time.time() + timeout
    while time.time() < deadline:
        try:
            with urlopen(health, timeout=2) as resp:
                if resp.status == 200:
                    return True
        except (URLError, OSError, TimeoutError):
            pass
        time.sleep(0.5)
    return False


def open_browser_when_ready() -> None:
    if wait_ready():
        log(f"Abriendo navegador: {URL}")
        webbrowser.open(URL)
    else:
        log("El servidor no respondio a tiempo. Abra manualmente: " + URL)


def port_in_use() -> bool:
    import socket

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex((HOST, PORT)) == 0


def main() -> None:
    if LOG.exists():
        LOG.unlink()
    os.chdir(ROOT)
    log("Dashboard ACR — inicio")
    log(f"Carpeta: {ROOT}")

    if port_in_use():
        log(f"AVISO: el puerto {PORT} ya esta en uso. Cierre otras ventanas del dashboard o reinicie el PC.")

    py = ensure_venv()
    install_deps(py)

    os.chdir(BACKEND)
    env = {**os.environ, "PYTHONUNBUFFERED": "1"}

    threading.Thread(target=open_browser_when_ready, daemon=True).start()

    log("Iniciando servidor (no cierre esta ventana)...")
    try:
        subprocess.run(
            [str(py), "-m", "uvicorn", "main:app", "--host", HOST, "--port", str(PORT)],
            cwd=str(BACKEND),
            env=env,
        )
    except KeyboardInterrupt:
        log("Servidor detenido.")
    log("Fin.")


if __name__ == "__main__":
    main()
