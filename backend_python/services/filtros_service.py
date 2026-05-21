"""
Filtros — traducción de utils/helpers.R.

Equivalencias:
  bind_rows(a, b, c)     → pd.concat([a, b, c], ignore_index=True)
  df[df$Departamento == "Loreto", ] → df[df["Departamento"] == "Loreto"]
  df[df$ACR %in% filtros, ]         → df[df["ACR"].isin(filtros)]
  gsub("^ACR_", "ZI_", acr)          → acr.replace("ACR_", "ZI_", 1)
"""
from __future__ import annotations

from typing import Literal

import pandas as pd

from core.config import CAUSAS_ORDEN, DEPARTAMENTO_MAP
from services.estadisticas_service import EstadisticasConsolidadas, cargar_estadisticas_consolidadas


def _estructura_causas() -> pd.DataFrame:
    return pd.DataFrame({"Causa": CAUSAS_ORDEN, "Area_Ha": [0.0] * len(CAUSAS_ORDEN)})


def _filter_departamento(df: pd.DataFrame, departamento: str) -> pd.DataFrame:
    depto_label = DEPARTAMENTO_MAP.get(departamento)
    if depto_label is None:
        return df
    return df[df["Departamento"] == depto_label].copy()


def obtener_datos_filtrados(
    est: EstadisticasConsolidadas,
    filtros: list[str] | None = None,
    departamento: str = "todos",
    tipo: Literal["acr", "zi"] = "acr",
) -> pd.DataFrame:
    """Equivalente a obtener_datos_filtrados() en helpers.R."""
    if tipo == "acr":
        df = pd.concat(
            [
                est.acr_categoria,
                est.acr_categoria_sm,
                est.acr_categoria_cz,
            ],
            ignore_index=True,
        )
    else:
        df = pd.concat(
            [
                est.zi_categoria,
                est.zi_categoria_sm,
                est.zi_categoria_cz,
            ],
            ignore_index=True,
        )

    if "Departamento" not in df.columns:
        df["Departamento"] = "Desconocido"

    df = _filter_departamento(df, departamento)

    if filtros:
        df = df[df["ACR"].isin(filtros)]

    return df.reset_index(drop=True)


def _sum_causas_por_region(
    base: pd.DataFrame, *region_frames: pd.DataFrame
) -> pd.DataFrame:
    """Equivalente al loop for (i in 1:nrow(base_acr)) con sum() por Causa."""
    out = base.copy()
    for i, causa in enumerate(out["Causa"]):
        total = 0.0
        for frame in region_frames:
            match = frame.loc[frame["Causa"] == causa, "Area_Ha"]
            if not match.empty:
                total += float(match.iloc[0])
        out.at[i, "Area_Ha"] = total
    return out


def obtener_causas_filtradas(
    est: EstadisticasConsolidadas,
    filtros: list[str] | None = None,
    departamento: str = "todos",
    ambito: Literal["acr", "zi", "ambos"] = "acr",
) -> pd.DataFrame:
    """Equivalente a obtener_causas_filtradas() en helpers.R."""
    estructura = _estructura_causas()

    if departamento == "loreto":
        base_acr, base_zi = est.causas_acr, est.causas_zi
        causas_acr_list, causas_zi_list = est.causas_por_acr, est.causas_por_zi
    elif departamento == "san_martin":
        base_acr, base_zi = est.causas_acr_sm, est.causas_zi_sm
        causas_acr_list, causas_zi_list = est.causas_por_acr_sm, est.causas_por_zi_sm
    elif departamento == "cusco":
        base_acr, base_zi = est.causas_acr_cz, est.causas_zi_cz
        causas_acr_list, causas_zi_list = est.causas_por_acr_cz, est.causas_por_zi_cz
    else:
        base_acr = _sum_causas_por_region(
            estructura, est.causas_acr, est.causas_acr_sm, est.causas_acr_cz
        )
        base_zi = _sum_causas_por_region(
            estructura, est.causas_zi, est.causas_zi_sm, est.causas_zi_cz
        )
        causas_acr_list = {
            **est.causas_por_acr,
            **est.causas_por_acr_sm,
            **est.causas_por_acr_cz,
        }
        causas_zi_list = {
            **est.causas_por_zi,
            **est.causas_por_zi_sm,
            **est.causas_por_zi_cz,
        }

    def _acumular_desde_lista(keys: list[str], lista: dict, ambito_local: str) -> pd.DataFrame:
        datos = estructura.copy()
        for key in keys:
            zi_key = key.replace("ACR_", "ZI_", 1) if ambito_local == "zi" else key
            lookup = zi_key if ambito_local == "zi" else key
            if lookup not in lista:
                continue
            tmp = lista[lookup]
            for i, causa in enumerate(datos["Causa"]):
                match = tmp.loc[tmp["Causa"] == causa, "Area_Ha"]
                if not match.empty and pd.notna(match.iloc[0]):
                    datos.at[i, "Area_Ha"] += float(match.iloc[0])
        return datos

    if filtros:
        if ambito == "acr":
            datos_causas = _acumular_desde_lista(filtros, causas_acr_list, "acr")
        elif ambito == "zi":
            datos_causas = _acumular_desde_lista(filtros, causas_zi_list, "zi")
        else:
            datos_acr = _acumular_desde_lista(filtros, causas_acr_list, "acr")
            datos_zi = _acumular_desde_lista(filtros, causas_zi_list, "zi")
            datos_causas = estructura.copy()
            datos_causas["Area_Ha"] = datos_acr["Area_Ha"] + datos_zi["Area_Ha"]
    else:
        if ambito == "zi":
            datos_causas = base_zi.copy()
        elif ambito == "acr":
            datos_causas = base_acr.copy()
        else:
            datos_causas = estructura.copy()
            datos_causas["Area_Ha"] = base_acr["Area_Ha"].values + base_zi["Area_Ha"].values

    return datos_causas[datos_causas["Area_Ha"] > 0].reset_index(drop=True)


# Singleton en memoria — equivalente a variables globales cargadas en global.R
_ESTADISTICAS: EstadisticasConsolidadas | None = None


def get_estadisticas() -> EstadisticasConsolidadas:
    global _ESTADISTICAS
    if _ESTADISTICAS is None:
        _ESTADISTICAS = cargar_estadisticas_consolidadas()
    return _ESTADISTICAS
