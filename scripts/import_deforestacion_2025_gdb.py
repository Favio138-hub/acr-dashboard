#!/usr/bin/env python3
"""
Extrae polígonos de deforestación 2025 desde las GDB regionales y actualiza
data/cache/centroides_deforestacion.csv (y opcionalmente GeoJSON por código).

Ruta por defecto (GFP-Subnacional). Sobrescribir con variable de entorno GDB_2025_BASE.
"""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

import geopandas as gpd
import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
CACHE_CSV = ROOT / "data" / "cache" / "centroides_deforestacion.csv"
PATCH_DIR = ROOT / "data" / "incoming" / "2025"
DEFAULT_GDB_BASE = Path(
    r"C:\Users\Favio Campos Rivera\Desktop\GFP-Subnacional\2026\LBD_2026"
    r"\reporte_atd_loreto\output\salidas\Informe_ATD_preliminar\GDB"
)

LAYER_ACUM = "MonitoreoDeforestacionAcumulado"
LAYER_ZI_CE = "MonitoreoDeforestacionAcumulado_ZI_CE"
LAYER_ZI_BOSHUMI = "MonitoreoDeforestacionAcumulado_ZI_BOSHUMI"

LORETO_ACR_MAP = {
    "ACR09": "ACR_AA",
    "ACR10": "ACR_ANPCH",
    "ACR04": "ACR_CTT",
    "ACR17": "ACR_MK",
    "ACR Ampiyacu Apayacu": "ACR_AA",
    "ACR Alto Nanay Pintuyacu Chambira": "ACR_ANPCH",
    "ACR Alto Nanay Pintuyacu": "ACR_ANPCH",
    "ACR Comunal Tamshiyacu Tahuayo": "ACR_CTT",
    "ACR Maijuna Kichwa": "ACR_MK",
}

LORETO_ZI_MAP = {
    "ZI AA": "ZI_AA",
    "ZI ANPCH": "ZI_ANPCH",
    "ZI CTT": "ZI_CTT",
    "ZI MK": "ZI_MK",
}

CUSCO_ACR_MAP = {
    "ACR07": "ACR_CHQ",
    "ACR26": "ACR_CHU",
    "ACR30": "ACR_QK",
}

CUSCO_ZI_MAP = {
    "Zona de influencia ACR Choquequirao": "ZI_CHQ",
    "Zona de influencia ACR Chuyapi Urusayhua": "ZI_CHU",
    "Zona de influencia ACR Qeros Kosñipata": "ZI_QK",
    "Zona de influencia ACR Qeros Kosnipata": "ZI_QK",
}


def resolve_gdb_base() -> Path:
    env = os.environ.get("GDB_2025_BASE")
    base = Path(env) if env else DEFAULT_GDB_BASE
    if not base.exists():
        raise FileNotFoundError(f"No existe la carpeta GDB: {base}")
    return base


def find_gdb(base: Path, pattern: str) -> Path:
    matches = list(base.rglob(pattern))
    if not matches:
        raise FileNotFoundError(f"No se encontró GDB con patrón {pattern!r} en {base}")
    return matches[0]


def read_layer_2025(gdb: Path, layer: str) -> gpd.GeoDataFrame:
    gdf = gpd.read_file(str(gdb), layer=layer)
    if gdf.empty:
        return gdf
    gdf = gdf[gdf["md_anno"].astype(str).str.strip() == "2025"].copy()
    if gdf.crs is None:
        gdf = gdf.set_crs(4326)
    elif gdf.crs.to_epsg() != 4326:
        gdf = gdf.to_crs(4326)
    return gdf


def es_zi_loreto(anp_codi: str, zi_codi: str | None = None) -> bool:
    a = str(anp_codi or "").strip()
    z = str(zi_codi or "").strip()
    if a in LORETO_ZI_MAP:
        return True
    if a.upper().startswith("ZI"):
        return True
    return bool(z and z.upper().startswith("ZI"))


def codigo_loreto(row) -> tuple[str, str] | None:
    anp = str(row.get("anp_codi", "")).strip()
    zi = str(row.get("zi_codi", "")).strip() if pd.notna(row.get("zi_codi")) else ""
    if es_zi_loreto(anp, zi):
        codigo = LORETO_ZI_MAP.get(anp)
        if not codigo and anp.upper().startswith("ZI"):
            codigo = LORETO_ZI_MAP.get(anp) or f"ZI_{anp.replace('ZI ', '').replace(' ', '_')}"
        return (codigo, "zi") if codigo else None
    codigo = LORETO_ACR_MAP.get(anp)
    return (codigo, "acr") if codigo else None


def codigo_cusco(row) -> tuple[str, str] | None:
    anp = str(row.get("anp_codi", "")).strip()
    if anp in CUSCO_ZI_MAP:
        return CUSCO_ZI_MAP[anp], "zi"
    if anp in CUSCO_ACR_MAP:
        return CUSCO_ACR_MAP[anp], "acr"
    return None


