"""
Insights regionales calculados desde centroides y serie temporal.
"""
from __future__ import annotations

import re

import pandas as pd

from core.config import PROJECT_ROOT
from services.deforestacion_service import DEPTO_CODIGOS
from services.filtros_config import ACR_OPCIONES_TODOS

ACR_NOMBRES = {
    code: label.replace("ACR ", "", 1)
    for group in ACR_OPCIONES_TODOS.values()
    for label, code in group.items()
}

REGION_LABELS = {
    "loreto": "LORETO",
    "san_martin": "SAN MARTÍN",
    "cusco": "CUSCO",
}


def _fmt_ha(value: float, decimals: int = 0) -> str:
    if decimals == 0:
        return f"{value:,.0f}".replace(",", ".")
    return f"{value:,.{decimals}f}".replace(",", "X").replace(".", ",").replace("X", ".")


def _fmt_pct(value: float, signed: bool = True) -> str:
    sign = "+" if value > 0 and signed else ""
    if value < 0 and signed:
        sign = ""
    return f"{sign}{value:.1f}%"


def _fmt_int(value: float | int) -> str:
    return f"{int(round(value)):,}".replace(",", ".")


def _subset(df: pd.DataFrame, depto: str, solo_acr: bool = False) -> pd.DataFrame:
    codes = DEPTO_CODIGOS.get(depto, set())
    sub = df[df["codigo"].isin(codes)].copy()
    if solo_acr:
        sub = sub[sub["codigo"].str.startswith("ACR_")]
    return sub


def _causa_valida(causa: str) -> bool:
    text = str(causa or "").strip()
    low = text.lower()
    if not text or low in {"n/a", "na", "none", "nan"}:
        return False
    if low == "natural":
        return False
    if "falsa" in low and "alerta" in low:
        return False
    if text.replace(".", "", 1).isdigit():
        return False
    return len(text) >= 3 and any(ch.isalpha() for ch in text)


def _top_causa(df: pd.DataFrame) -> tuple[str, float]:
    valid = df[df["causa"].map(_causa_valida)]
    if valid.empty:
        return "Origen antrópico", float(df["area"].sum())
    grouped = valid.groupby("causa", as_index=False)["area"].sum().sort_values("area", ascending=False)
    row = grouped.iloc[0]
    return str(row["causa"]), float(row["area"])


def _pct_antropico(df: pd.DataFrame) -> float:
    if df.empty:
        return 0.0
    low = df["causa"].astype(str).str.strip().str.lower()
    ant = ~low.isin({"natural"}) & ~low.str.contains("falsa", na=False)
    total = float(df["area"].sum())
    if total <= 0:
        return 0.0
    return round(float(df.loc[ant, "area"].sum()) / total * 100, 1)


def _annual_totals(df: pd.DataFrame) -> pd.Series:
    years = pd.to_numeric(df["anno"], errors="coerce")
    return df.assign(_anno=years).dropna(subset=["_anno"]).groupby("_anno")["area"].sum()


def _load_temporal() -> pd.DataFrame:
    path = PROJECT_ROOT / "utils" / "datos_temporales_acr.R"
    if not path.exists():
        return pd.DataFrame(columns=["Region", "ACR", "Anio", "Deforestacion_ha"])
    text = path.read_text(encoding="utf-8")
    rows = re.findall(r'"([^"]+)",\s*"([^"]+)",\s*(\d{4}),\s*([\d.]+)', text)
    df = pd.DataFrame(rows, columns=["Region", "ACR", "Anio", "Deforestacion_ha"])
    df["Anio"] = df["Anio"].astype(int)
    df["Deforestacion_ha"] = df["Deforestacion_ha"].astype(float)
    return df


def _temporal_region(region: str) -> pd.Series:
    df = _load_temporal()
    sub = df[df["Region"] == region]
    if sub.empty:
        return pd.Series(dtype=float)
    return sub.groupby("Anio")["Deforestacion_ha"].sum().sort_index()


def _trend_since(year_from: int, year_to: int, series: pd.Series) -> float | None:
    if year_from not in series.index or year_to not in series.index:
        return None
    base = float(series.loc[year_from])
    end = float(series.loc[year_to])
    if base <= 0:
        return None
    return round((end - base) / base * 100, 1)


