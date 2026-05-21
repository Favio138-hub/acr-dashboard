"""
Carga de archivos — traducción de utils/cargar_datos.R.

Equivalencias R → Python:
  buscar_archivo()     → find_data_file()
  readRDS()            → pyreadr.read_r() + conversión a GeoDataFrame si hay geometría
  st_transform(4326)   → gdf.to_crs(epsg=4326)
  st_simplify()        → gdf.simplify() (tolerancia en grados, análoga a dTolerance)
  Filter(Negate(is.null)) → {k: v for k, v in items if v is not None}
"""
from __future__ import annotations

import logging
from pathlib import Path
from typing import Any

import pandas as pd

from core.config import DATA_DIR, PROJECT_ROOT

logger = logging.getLogger(__name__)

try:
    import geopandas as gpd
    import pyreadr
    HAS_GEO = True
except ImportError:
    HAS_GEO = False
    gpd = None  # type: ignore


def find_data_file(filename: str, subdirectory: str | None = None) -> Path | None:
    """Equivalente a buscar_archivo() en cargar_datos.R."""
    candidates: list[Path] = []
    if subdirectory:
        candidates.extend(
            [
                DATA_DIR / subdirectory / filename,
                PROJECT_ROOT / "data" / subdirectory / filename,
            ]
        )
    candidates.extend(
        [
            DATA_DIR / filename,
            PROJECT_ROOT / "data" / filename,
            PROJECT_ROOT / filename,
        ]
    )
    for path in candidates:
        if path.exists():
            return path
    return None


def load_rds_optimized(
    filename: str,
    name: str,
    subdirectory: str | None = None,
    *,
    simplify: bool = True,
) -> Any | None:
    """
    Equivalente a cargar_rds_optimizado().
    Devuelve GeoDataFrame (sf) o DataFrame según el contenido del RDS.
    """
    if not HAS_GEO:
        logger.warning("geopandas/pyreadr no instalados; no se puede cargar %s", name)
        return None

    path = find_data_file(filename, subdirectory)
    if path is None:
        logger.warning("No se encuentra %s", filename)
        return None

    try:
        result = pyreadr.read_r(str(path))
        # pyreadr devuelve dict {nombre_objeto: DataFrame}
        df = next(iter(result.values()))

        if hasattr(df, "geometry") or "geometry" in getattr(df, "columns", []):
            gdf = gpd.GeoDataFrame(df, geometry="geometry", crs="EPSG:4326")
        else:
            # Intentar construir desde columnas WKT si existieran
            gdf = gpd.GeoDataFrame(df)
            if gdf.crs is None:
                gdf.set_crs(epsg=4326, inplace=True, allow_override=True)

        if gdf.crs is not None and gdf.crs.to_epsg() != 4326:
            gdf = gdf.to_crs(epsg=4326)

        if simplify and not gdf.empty:
            try:
                n_verts = len(gdf.geometry.iloc[0].coords) if len(gdf) else 0
            except Exception:
                n_verts = 5000
            tolerance = 0.001
            if n_verts > 10000:
                tolerance = 0.005
            elif n_verts > 5000:
                tolerance = 0.002
            gdf["geometry"] = gdf.geometry.simplify(tolerance, preserve_topology=True)

        keep_cols = [
            c
            for c in gdf.columns
            if c
            in {
                "geometry",
                "OBJECTID",
                "id",
                "nombre",
                "codigo",
                "area",
                "area_ha",
                "AREA_HA",
                "anp_codi",
                "anp_nomb",
            }
        ]
        if len(gdf.columns) > 10 and keep_cols:
            gdf = gdf[keep_cols]

        logger.info("%s cargado y optimizado (%d filas)", name, len(gdf))
        return gdf

    except Exception as exc:
        logger.error("Error cargando %s: %s", name, exc)
        return None


def load_rds_tabular(relative_path: str) -> pd.DataFrame | None:
    """
    RDS tabulares simples. Los .rds sf (deforestación) NO se leen aquí;
    usar core.rds_bridge.load_centroides_deforestacion().
    """
    if not HAS_GEO:
        return None
    path = PROJECT_ROOT / relative_path
    if not path.exists():
        return None
    try:
        result = pyreadr.read_r(str(path))
        return next(iter(result.values()))
    except Exception as exc:
        logger.debug("RDS no legible con pyreadr (%s): %s", relative_path, exc)
        return None
