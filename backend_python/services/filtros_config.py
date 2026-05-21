"""Opciones de filtros — equivalente a mod_filtros.R observeEvent(departamento)"""

ACR_OPCIONES_TODOS = {
    "LORETO": {
        "ACR Ampiyacu Apayacu": "ACR_AA",
        "ACR Alto Nanay – Pintuyacu Chambira": "ACR_ANPCH",
        "ACR Maijuna Kichwa": "ACR_MK",
        "ACR Comunal Tamshiyacu Tahuayo": "ACR_CTT",
    },
    "SAN MARTÍN": {
        "ACR Bosques de Shunté y Mishollo": "ACR_BSM",
        "ACR Cordillera Escalera": "ACR_CE",
    },
    "CUSCO": {
        "ACR Choquequirao": "ACR_CHQ",
        "ACR Chuyapi Urusayhua": "ACR_CHU",
        "ACR Q'eros Kosñipata": "ACR_QK",
    },
}

ACR_OPCIONES_POR_DEPTO = {
    "todos": ACR_OPCIONES_TODOS,
    "loreto": {"LORETO": ACR_OPCIONES_TODOS["LORETO"]},
    "san_martin": {"SAN MARTÍN": ACR_OPCIONES_TODOS["SAN MARTÍN"]},
    "cusco": {"CUSCO": ACR_OPCIONES_TODOS["CUSCO"]},
}
