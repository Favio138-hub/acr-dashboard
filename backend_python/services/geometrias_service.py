"""Capas vectoriales ACR/ZI/límites — equivalente a mod_mapa.R addPolygons."""
from __future__ import annotations

import json
import logging
from pathlib import Path

from core.config import PROJECT_ROOT
from services.decretos_service import obtener_info_decreto
from services.filtros_service import get_estadisticas, obtener_datos_filtrados

logger = logging.getLogger(__name__)

GEO_DIR = PROJECT_ROOT / "data" / "cache" / "geojson"

ACR_BY_DEPTO = {
    "loreto": {"ACR_AA", "ACR_ANPCH", "ACR_MK", "ACR_CTT"},
    "san_martin": {"ACR_BSM", "ACR_CE"},
    "cusco": {"ACR_CHQ", "ACR_CHU", "ACR_QK"},
}

ZI_BY_DEPTO = {
    "loreto": {"ZI_AA", "ZI_ANPCH", "ZI_MK", "ZI_CTT"},
    "san_martin": {"ZI_BSM", "ZI_CE"},
    "cusco": {"ZI_CHQ", "ZI_CHU", "ZI_QK"},
}

_cache: dict[str, dict] = {}


def _load_geojson(name: str) -> dict | None:
    if name in _cache:
        return _cache[name]
    path = GEO_DIR / name
    if not path.exists():
        return None
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
    _cache[name] = data
    return data


def _filter_features(geo: dict, codigos: set[str] | None) -> dict:
    if not geo or codigos is None:
        return geo
    features = [
        f for f in geo.get("features", [])
        if f.get("properties", {}).get("codigo") in codigos
    ]
    return {"type": "FeatureCollection", "features": features}


def _popup_acr_html(codigo: str, stats_row: dict) -> str:
    dec = obtener_info_decreto(codigo)
    nombre = stats_row.get("Nombre", codigo)
    return f"""<div style="font-family:Arial;min-width:250px;padding:5px;">
<h4 style="margin:0 0 12px;color:#2E7D32;border-bottom:3px solid #4CAF50;padding-bottom:5px;">
<b>{nombre}</b></h4>
<table style="width:100%;font-size:14px;line-height:1.8;">
<tr style="background:#ffebee"><td><b>🔴 Antrópico:</b></td><td align="right"><b>{stats_row.get('Antropico', 0):,.2f} ha</b></td></tr>
<tr style="background:#e8f5e9"><td><b>🟢 Natural:</b></td><td align="right"><b>{stats_row.get('Perdida_natural', 0):,.2f} ha</b></td></tr>
<tr style="background:#fff3e0"><td><b>🟡 Falsa Alerta:</b></td><td align="right"><b>{stats_row.get('Falsa_alerta', 0):,.2f} ha</b></td></tr>
<tr style="border-top:2px solid #ddd;background:#f5f5f5"><td><b>📊 TOTAL:</b></td>
<td align="right"><b style="color:#2E7D32;font-size:16px">{stats_row.get('Total', 0):,.2f} ha</b></td></tr>
</table>
<div style="margin-top:15px;padding-top:12px;border-top:2px solid #4CAF50;">
<p style="margin:0;font-size:12px"><b>📜 Decreto:</b> {dec['decreto']}</p>
<p style="margin:6px 0 0;font-size:12px"><b>📅 Fecha:</b> {dec['fecha']}</p>
</div></div>"""


def _popup_zi_html(codigo: str, stats_row: dict) -> str:
    nombre = stats_row.get("Nombre", codigo.replace("_", " "))
    return f"""<div style="font-family:Arial;min-width:250px;padding:5px;">
<h4 style="margin:0 0 12px;color:#555;border-bottom:3px solid #9E9E9E;padding-bottom:5px;">
<b>{nombre} (ZI)</b></h4>
<table style="width:100%;font-size:14px;line-height:1.8;">
<tr style="background:#ffebee"><td><b>🔴 Antrópico:</b></td><td align="right"><b>{stats_row.get('Antropico', 0):,.2f} ha</b></td></tr>
<tr style="background:#e8f5e9"><td><b>🟢 Natural:</b></td><td align="right"><b>{stats_row.get('Perdida_natural', 0):,.2f} ha</b></td></tr>
<tr style="background:#fff3e0"><td><b>🟡 Falsa Alerta:</b></td><td align="right"><b>{stats_row.get('Falsa_alerta', 0):,.2f} ha</b></td></tr>
<tr style="border-top:2px solid #ddd;background:#f5f5f5"><td><b>📊 TOTAL:</b></td>
<td align="right"><b style="color:#757575;font-size:16px">{stats_row.get('Total', 0):,.2f} ha</b></td></tr>
</table></div>"""


def _enrich_geojson(geo: dict, tipo_stats: str, depto: str) -> dict:
    if not geo:
        return geo
    est = get_estadisticas()
    out_features = []
    for f in geo.get("features", []):
        codigo = f.get("properties", {}).get("codigo", "")
        stats_df = obtener_datos_filtrados(est, [codigo], depto, tipo_stats)
        props = dict(f.get("properties", {}))
        if not stats_df.empty:
            row = stats_df.iloc[0].to_dict()
            props["Nombre"] = row.get("Nombre", codigo)
            props["Antropico"] = float(row.get("Antropico", 0))
            props["Perdida_natural"] = float(row.get("Perdida_natural", 0))
            props["Falsa_alerta"] = float(row.get("Falsa_alerta", 0))
            props["Total"] = float(row.get("Total", 0))
            if tipo_stats == "acr":
                props["popup_html"] = _popup_acr_html(codigo, row)
            else:
                props["popup_html"] = _popup_zi_html(codigo, row)
        else:
            props["popup_html"] = f"<b>{codigo}</b>"
        f = dict(f)
        f["properties"] = props
        out_features.append(f)
    return {"type": "FeatureCollection", "features": out_features}


def build_map_layers(
    departamento: str = "todos",
    ambito: str = "acr",
    acr_filtros: list[str] | None = None,
) -> dict:
    """Equivalente al observe() de mod_mapa.R."""
    depto = departamento or "todos"

    acr_codes = None
    zi_codes = None
    if acr_filtros:
        acr_codes = set(acr_filtros)
        zi_codes = {c.replace("ACR_", "ZI_", 1) for c in acr_filtros}
    elif depto != "todos":
        acr_codes = ACR_BY_DEPTO.get(depto, set())
        zi_codes = ZI_BY_DEPTO.get(depto, set())

    acr_geo = _load_geojson("acr_all.geojson")
    zi_geo = _load_geojson("zi_all.geojson")
    lim_geo = _load_geojson("limites.geojson")

    lim_filter = None
    if depto == "loreto":
        lim_filter = {"LORETO"}
    elif depto == "san_martin":
        lim_filter = {"SAN_MARTIN"}
    elif depto == "cusco":
        lim_filter = {"CUSCO"}

    show_acr = ambito in ("acr", "ambos", "") or ambito is None
    show_zi = ambito in ("zi", "ambos")

    result = {
        "acr": None,
        "zi": None,
        "limites": _filter_features(lim_geo, lim_filter) if lim_geo else None,
        "geojson_ready": acr_geo is not None,
    }

    if show_acr and acr_geo:
        filtered = _filter_features(acr_geo, acr_codes)
        result["acr"] = _enrich_geojson(filtered, "acr", depto)

    if show_zi and zi_geo:
        filtered = _filter_features(zi_geo, zi_codes)
        result["zi"] = _enrich_geojson(filtered, "zi", depto)

    return result
