"""
Puente R → Python para archivos .rds espaciales (sf).
pyreadr no lee objetos sf; usamos Rscript + cache CSV.
"""
from __future__ import annotations

import logging
import os
import shutil
import subprocess
from pathlib import Path

import pandas as pd

from core.config import PROJECT_ROOT

logger = logging.getLogger(__name__)

CACHE_CSV = PROJECT_ROOT / "data" / "cache" / "centroides_deforestacion.csv"
EXPORT_SCRIPT = PROJECT_ROOT / "scripts" / "export_centroides_cache.R"


def _find_rscript() -> str | None:
    found = shutil.which("Rscript")
    if found:
        return found
    r_root = Path(r"C:\Program Files\R")
    if r_root.is_dir():
        versions = sorted(r_root.glob("R-*/bin/Rscript.exe"), reverse=True)
        if versions:
            return str(versions[0])
    for candidate in (
        r"C:\Program Files\R\R-4.4.2\bin\Rscript.exe",
        r"C:\Program Files\R\R-4.4.1\bin\Rscript.exe",
        r"C:\Program Files\R\R-4.3.3\bin\Rscript.exe",
        r"C:\Program Files\R\R-4.3.2\bin\Rscript.exe",
        r"C:\Program Files\R\R-4.2.3\bin\Rscript.exe",
    ):
        if Path(candidate).exists():
            return candidate
    return None


def export_centroides_via_r(force: bool = False) -> bool:
    """Ejecuta scripts/export_centroides_cache.R (requiere R + sf)."""
    if CACHE_CSV.exists() and not force and CACHE_CSV.stat().st_size > 100:
        return True

    rscript = _find_rscript()
    if not rscript:
        logger.warning(
            "Rscript no encontrado. Instale R desde https://cran.r-project.org/ "
            "o ejecute manualmente: Rscript scripts/export_centroides_cache.R"
        )
        return False

    if not EXPORT_SCRIPT.exists():
        logger.error("No existe %s", EXPORT_SCRIPT)
        return False

    logger.info("Generando cache de centroides con R (puede tardar 1-2 min)...")
    try:
        result = subprocess.run(
            [rscript, str(EXPORT_SCRIPT)],
            cwd=str(PROJECT_ROOT),
            capture_output=True,
            text=True,
            timeout=600,
            env={**os.environ, "LANGUAGE": "en"},
        )
        if result.stdout:
            for line in result.stdout.strip().splitlines():
                logger.info("[R] %s", line)
        if result.returncode != 0:
            logger.error("[R] fallo exportacion: %s", (result.stderr or "").strip()[:500])
            return False
        return CACHE_CSV.exists() and CACHE_CSV.stat().st_size > 0
    except subprocess.TimeoutExpired:
        logger.error("Timeout exportando centroides con R")
        return False
    except Exception as exc:
        logger.error("Error ejecutando Rscript: %s", exc)
        return False


def load_centroides_deforestacion() -> pd.DataFrame:
    """
    Carga centroides para el mapa.
    1) CSV en data/cache (generado por R)
    2) Si no existe, intenta generarlo con Rscript
    """
    empty = pd.DataFrame(columns=["lon", "lat", "codigo", "tipo", "area", "anno", "causa"])

    if CACHE_CSV.exists() and CACHE_CSV.stat().st_size > 100:
        df = pd.read_csv(CACHE_CSV)
        logger.info("Centroides desde cache: %d puntos", len(df))
        return df

    if export_centroides_via_r():
        df = pd.read_csv(CACHE_CSV)
        logger.info("Centroides generados y cargados: %d puntos", len(df))
        return df

    logger.warning(
        "Mapa sin puntos de deforestacion. Instale R+sf y ejecute: "
        "Rscript scripts/export_centroides_cache.R"
    )
    return empty
