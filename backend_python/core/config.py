"""
Configuración central — equivalente a la sección CONFIGURACIÓN de global.R
y a las constantes de rutas en utils/cargar_datos.R.
"""
from pathlib import Path

# Raíz del proyecto Shiny (un nivel arriba de backend_python)
PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = PROJECT_ROOT / "data"

# Equivalente a options(scipen=999) — evitar notación científica en JSON
JSON_FLOAT_FORMAT = "%.6f"

# Mapeo ACR → archivo RDS (utils/cargar_datos.R :: cargar_geometrias_acr)
ACR_GEOMETRY_FILES: dict[str, tuple[str, str]] = {
    "ACR_AA": ("acr_aa.rds", "geometrias_acr"),
    "ACR_ANPCH": ("acr_anpch.rds", "geometrias_acr"),
    "ACR_CTT": ("acr_ctt.rds", "geometrias_acr"),
    "ACR_MK": ("acr_mk.rds", "geometrias_acr"),
    "ACR_BSM": ("ACR_Bosques_de_Shunté_y_Mishollo.rds", "geometrias_acr"),
    "ACR_CE": ("ACR_Cordillera_Escalera.rds", "geometrias_acr"),
    "ACR_CHQ": ("ACR_Choquequirao.rds", "geometrias_acr"),
    "ACR_CHU": ("ACR_Chuyapi_Urusayhua.rds", "geometrias_acr"),
    "ACR_QK": ("ACR_Qeros_Kosnipata.rds", "geometrias_acr"),
}

# ZI Loreto/San Martín + ZI_ACR para Cusco (cargar_geometrias_zi)
ZI_GEOMETRY_FILES: dict[str, tuple[str, str]] = {
    "ZI_AA": ("zi_aa.rds", "geometrias_zi"),
    "ZI_ANPCH": ("zi_anpch.rds", "geometrias_zi"),
    "ZI_CTT": ("zi_ctt.rds", "geometrias_zi"),
    "ZI_MK": ("zi_mk.rds", "geometrias_zi"),
    "ZI_BSM": ("ZI_Bosques_de_Shunté_y_Mishollo.rds", "geometrias_zi"),
    "ZI_CE": ("ZI_Cordillera_Escalera.rds", "geometrias_zi"),
}

ZI_ACR_CUSCO_FILE = ("ZI_ACR.rds", "geometrias_zi")
ZI_ACR_CUSCO_CODES = {
    "ACR07": "ZI_CHQ",
    "ACR26": "ZI_CHU",
    "ACR30": "ZI_QK",
}

LIMITES_FILES = {
    "loreto": ("loreto.rds", "limites"),
    "san_martin": ("san_martin.rds", "limites"),
    "cuzco": ("cuzco.rds", "limites"),
}

# global.R :: archivos_defo_acr / archivos_defo_zi
DEFO_ACR_FILES: dict[str, str] = {
    "ACR_AA": "data/deforestacion_ACR_AA.rds",
    "ACR_ANPCH": "data/deforestacion_ACR_ANPCH.rds",
    "ACR_CTT": "data/deforestacion_ACR_CTT.rds",
    "ACR_MK": "data/deforestacion_ACR_MK.rds",
    "ACR_BSM": "data/deforestacion_ACR_BSM.rds",
    "ACR_CE": "data/deforestacion_ACR_CE.rds",
    "ACR_CHQ": "data/deforestacion_ACR_CHQ.rds",
    "ACR_CHU": "data/deforestacion_ACR_CHU.rds",
    "ACR_QK": "data/deforestacion_ACR_QK.rds",
}

DEFO_ZI_FILES: dict[str, str] = {
    "ZI_CHQ": "data/deforestacion_ZI_CHQ.rds",
    "ZI_CHU": "data/deforestacion_ZI_CHU.rds",
    "ZI_QK": "data/deforestacion_ZI_QK.rds",
}

# global.R — paletas (para futuro frontend)
COLOR_ACR = {
    "ACR_AA": "#f1c40f",
    "ACR_ANPCH": "#f39c12",
    "ACR_MK": "#f4d03f",
    "ACR_CTT": "#f7dc6f",
    "ACR_BSM": "#f8c471",
    "ACR_CE": "#f5b041",
    "ACR_CHQ": "#f9e79f",
    "ACR_CHU": "#f7dc6f",
    "ACR_QK": "#f1c40f",
}

CAUSAS_ORDEN = [
    "Agricultura",
    "Extracción forestal",
    "Transporte",
    "Minería",
    "Hidrocarburos",
    "Incendio Antrópico",
    "Ganadería",
    "Ocupación humana",
    "Turismo",
    "Energía",
    "Otros",
]

DEPARTAMENTO_MAP = {
    "loreto": "Loreto",
    "san_martin": "San Martín",
    "cusco": "Cusco",
    "todos": None,
}