def asignar_codigo(gdf: gpd.GeoDataFrame, region: str, forced: tuple[str, str] | None = None) -> gpd.GeoDataFrame:
    rows = []
    for _, row in gdf.iterrows():
        if forced:
            codigo, tipo = forced
        elif region == "loreto":
            mapped = codigo_loreto(row)
            if not mapped:
                continue
            codigo, tipo = mapped
        elif region == "cusco":
            mapped = codigo_cusco(row)
            if not mapped:
                continue
            codigo, tipo = mapped
        elif region == "acr_bsm":
            codigo, tipo = "ACR_BSM", "acr"
        elif region == "acr_ce":
            codigo, tipo = "ACR_CE", "acr"
        elif region == "zi_ce":
            codigo, tipo = "ZI_CE", "zi"
        elif region == "zi_bsm":
            codigo, tipo = "ZI_BSM", "zi"
        else:
            continue
        rows.append(
            {
                "codigo": codigo,
                "tipo": tipo,
                "area": float(row.get("md_sup") or 0),
                "anno": "2025",
                "causa": str(row.get("md_causa") or "N/A"),
                "geometry": row.geometry,
            }
        )
    if not rows:
        return gpd.GeoDataFrame(columns=["codigo", "tipo", "area", "anno", "causa", "geometry"], crs="EPSG:4326")
    out = gpd.GeoDataFrame(rows, crs="EPSG:4326")
    return out


def cargar_fuentes_2025(base: Path) -> gpd.GeoDataFrame:
    loreto_gdb = find_gdb(base, "Linea_base_deforestaci*n_Loreto.gdb")
    cusco_gdb = find_gdb(base, "Linea_base_deforestaci*n_Cuzco.gdb")
    bsm_gdb = find_gdb(base, "gdb_monit_template_ACR_BOSHUMI.gdb")
    ce_gdb = find_gdb(base, "gdb_monit_template_ACR_CE.gdb")

    partes: list[gpd.GeoDataFrame] = []

    loreto = read_layer_2025(loreto_gdb, LAYER_ACUM)
    partes.append(asignar_codigo(loreto, "loreto"))

    cusco = read_layer_2025(cusco_gdb, LAYER_ACUM)
    partes.append(asignar_codigo(cusco, "cusco"))

    bsm = read_layer_2025(bsm_gdb, LAYER_ACUM)
    partes.append(asignar_codigo(bsm, "acr_bsm"))

    zi_bsm = read_layer_2025(bsm_gdb, LAYER_ZI_BOSHUMI)
    if not zi_bsm.empty:
        partes.append(asignar_codigo(zi_bsm, "zi_bsm"))

    ce = read_layer_2025(ce_gdb, LAYER_ACUM)
    partes.append(asignar_codigo(ce, "acr_ce"))

    zi_ce = read_layer_2025(ce_gdb, LAYER_ZI_CE)
    partes.append(asignar_codigo(zi_ce, "zi_ce"))

    partes = [p for p in partes if p is not None and not p.empty]
    if not partes:
        raise RuntimeError("No se encontraron polígonos 2025 en las GDB.")
    return gpd.GeoDataFrame(pd.concat(partes, ignore_index=True), crs="EPSG:4326")


def a_centroides_df(gdf: gpd.GeoDataFrame) -> pd.DataFrame:
    cent = gdf.copy()
    cent["geometry"] = cent.geometry.centroid
    cent["lon"] = cent.geometry.x
    cent["lat"] = cent.geometry.y
    return cent[["lon", "lat", "codigo", "tipo", "area", "anno", "causa"]].dropna(subset=["lon", "lat"])


def guardar_patches(gdf: gpd.GeoDataFrame) -> None:
    PATCH_DIR.mkdir(parents=True, exist_ok=True)
    for codigo in sorted(gdf["codigo"].unique()):
        sub = gdf[gdf["codigo"] == codigo]
        path = PATCH_DIR / f"{codigo}.geojson"
        sub.to_file(path, driver="GeoJSON")
    meta = {
        "anno": 2025,
        "total_poligonos": int(len(gdf)),
        "por_codigo": gdf.groupby("codigo").size().astype(int).to_dict(),
        "hectareas_por_codigo": gdf.groupby("codigo")["area"].sum().round(4).to_dict(),
    }
    (PATCH_DIR / "resumen_2025.json").write_text(json.dumps(meta, indent=2, ensure_ascii=False), encoding="utf-8")


def actualizar_csv(nuevos: pd.DataFrame) -> pd.DataFrame:
    CACHE_CSV.parent.mkdir(parents=True, exist_ok=True)
    if CACHE_CSV.exists():
        actual = pd.read_csv(CACHE_CSV)
        actual = actual[actual["anno"].astype(str).str.strip() != "2025"]
    else:
        actual = pd.DataFrame(columns=["lon", "lat", "codigo", "tipo", "area", "anno", "causa"])
    combinado = pd.concat([actual, nuevos], ignore_index=True)
    combinado.to_csv(CACHE_CSV, index=False)
    return combinado


def main() -> int:
    base = resolve_gdb_base()
    print(f"GDB base: {base}")

    gdf_2025 = cargar_fuentes_2025(base)
    print(f"Polígonos 2025 mapeados: {len(gdf_2025)}")
    print(gdf_2025.groupby(["codigo", "tipo"]).agg(n=("area", "size"), ha=("area", "sum")).round(2))

    guardar_patches(gdf_2025)
    nuevos = a_centroides_df(gdf_2025)
    combinado = actualizar_csv(nuevos)
    print(f"Centroides CSV: {len(combinado)} filas ({len(nuevos)} nuevas de 2025)")
    print(f"Guardado: {CACHE_CSV}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