def _build_loreto(df: pd.DataFrame) -> dict:
    acr = _subset(df, "loreto", solo_acr=True)
    all_lo = _subset(df, "loreto")
    annual_acr = _annual_totals(acr)
    avg_recent = float(annual_acr.loc[annual_acr.index.isin(range(2018, 2025))].mean()) if not annual_acr.empty else 0.0
    avg_prior = float(annual_acr.loc[annual_acr.index.isin(range(2011, 2018))].mean()) if not annual_acr.empty else 0.0
    trend_avg = None if avg_prior <= 0 else round((avg_recent - avg_prior) / avg_prior * 100, 1)

    by_acr = acr.groupby("codigo")["area"].sum().sort_values(ascending=False)
    top_code = str(by_acr.index[0]) if not by_acr.empty else "ACR_ANPCH"
    top_name = ACR_NOMBRES.get(top_code, top_code)
    top_ha = float(by_acr.iloc[0]) if not by_acr.empty else 0.0

    y2025 = all_lo[pd.to_numeric(all_lo["anno"], errors="coerce") == 2025]
    alerts_2025 = int(len(y2025))
    ha_acr_2025 = float(y2025[y2025["codigo"].str.startswith("ACR_")]["area"].sum())
    ha_zi_2025 = float(y2025[y2025["codigo"].str.startswith("ZI_")]["area"].sum())
    causa, _ = _top_causa(acr[pd.to_numeric(acr["anno"], errors="coerce").between(2015, 2025)])

    summary = (
        f"<strong>{top_name}</strong> concentra la mayor superficie deforestada acumulada "
        f"(<strong>{_fmt_ha(top_ha)} ha</strong>). En 2025 se registraron "
        f"<strong>{_fmt_int(alerts_2025)} alertas</strong> "
        f"({_fmt_ha(ha_acr_2025, 1)} ha en ACR y {_fmt_ha(ha_zi_2025, 1)} ha en zonas de influencia). "
        f"La causa antrópica dominante es <strong>{causa}</strong>."
    )

    trend_text = (
        f"Tendencia reciente: {_fmt_pct(trend_avg)} en promedio anual (2018–2024 vs 2011–2017)"
        if trend_avg is not None
        else "Tendencia reciente: estable en el periodo analizado"
    )

    return {
        "id": "loreto",
        "label": REGION_LABELS["loreto"],
        "accent": "#f1c40f",
        "title": "Presión diferenciada entre ACR y zonas de influencia",
        "icon": "fa-fire",
        "icon_color": "#e74c3c",
        "summary": summary,
        "metrics": [
            {"icon": "fa-trophy", "color": "#e67e22", "text": f"ACR líder: {top_name} ({_fmt_ha(top_ha)} ha)"},
            {"icon": "fa-chart-line", "color": "#f39c12", "text": trend_text},
            {"icon": "fa-bell", "color": "#e74c3c", "text": f"Alertas 2025: {_fmt_int(alerts_2025)} polígonos"},
            {"icon": "fa-tractor", "color": "#27ae60", "text": f"Causa principal: {causa}"},
        ],
        "modal": {
            "title": "LORETO — Análisis regional",
            "stats": [
                [_fmt_ha(top_ha), "Ha acumuladas (ACR líder)", "#fff3cd", "#f39c12"],
                [_fmt_int(alerts_2025), "Alertas registradas en 2025", "#ffe8e8", "#e74c3c"],
                [_fmt_ha(ha_zi_2025, 1), "Ha en ZI durante 2025", "#e8f5e9", "#27ae60"],
            ],
            "sections": [
                {
                    "title": "Distribución por ACR (acumulado)",
                    "html": _acr_ranking_html(acr, "loreto"),
                },
                {
                    "title": "Dinámica reciente",
                    "html": (
                        f"<p>El promedio anual en territorios ACR pasó de "
                        f"<strong>{_fmt_ha(avg_prior, 1)} ha/año</strong> (2011–2017) a "
                        f"<strong>{_fmt_ha(avg_recent, 1)} ha/año</strong> (2018–2024)."
                        f"{' Variación: ' + _fmt_pct(trend_avg) + '.' if trend_avg is not None else ''}</p>"
                        f"<p>En 2025, las zonas de influencia aportan "
                        f"<strong>{_fmt_ha(ha_zi_2025, 1)} ha</strong>, frente a "
                        f"<strong>{_fmt_ha(ha_acr_2025, 1)} ha</strong> dentro de las ACR.</p>"
                    ),
                },
            ],
        },
    }


