"""Traducción de utils/datos_decretos_acr.R"""
from __future__ import annotations

import pandas as pd

ACR_DECRETOS = pd.DataFrame(
    {
        "codigo": [
            "ACR_AA", "ACR_ANPCH", "ACR_CTT", "ACR_MK",
            "ACR_BSM", "ACR_CE",
            "ACR_CHQ", "ACR_CHU", "ACR_QK",
        ],
        "nombre_completo": [
            "ACR Alto Nanay - Pintuyacu Chambira",
            "ACR Ampiyacu Apayacu",
            "ACR Comunal Tamshiyacu Tahuayo",
            "ACR Maijuna Kichwa",
            "ACR Bosques de Shunté y Mishollo",
            "ACR Cordillera Escalera",
            "ACR Choquequirao",
            "ACR Chuyapi Urusayhua",
            "ACR Q'eros Kosñipata",
        ],
        "decreto_supremo": [
            "D.S. N° 005-2015-MINAM",
            "D.S. N° 006-2010-MINAM",
            "D.S. N° 010-2009-MINAM",
            "D.S. N° 008-2015-MINAM",
            "D.S. N° 011-2017-MINAM",
            "D.S. N° 045-2005-AG",
            "D.S. N° 016-2010-MINAM",
            "D.S. N° 009-2014-MINAM",
            "D.S. N° 008-2014-MINAM",
        ],
        "fecha_creacion": [
            "29/01/2015", "14/01/2010", "20/05/2009", "29/01/2015",
            "04/08/2017", "22/12/2005",
            "08/04/2010", "21/01/2014", "21/01/2014",
        ],
        "superficie_ha": [
            943.87, 434.13, 420.08, 391.04,
            28588.86, 149870.23,
            103814.39, 66514.49, 39345.85,
        ],
        "region": [
            "Loreto", "Loreto", "Loreto", "Loreto",
            "San Martín", "San Martín",
            "Cusco", "Cusco", "Cusco",
        ],
    }
)


def obtener_info_decreto(codigo_acr: str) -> dict:
    row = ACR_DECRETOS[ACR_DECRETOS["codigo"] == codigo_acr]
    if row.empty:
        return {"decreto": "N/A", "fecha": "N/A", "nombre": codigo_acr, "superficie": None, "region": None}
    r = row.iloc[0]
    return {
        "decreto": r["decreto_supremo"],
        "fecha": r["fecha_creacion"],
        "nombre": r["nombre_completo"],
        "superficie": float(r["superficie_ha"]),
        "region": r["region"],
    }
