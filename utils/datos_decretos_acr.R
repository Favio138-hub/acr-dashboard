# ══════════════════════════════════════════════════════════════
# 📜 DATOS DE DECRETOS SUPREMOS - ACRs
# Información legal de creación de cada ACR
# ══════════════════════════════════════════════════════════════

# Data frame con información de decretos
acr_decretos <- data.frame(
  codigo = c(
    # LORETO
    "ACR_AA",
    "ACR_ANPCH",
    "ACR_CTT",
    "ACR_MK",
    
    # SAN MARTÍN
    "ACR_BSM",
    "ACR_CE",
    
    # CUSCO
    "ACR_CHQ",
    "ACR_CHU",
    "ACR_QK"
  ),
  
  nombre_completo = c(
    # LORETO
    "ACR Alto Nanay - Pintuyacu Chambira",
    "ACR Ampiyacu Apayacu",
    "ACR Comunal Tamshiyacu Tahuayo",
    "ACR Maijuna Kichwa",
    
    # SAN MARTÍN
    "ACR Bosques de Shunté y Mishollo",
    "ACR Cordillera Escalera",
    
    # CUSCO
    "ACR Choquequirao",
    "ACR Ausangate",
    "ACR Tres Cañones"
  ),
  
  decreto_supremo = c(
    # LORETO
    "D.S. N° 005-2015-MINAM",
    "D.S. N° 006-2010-MINAM", 
    "D.S. N° 010-2009-MINAM",
    "D.S. N° 008-2015-MINAM",
    
    # SAN MARTÍN
    "D.S. N° 011-2017-MINAM",
    "D.S. N° 045-2005-AG",
    
    # CUSCO
    "D.S. N° 016-2010-MINAM",
    "D.S. N° 009-2014-MINAM",
    "D.S. N° 008-2014-MINAM"
  ),
  
  fecha_creacion = c(
    # LORETO
    "29/01/2015",
    "14/01/2010",
    "20/05/2009",
    "29/01/2015",
    
    # SAN MARTÍN
    "04/08/2017",
    "22/12/2005",
    
    # CUSCO
    "08/04/2010",
    "21/01/2014",
    "21/01/2014"
  ),
  
  superficie_ha = c(
    # LORETO
    943.87,
    434.13,
    420.08,
    391.04,
    
    # SAN MARTÍN
    28588.86,
    149870.23,
    
    # CUSCO
    103814.39,
    66514.49,
    39345.85
  ),
  
  region = c(
    # LORETO
    "Loreto",
    "Loreto",
    "Loreto",
    "Loreto",
    
    # SAN MARTÍN
    "San Martín",
    "San Martín",
    
    # CUSCO
    "Cusco",
    "Cusco",
    "Cusco"
  ),
  
  stringsAsFactors = FALSE
)

# Función para obtener info de decreto
obtener_info_decreto <- function(codigo_acr) {
  info <- acr_decretos[acr_decretos$codigo == codigo_acr, ]
  
  if (nrow(info) == 0) {
    return(list(
      decreto = "N/A",
      fecha = "N/A",
      nombre = codigo_acr
    ))
  }
  
  return(list(
    decreto = info$decreto_supremo,
    fecha = info$fecha_creacion,
    nombre = info$nombre_completo,
    superficie = info$superficie_ha,
    region = info$region
  ))
}

# Función para generar HTML del decreto (para popup)
generar_html_decreto <- function(codigo_acr) {
  info <- obtener_info_decreto(codigo_acr)
  
  html <- sprintf(
    '<div style="margin-top: 10px; padding-top: 10px; border-top: 2px solid #34495e;">
      <p style="margin: 5px 0; font-size: 13px;">
        <strong style="color: #2c3e50;">📜 Decreto Supremo:</strong><br>
        <span style="color: #16a085; font-weight: 600;">%s</span>
      </p>
      <p style="margin: 5px 0; font-size: 13px;">
        <strong style="color: #2c3e50;">📅 Fecha de Creación:</strong><br>
        <span style="color: #7f8c8d;">%s</span>
      </p>
    </div>',
    info$decreto,
    info$fecha
  )
  
  return(html)
}

cat("✅ Datos de decretos cargados exitosamente\n")
cat(sprintf("   Total de ACRs con información legal: %d\n", nrow(acr_decretos)))