def _build_san_martin(df: pd.DataFrame) -> dict:
    acr = _subset(df, "san_martin", solo_acr=True)
    all_sm = _subset(df, "san_martin")
    annual = _annual_totals(acr)
    avg_recent = float(annual.loc[annual.index.isin(range(2018, 2025))].mean()) if not annual.empty else 0.0
    avg_prior = float(annual.loc[annual.index.isin(range(2011, 2018))].mean()) if not annual.empty else 0.0
    trend_avg = None if avg_prior <= 0 else round((avg_recent - avg_prior) / avg_prior * 100, 1)

    y2025 = all_sm[pd.to_numeric(all_sm["anno"], errors="coerce") == 2025]
    zi_ce_2025 = float(y2025[y2025["codigo"] == "ZI_CE"]["area"].sum())
    acr_ce_2025 = float(y2025[y2025["codigo"] == "ACR_CE"]["area"].sum())
    acr_bsm_2025 = float(y2025[y2025["codigo"] == "ACR_BSM"]["area"].sum())
    peak_year = int(annual.idxmax()) if not annual.empty else 2024
    peak_ha = float(annual.max()) if not annual.empty else 0.0
    pct_ant = _pct_antropico(acr[pd.to_numeric(acr["anno"], errors="coerce").between(2015, 2025)])

    summary = (
        f"San Martín muestra un <strong>incremento del promedio anual</strong> en territorios ACR "
        f"desde 2018, con pico en <strong>{peak_year}</strong> ({_fmt_ha(peak_ha, 1)} ha). "
        f"En 2025, <strong>Cordillera Escalera</strong> registra {_fmt_ha(acr_ce_2025, 1)} ha en ACR y "
        f"<strong>{_fmt_ha(zi_ce_2025, 1)} ha</strong> en su zona de influencia."
    )

    return {
        "id": "sanmartin",
        "label": REGION_LABELS["san_martin"],
        "accent": "#f8c471",
        "title": "Recrudecimiento en Cordillera Escalera",
        "icon": "fa-exclamation-triangle",
        "icon_color": "#f39c12",
        "summary": summary,
        "metrics": [
            {"icon": "fa-chart-line", "color": "#e74c3c", "text": (
                f"Promedio anual ACR: {_fmt_pct(trend_avg)} (2018–2024 vs 2011–2017)"
                if trend_avg is not None else "Promedio anual ACR en evaluación"
            )},
            {"icon": "fa-mountain", "color": "#8e44ad", "text": f"ACR CE 2025: {_fmt_ha(acr_ce_2025, 1)} ha"},
            {"icon": "fa-map-marked-alt", "color": "#e67e22", "text": f"ZI CE 2025: {_fmt_ha(zi_ce_2025, 1)} ha"},
            {"icon": "fa-user-cog", "color": "#95a5a6", "text": f"Origen antrópico (2015–2025): {pct_ant}%"},
        ],
        "modal": {
            "title": "SAN MARTÍN — Análisis regional",
            "stats": [
                [_fmt_ha(peak_ha, 1), f"Pico anual ACR ({peak_year})", "#ffe8e8", "#e74c3c"],
                [_fmt_ha(zi_ce_2025, 1), "Ha ZI Cordillera Escalera 2025", "#fff3e0", "#e67e22"],
                [f"{pct_ant}%", "Origen antrópico 2015–2025", "#f5f5f5", "#7f8c8d"],
            ],
            "sections": [
                {
                    "title": "Comparación ACR Bosques de Shunté vs Cordillera Escalera",
                    "html": (
                        f"<ul>"
                        f"<li><strong>ACR Cordillera Escalera (2025):</strong> {_fmt_ha(acr_ce_2025, 1)} ha</li>"
                        f"<li><strong>ACR Bosques de Shunté (2025):</strong> {_fmt_ha(acr_bsm_2025, 1)} ha</li>"
                        f"<li><strong>ZI Cordillera Escalera (2025):</strong> {_fmt_ha(zi_ce_2025, 1)} ha</li>"
                        f"</ul>"
                    ),
                },
                {
                    "title": "Tendencia interanual",
                    "html": (
                        f"<p>Promedio anual en ACR: <strong>{_fmt_ha(avg_prior, 1)} ha</strong> (2011–2017) "
                        f"→ <strong>{_fmt_ha(avg_recent, 1)} ha</strong> (2018–2024)."
                        f"{' Cambio: ' + _fmt_pct(trend_avg) + '.' if trend_avg is not None else ''}</p>"
                    ),
                },
            ],
        },
    }


