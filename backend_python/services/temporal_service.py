"""
Datos temporales — utils/datos_temporales_acr.R (serie 2001-2024).
"""
from __future__ import annotations

import re
from pathlib import Path

import pandas as pd

from core.config import PROJECT_ROOT
from services.filtros_config import ACR_OPCIONES_POR_DEPTO

ACR_NAME_TO_CODE = {
    "Choquequirao": "ACR_CHQ",
  "Chuyapi Urusayhua": "ACR_CHU",
  "Q'eros Kosñipata": "ACR_QK",
  "Cordillera Escalera": "ACR_CE",
    "Bosques de Shunté y Mishollo": "ACR_BSM",
    "Ampiyacu Apayacu": "ACR_AA",
    "Alto Nanay Pintuyacu Chambira": "ACR_ANPCH",
    "Comunal Tamshiyacu Tahuayo": "ACR_CTT",
    "Maijuna Kichwa": "ACR_MK",
}

DEPTO_TO_REGION = {
    "loreto": "Loreto",
    "san_martin": "San Martín",
    "cusco": "Cusco",
}

_R_LINE = re.compile(
    r'"([^"]+)",\s*"([^"]+)",\s*(\d{4}),\s*([\d.]+)'
)

_df: pd.DataFrame | None = None


def _load() -> pd.DataFrame:
    global _df
    if _df is not None:
        return _df

    r_path = PROJECT_ROOT / "utils" / "datos_temporales_acr.R"
    records: list[dict] = []
    if r_path.exists():
        text = r_path.read_text(encoding="utf-8")
        for region, acr, anio, val in _R_LINE.findall(text):
            records.append(
                {
                    "Region": region,
                    "ACR": acr,
                    "Anio": int(anio),
                    "Deforestacion_ha": float(val),
                    "ACR_codigo": ACR_NAME_TO_CODE.get(acr, acr),
                }
            )

    _df = pd.DataFrame(records)
    return _df


def _codigos_para_filtro(
    filtros: list[str] | None,
    departamento: str = "todos",
) -> list[str]:
    if filtros:
        return list(filtros)
    grupos = ACR_OPCIONES_POR_DEPTO.get(departamento, ACR_OPCIONES_POR_DEPTO["todos"])
    codes: list[str] = []
    for items in grupos.values():
        codes.extend(items.values())
    return codes


def _subset_temporal(
    filtros: list[str] | None = None,
    departamento: str = "todos",
) -> pd.DataFrame:
    df = _load()
    if df.empty:
        return df

    if filtros:
        return df[df["ACR_codigo"].isin(filtros)]

    region = DEPTO_TO_REGION.get(departamento)
    if region:
        return df[df["Region"] == region]

    return df


def calcular_variacion_anual(
    filtros: list[str] | None = None,
    departamento: str = "todos",
) -> dict:
    """Variación 2024 vs 2023 según filtros activos (ACR, departamento o total)."""
    sub = _subset_temporal(filtros, departamento)
    if sub.empty:
        return {
            "variacion": 0.0,
            "texto": "Sin datos",
            "icono": "minus",
            "color": "#f39c12",
        }

    y2023 = float(sub[sub["Anio"] == 2023]["Deforestacion_ha"].sum())
    y2024 = float(sub[sub["Anio"] == 2024]["Deforestacion_ha"].sum())
    variacion = 0.0 if y2023 == 0 else round(((y2024 - y2023) / y2023) * 100, 1)

    if variacion > 0:
        return {
            "variacion": variacion,
            "texto": "Incremento",
            "icono": "arrow-up",
            "color": "#d9534f",
        }
    if variacion < 0:
        return {
            "variacion": variacion,
            "texto": "Reducción",
            "icono": "arrow-down",
            "color": "#5cb85c",
        }
    return {
        "variacion": 0.0,
        "texto": "Sin cambios",
        "icono": "minus",
        "color": "#f39c12",
    }


def serie_temporal(filtros: list[str] | None = None) -> list[dict]:
    df = _subset_temporal(filtros, "todos")
    if filtros:
        df = df[df["ACR_codigo"].isin(filtros)]
    if df.empty:
        return []
    return (
        df.groupby("Anio", as_index=False)["Deforestacion_ha"]
        .sum()
        .to_dict(orient="records")
    )
