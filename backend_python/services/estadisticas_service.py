"""
Estadísticas consolidadas — traducción fiel de cargar_estadisticas_consolidadas()
en utils/cargar_datos.R (líneas 181-352).

Equivalencias:
  data.frame()           → pd.DataFrame()
  stringsAsFactors=FALSE → dtype object/str explícito
  rowSums(...[, cols])   → df[col].sum(axis=1) o df[cols].sum(axis=1)
  list(...) de dfs       → dict[str, pd.DataFrame]
"""
from __future__ import annotations

from dataclasses import dataclass

import pandas as pd

from core.config import CAUSAS_ORDEN


def _causas_df(areas: list[float]) -> pd.DataFrame:
    return pd.DataFrame({"Causa": CAUSAS_ORDEN, "Area_Ha": areas})


@dataclass
class EstadisticasConsolidadas:
    """Contenedor tipado — equivalente al list() retornado por R."""

    causas_acr: pd.DataFrame
    causas_zi: pd.DataFrame
    causas_por_acr: dict[str, pd.DataFrame]
    causas_por_zi: dict[str, pd.DataFrame]
    acr_categoria: pd.DataFrame
    zi_categoria: pd.DataFrame
    causas_acr_sm: pd.DataFrame
    causas_zi_sm: pd.DataFrame
    causas_por_acr_sm: dict[str, pd.DataFrame]
    causas_por_zi_sm: dict[str, pd.DataFrame]
    acr_categoria_sm: pd.DataFrame
    zi_categoria_sm: pd.DataFrame
    causas_acr_cz: pd.DataFrame
    causas_zi_cz: pd.DataFrame
    causas_por_acr_cz: dict[str, pd.DataFrame]
    causas_por_zi_cz: dict[str, pd.DataFrame]
    acr_categoria_cz: pd.DataFrame
    zi_categoria_cz: pd.DataFrame


def _add_total_categoria(df: pd.DataFrame) -> pd.DataFrame:
    """Equivalente a: df$Total <- rowSums(df[, c('Antropico', 'Perdida_natural', 'Falsa_alerta')])"""
    out = df.copy()
    out["Total"] = out[["Antropico", "Perdida_natural", "Falsa_alerta"]].sum(axis=1)
    return out