def _build_cusco(df: pd.DataFrame) -> dict:
    acr = _subset(df, "cusco", solo_acr=True)
    series = _temporal_region("Cusco")
    trend_20_24 = _trend_since(2020, 2024, series)
    ha_2024 = float(series.get(2024, 0.0))
    ha_2020 = float(series.get(2020, 0.0))

    recent = acr[pd.to_numeric(acr["anno"], errors="coerce") >= 2020]
    median_patch = float(recent["area"].median()) if not recent.empty else 0.0
    mean_patch = float(recent["area"].mean()) if not recent.empty else 0.0
    alerts_2025 = int(len(acr[pd.to_numeric(acr["anno"], errors="coerce") == 2025]))

    by_acr = acr.groupby("codigo")["area"].sum().sort_values(ascending=False)
    top_code = str(by_acr.index[0]) if not by_acr.empty else "ACR_CHU"
    top_name = ACR_NOMBRES.get(top_code, top_code)

    if trend_20_24 is not None and trend_20_24 < 0:
        headline = "Reducción sostenida de la deforestación"
        trend_label = f"Tendencia 2020–2024: {_fmt_pct(trend_20_24)}"
    elif trend_20_24 is not None:
        headline = "Incremento reciente de alertas"
        trend_label = f"Tendencia 2020–2024: {_fmt_pct(trend_20_24)}"
    else:
        headline = "Patrón de parches de baja magnitud"
        trend_label = "Serie temporal en consolidación"

    summary = (
        f"Cusco presenta <strong>{headline.lower()}</strong>: la serie oficial pasó de "
        f"<strong>{_fmt_ha(ha_2020, 1)} ha</strong> (2020) a "
        f"<strong>{_fmt_ha(ha_2024, 1)} ha</strong> (2024)."
        f" El parche mediano reciente es de <strong>{median_patch:.2f} ha</strong>."
        f" La mayor presión acumulada corresponde a <strong>{top_name}</strong>."
    )

    return {
        "id": "cusco",
        "label": REGION_LABELS["cusco"],
        "accent": "#5cb85c",
        "title": headline,
        "icon": "fa-chart-line",
        "icon_color": "#27ae60",
        "summary": summary,
        "metrics": [
            {"icon": "fa-check-circle", "color": "#27ae60", "text": trend_label},
            {"icon": "fa-seedling", "color": "#2ecc71", "text": f"Parche mediano (2020+): {median_patch:.2f} ha"},
            {"icon": "fa-layer-group", "color": "#3498db", "text": f"Parche promedio (2020+): {mean_patch:.2f} ha"},
            {"icon": "fa-bell", "color": "#8e44ad", "text": f"Alertas ACR 2025: {_fmt_int(alerts_2025)}"},
        ],
        "modal": {
            "title": "CUSCO — Análisis regional",
            "stats": [
                [_fmt_pct(trend_20_24) if trend_20_24 is not None else "—", "Cambio 2020 → 2024", "#e8f5e9", "#27ae60"],
                [f"{median_patch:.2f} ha", "Parche mediano reciente", "#e1f5fe", "#2196f3"],
                [_fmt_ha(ha_2024, 1), "Deforestación ACR 2024", "#f3e5f5", "#8e44ad"],
            ],
            "sections": [
                {
                    "title": "Distribución acumulada por ACR",
                    "html": _acr_ranking_html(acr, "cusco"),
                },
                {
                    "title": "Lectura territorial",
                    "html": (
                        "<p>La deforestación en Cusco se concentra en <strong>parches pequeños y dispersos</strong>, "
                        "típicos de valles y franjas agrícolas de montaña, con menor presión que la selva baja "
                        "de Loreto y San Martín.</p>"
                        f"<p>En 2025 se detectaron <strong>{_fmt_int(alerts_2025)}</strong> alertas en territorios ACR.</p>"
                    ),
                },
            ],
        },
    }


def _acr_ranking_html(df: pd.DataFrame, depto: str) -> str:
    acr = df[df["codigo"].str.startswith("ACR_")].groupby("codigo")["area"].sum().sort_values(ascending=False)
    if acr.empty:
        return "<p>Sin datos disponibles.</p>"
    items = []
    for code, ha in acr.items():
        name = ACR_NOMBRES.get(str(code), str(code))
        items.append(f"<li><strong>{name}:</strong> {_fmt_ha(float(ha), 1)} ha acumuladas</li>")
    return "<ol>" + "".join(items) + "</ol>"


def region_insights(centroides_df: pd.DataFrame) -> dict:
    if centroides_df.empty:
        return {"regions": [], "updated_from": "centroides", "periodo": "2001-2025"}

    df = centroides_df.copy()
    df["area"] = pd.to_numeric(df["area"], errors="coerce").fillna(0.0)

    regions = [
        _build_loreto(df),
        _build_san_martin(df),
        _build_cusco(df),
    ]
    return {
        "regions": regions,
        "updated_from": "centroides_deforestacion.csv",
        "periodo": "2001-2025",
    }
