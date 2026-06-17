"""
Deforestación — traducción de global.R (centroides para mapa Leaflet).
Los .rds son objetos sf de R: se exportan a CSV vía scripts/export_centroides_cache.R
"""
from __future__ import annotations

import logging

import pandas as pd

from core.rds_bridge import load_centroides_deforestacion

logger = logging.getLogger(__name__)

DEPTO_CODIGOS = {
    "loreto": {
        "ACR_AA", "ACR_ANPCH", "ACR_MK", "ACR_CTT",
        "ZI_AA", "ZI_ANPCH", "ZI_MK", "ZI_CTT",
    },
    "san_martin": {"ACR_BSM", "ACR_CE", "ZI_BSM", "ZI_CE"},
    "cusco": {"ACR_CHQ", "ACR_CHU", "ACR_QK", "ZI_CHQ", "ZI_CHU", "ZI_QK"},
}


def filtrar_centroides(
    centroides_df: pd.DataFrame,
    departamento: str = "todos",
    ambito: str = "acr",
    acr_filtros: list[str] | None = None,
) -> pd.DataFrame:
    """Filtra puntos del mapa según filtros activos (sin truncar por límite arbitrario)."""
    if centroides_df.empty:
        return centroides_df

    df = centroides_df.copy()
    amb = ambito or "acr"
    if amb == "acr":
        df = df[df["tipo"] == "acr"]
    elif amb == "zi":
        df = df[df["tipo"] == "zi"]

    depto = departamento or "todos"
    if depto != "todos":
        allowed = DEPTO_CODIGOS.get(depto, set())
        df = df[df["codigo"].isin(allowed)]

    if acr_filtros:
        allowed = set(acr_filtros) | {c.replace("ACR_", "ZI_", 1) for c in acr_filtros}
        df = df[df["codigo"].isin(allowed)]

    return df.dropna(subset=["lon", "lat"])


def load_deforestacion_layers() -> pd.DataFrame:
    """Compatibilidad: devuelve centroides (el mapa usa puntos, no polígonos completos)."""
    cent = load_centroides_deforestacion()
    if cent.empty:
        return pd.DataFrame()
    return cent.rename(columns={"codigo": "CODIGO", "tipo": "TIPO", "area": "md_sup", "anno": "md_anno"})


def compute_centroides_deforestacion(defo: pd.DataFrame) -> pd.DataFrame:
    """Si ya son centroides (lon/lat), retornar tal cual."""
    if defo.empty:
        return pd.DataFrame(columns=["lon", "lat", "codigo", "tipo", "area", "anno"])

    if "lon" in defo.columns and "lat" in defo.columns:
        out = defo[["lon", "lat", "codigo", "tipo", "area", "anno"]].copy()
        if "codigo" not in out.columns and "CODIGO" in defo.columns:
            out["codigo"] = defo["CODIGO"]
            out["tipo"] = defo["TIPO"]
            out["area"] = defo["md_sup"]
            out["anno"] = defo["md_anno"]
        return out.dropna(subset=["lon", "lat"])

    return load_centroides_deforestacion()


def resumen_centroides_por_region(centroides_df: pd.DataFrame) -> dict:
    if centroides_df.empty:
        return {}

    df = centroides_df

    def _count(tipo: str, pattern: str) -> int:
        mask = (df["tipo"] == tipo) & df["codigo"].str.contains(pattern, regex=True, na=False)
        return int(mask.sum())

    return {
        "total": len(df),
        "acr": int((df["tipo"] == "acr").sum()),
        "zi": int((df["tipo"] == "zi").sum()),
        "loreto": {
            "acr": _count("acr", r"ACR_(AA|ANPCH|CTT|MK)"),
            "zi": _count("zi", r"ZI_(AA|ANPCH|CTT|MK)"),
        },
        "san_martin": {
            "acr": _count("acr", r"ACR_(BSM|CE)"),
            "zi": _count("zi", r"ZI_(BSM|CE)"),
        },
        "cusco": {
            "acr": _count("acr", r"ACR_(CHQ|CHU|QK)"),
            "zi": _count("zi", r"ZI_(CHQ|CHU|QK)"),
        },
    }