def cargar_estadisticas_consolidadas() -> EstadisticasConsolidadas:
    """
    Réplica 1:1 de cargar_estadisticas_consolidadas() en R.
    Los valores numéricos se mantienen idénticos al dashboard Shiny.
    """
    # --- LORETO ---
    causas_acr = _causas_df(
        [497.84, 11.87, 205.73, 16.96, 39.80, 0, 0, 0, 0, 0, 0]
    )
    causas_zi = _causas_df(
        [5245.95, 569.07, 162.27, 98.53, 208.08, 0, 0, 0, 0, 0, 0]
    )

    causas_por_acr = {
        "ACR_AA": _causas_df([120.50, 3.20, 65.30, 5.50, 17.06, 0, 0, 0, 0, 0, 0]),
        "ACR_ANPCH": _causas_df([85.20, 2.10, 45.50, 3.20, 6.51, 0, 0, 0, 0, 0, 0]),
        "ACR_MK": _causas_df([225.14, 4.57, 75.93, 6.26, 34.07, 0, 0, 0, 0, 0, 0]),
        "ACR_CTT": _causas_df([67.00, 2.00, 19.00, 2.00, 2.16, 0, 0, 0, 0, 0, 0]),
    }

    causas_por_zi = {
        "ZI_AA": _causas_df([1650.00, 142.00, 45.00, 30.00, 215.00, 0, 0, 0, 0, 0, 0]),
        "ZI_ANPCH": _causas_df([1580.00, 135.50, 40.27, 25.53, 197.51, 0, 0, 0, 0, 0, 0]),
        "ZI_MK": _causas_df([1150.00, 185.57, 50.00, 28.00, 27.24, 0, 0, 0, 0, 0, 0]),
        "ZI_CTT": _causas_df([865.95, 106.00, 27.00, 15.00, 68.78, 0, 0, 0, 0, 0, 0]),
    }

    acr_categoria = _add_total_categoria(
        pd.DataFrame(
            {
                "ACR": ["ACR_AA", "ACR_ANPCH", "ACR_MK", "ACR_CTT"],
                "Nombre": [
                    "ACR Ampiyacu Apayacu",
                    "ACR Alto Nanay – Pintuyacu Chambira",
                    "ACR Maijuna Kichwa",
                    "ACR Comunal Tamshiyacu Tahuayo",
                ],
                "Departamento": "Loreto",
                "Antropico": [211.56, 142.51, 345.97, 72.16],
                "Perdida_natural": [217.32, 417.62, 69.1, 39.69],
                "Falsa_alerta": [128.9, 383.74, 61.7, 87.63],
            }
        )
    )

    zi_categoria = _add_total_categoria(
        pd.DataFrame(
            {
                "ACR": ["ACR_AA", "ACR_MK", "ACR_ANPCH", "ACR_CTT"],
                "Nombre": [
                    "ZI Ampiyacu Apayacu",
                    "ZI Maijuna Kichwa",
                    "ZI Alto Nanay – Pintuyacu Chambira",
                    "ZI Comunal Tamshiyacu Tahuayo",
                ],
                "Departamento": "Loreto",
                "Antropico": [2082, 1440.81, 1978.81, 782.73],
                "Perdida_natural": [20.52, 8.37, 575.01, 660.06],
                "Falsa_alerta": [633.05, 613.71, 1015.29, 389.16],
            }
        )
    )

    # --- SAN MARTÍN ---
    causas_acr_sm = _causas_df(
        [2478.40, 0, 123.94, 0, 0, 260.20, 298.89, 9.63, 0, 50.56, 240.25]
    )
    causas_zi_sm = _causas_df(
        [32074.67, 0, 165.01, 0, 0, 0.00, 379.64, 104.64, 0, 8.34, 6.12]
    )

    causas_por_acr_sm = {
        "ACR_BSM": _causas_df([384.14, 0, 77.58, 0, 0, 238.66, 0.00, 0.63, 0, 0, 46.81]),
        "ACR_CE": _causas_df([2094.28, 0, 6.55, 0, 0, 21.76, 325.75, 19.54, 0, 50.56, 0.00]),
    }

    causas_por_zi_sm = {
        "ZI_BSM": _causas_df([1040.20, 0, 45.36, 0, 0, 0.00, 298.89, 0.00, 0, 0, 240.25]),
        "ZI_CE": _causas_df([31034.47, 0, 119.65, 0, 0, 0.00, 0.00, 104.64, 0, 8.34, 0.00]),
    }

    acr_categoria_sm = _add_total_categoria(
        pd.DataFrame(
            {
                "ACR": ["ACR_BSM", "ACR_CE"],
                "Nombre": [
                    "ACR Bosques de Shunté y Mishollo",
                    "ACR Cordillera Escalera",
                ],
                "Departamento": "San Martín",
                "Antropico": [747.82, 2518.43],
                "Perdida_natural": [1040.20, 728.02],
                "Falsa_alerta": [145.25, 175.34],
            }
        )
    )

    zi_categoria_sm = _add_total_categoria(
        pd.DataFrame(
            {
                "ACR": ["ACR_BSM", "ACR_CE"],
                "Nombre": [
                    "ZI Bosques de Shunté y Mishollo",
                    "ZI Cordillera Escalera",
                ],
                "Departamento": "San Martín",
                "Antropico": [1623.70, 31682.60],
                "Perdida_natural": [618.09, 355.16],
                "Falsa_alerta": [35.48, 30.14],
            }
        )
    )

    # --- CUSCO ---
    causas_acr_cz = _causas_df(
        [680.57, 5.02, 2.52, 0, 0, 8.28, 140.93, 0, 0.27, 0, 0.18]
    )
    causas_zi_cz = _causas_df(
        [1058.78, 0, 11.00, 0, 0, 12.96, 129.13, 0, 0, 0, 0.72]
    )

    causas_por_acr_cz = {
        "ACR_CHQ": _causas_df([351.74, 5.02, 0.08, 0, 0, 8.28, 14.00, 0, 0.27, 0, 0.18]),
        "ACR_CHU": _causas_df([324.24, 0, 2.43, 0, 0, 12.96, 126.93, 0, 0, 0, 0.72]),
        "ACR_QK": _causas_df([4.59, 0, 0.01, 0, 0, 0, 0, 0, 0, 0, 0]),
    }

    causas_por_zi_cz = {
        "ZI_CHQ": _causas_df([254.69, 0, 11.00, 0, 0, 0, 0, 0, 0, 0, 0]),
        "ZI_CHU": _causas_df([341.53, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
        "ZI_QK": _causas_df([462.56, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
    }

    acr_categoria_cz = _add_total_categoria(
        pd.DataFrame(
            {
                "ACR": ["ACR_CHQ", "ACR_CHU", "ACR_QK"],
                "Nombre": [
                    "ACR Choquequirao",
                    "ACR Chuyapi Urusayhua",
                    "ACR Q'eros Kosñipata",
                ],
                "Area_Ha": [103814.4, 57780.1, 55460.1],
                "Departamento": "Cusco",
                "Antropico": [379.59, 467.28, 4.59],
                "Perdida_natural": [254.69, 341.53, 462.56],
                "Falsa_alerta": [61.98, 92.85, 81.12],
            }
        )
    )

    zi_categoria_cz = _add_total_categoria(
        pd.DataFrame(
            {
                "ACR": ["ACR_CHQ", "ACR_CHU", "ACR_QK"],
                "Nombre": [
                    "ZI Choquequirao",
                    "ZI Chuyapi Urusayhua",
                    "ZI Q'eros Kosñipata",
                ],
                "Departamento": "Cusco",
                "Antropico": [15.89, 734.19, 240.23],
                "Perdida_natural": [11.00, 96.33, 25.80],
                "Falsa_alerta": [1.01, 0.93, 0.27],
            }
        )
    )

    return EstadisticasConsolidadas(
        causas_acr=causas_acr,
        causas_zi=causas_zi,
        causas_por_acr=causas_por_acr,
        causas_por_zi=causas_por_zi,
        acr_categoria=acr_categoria,
        zi_categoria=zi_categoria,
        causas_acr_sm=causas_acr_sm,
        causas_zi_sm=causas_zi_sm,
        causas_por_acr_sm=causas_por_acr_sm,
        causas_por_zi_sm=causas_por_zi_sm,
        acr_categoria_sm=acr_categoria_sm,
        zi_categoria_sm=zi_categoria_sm,
        causas_acr_cz=causas_acr_cz,
        causas_zi_cz=causas_zi_cz,
        causas_por_acr_cz=causas_por_acr_cz,
        causas_por_zi_cz=causas_por_zi_cz,
        acr_categoria_cz=acr_categoria_cz,
        zi_categoria_cz=zi_categoria_cz,
    )


def estadisticas_a_catalogo(est: EstadisticasConsolidadas) -> dict[str, pd.DataFrame]:
    """
    Aplana el objeto en tablas nombradas — equivalente a asignar variables
    en global.R (acr_categoria, causas_por_acr, etc.).
    """
    return {
        "acr_categoria": est.acr_categoria,
        "zi_categoria": est.zi_categoria,
        "acr_categoria_sm": est.acr_categoria_sm,
        "zi_categoria_sm": est.zi_categoria_sm,
        "acr_categoria_cz": est.acr_categoria_cz,
        "zi_categoria_cz": est.zi_categoria_cz,
        "causas_acr": est.causas_acr,
        "causas_zi": est.causas_zi,
        "causas_acr_sm": est.causas_acr_sm,
        "causas_zi_sm": est.causas_zi_sm,
        "causas_acr_cz": est.causas_acr_cz,
        "causas_zi_cz": est.causas_zi_cz,
    }
