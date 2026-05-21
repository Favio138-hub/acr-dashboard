"""Conversión DataFrame → JSON ligero para el frontend."""
from __future__ import annotations

import math
from typing import Any

import numpy as np
import pandas as pd


def _sanitize_value(val: Any) -> Any:
    if val is None or (isinstance(val, float) and (math.isnan(val) or math.isinf(val))):
        return None
    if isinstance(val, (np.integer, np.floating)):
        return float(val) if isinstance(val, np.floating) else int(val)
    if isinstance(val, (pd.Timestamp,)):
        return val.isoformat()
    return val


def dataframe_to_records(df: pd.DataFrame) -> list[dict[str, Any]]:
    """Equivalente a jsonlite::toJSON(df, dataframe='rows') en R."""
    if df is None or df.empty:
        return []
    records = df.replace({np.nan: None}).to_dict(orient="records")
    return [{k: _sanitize_value(v) for k, v in row.items()} for row in records]
