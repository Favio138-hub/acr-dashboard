# ========================================
# UTILS/TRANSLATIONS.R
# Sistema de traducciones español-inglés
# ========================================

# Diccionario de traducciones
translations <- list(
  es = list(
    # Tabs principales
    dashboard = "Dashboard",
    metodologia = "Metodología",
    reportes = "Reportes y Descargas",
    tendencias = "Tendencias",
    
    # Hero section Dashboard
    hero_title_red = "Conservación de la biodiversidad y lucha contra el cambio climático",
    hero_title_main = "Monitoreo de la deforestación en Áreas de Conservación Regional de la Amazonía Peruana",
    hero_description = "En el marco de la asistencia técnica del Programa GFP Subnacional de la Cooperación Económica Suiza – SECO, implementado por el Basel Institute on Governance, y en coordinación con los Gobiernos Regionales de Loreto, San Martín y Cusco, se desarrolló el Dashboard de Línea Base de Deforestación de nueve Áreas de Conservación Regional, basado en la evaluación de información satelital de 24 años (2001 – 2024), así como herramienta clave para el monitoreo y la protección de los ecosistemas amazónicos.",
    
    # KPIs
    kpi_hectareas = "HECTÁREAS DEFORESTADAS",
    kpi_variacion = "VARIACIÓN ANUAL",
    kpi_porcentaje = "% DEL ÁREA TOTAL",
    kpi_causa = "CAUSA PRINCIPAL",
    kpi_click_detalles = "🔍 Click para ver detalles",
    indicadores_clave = "Indicadores Clave",
    
    # Filtros
    filtros_titulo = "Filtros de Análisis",
    departamento = "Departamento:",
    todos_departamentos = "Todos los departamentos",
    ambito_analisis = "Ámbito de Análisis:",
    ambito_acr = "ACR (Área de Conservación Regional)",
    ambito_zi = "ZI (Zona de Influencia)",
    ambito_ambos = "Ambos (ACR + ZI)",
    seleccionar_acr = "Seleccionar ACR(s):",
    rango_anios = "Rango de Años:",
    btn_aplicar = "Aplicar Filtros",
    btn_limpiar = "Limpiar Filtros",
    
    # Mapa
    mapa_titulo = "Mapa Interactivo de Deforestación",
    
    # Gráficos
    graficos_titulo = "Análisis Gráfico",
    deforestacion_por_anio = "Deforestación por Año",
    deforestacion_por_acr = "Deforestación por ACR",
    distribucion_causas = "Distribución de Causas",
    tendencia_temporal = "Tendencia Temporal",
    
    # Tablas
    tablas_titulo = "Datos Tabulares",
    tabla_resumen = "Resumen General",
    tabla_detallada = "Datos Detallados",
    descargar_excel = "Descargar Excel",
    descargar_csv = "Descargar CSV",
    
    # Datos Relevantes por Región
    datos_relevantes = "Datos Relevantes por Región",
    frentes_activos = "Frentes Activos de Deforestación",
    zona_critica = "Zona crítica: Eje vial Iquitos-Nauta",
    tendencia_decada = "Tendencia: +18.6% última década",
    impacto_acr = "Impacto: 4 ACRs con presión alta",
    ver_analisis = "Ver análisis completo",
    
    # Tendencias
    tendencias_hero_red = "Análisis de Tendencias Temporales",
    tendencias_hero_main = "Análisis histórico de deforestación en ACRs",
    tendencias_hero_desc = "Análisis histórico de la deforestación en las ACRs del Programa GFP Subnacional (2001-2024). Visualización de tendencias temporales y análisis de patrones de deforestación basados en series de tiempo.",
    
    config_analisis = "Configuración de Análisis",
    tipo_analisis = "Tipo de Análisis:",
    tendencia_general = "Tendencia General",
    por_acr_individual = "Por ACR Individual",
    comparativa_acrs = "Comparativa entre ACRs",
    seleccionar_acr_s = "Seleccionar ACR(s):",
    mostrar_tendencia = "Mostrar línea de tendencia",
    btn_generar_analisis = "🔍 Generar Análisis",
    
    analisis_tendencias_title = "Análisis de Tendencias",
    analisis_tendencias_msg = "Configura los parámetros en el panel izquierdo y haz clic en 'Generar Análisis' para visualizar las tendencias de deforestación.",
    grafico_tendencia = "Gráfico de Tendencia Temporal",
    
    # Reportes
    reportes_titulo = "Reportes, datos y metodologías",
    reportes_desc = "Shapefiles, GeoTIFF, CSV, informes PDF y notas metodológicas.",
    descargar_datos = "Descargar datos",
    ver_informe = "Ver informe",
    ver = "Ver",
    pdf = "PDF",
    actualizado = "Actualizado:",
    
    # Meses
    enero = "Enero",
    febrero = "Febrero",
    marzo = "Marzo",
    abril = "Abril",
    mayo = "Mayo",
    junio = "Junio",
    julio = "Julio",
    agosto = "Agosto",
    septiembre = "Septiembre",
    octubre = "Octubre",
    noviembre = "Noviembre",
    diciembre = "Diciembre",
    
    # Unidades
    hectareas = "ha",
    año = "Año",
    años = "Años"
  ),
  
  en = list(
    # Main tabs
    dashboard = "Dashboard",
    metodologia = "Methodology",
    reportes = "Reports & Downloads",
    tendencias = "Trends",
    
    # Hero section Dashboard
    hero_title_red = "Biodiversity conservation and fight against climate change",
    hero_title_main = "Deforestation Monitoring in Regional Conservation Areas of the Peruvian Amazon",
    hero_description = "Within the framework of technical assistance from the GFP Subnational Program of the Swiss Economic Cooperation – SECO, implemented by the Basel Institute on Governance, and in coordination with the Regional Governments of Loreto, San Martín and Cusco, the Deforestation Baseline Dashboard for nine Regional Conservation Areas was developed, based on the evaluation of satellite information from 24 years (2001 – 2024), as well as a key tool for monitoring and protecting Amazonian ecosystems.",
    
    # KPIs
    kpi_hectareas = "DEFORESTED HECTARES",
    kpi_variacion = "ANNUAL VARIATION",
    kpi_porcentaje = "% OF TOTAL AREA",
    kpi_causa = "MAIN CAUSE",
    kpi_click_detalles = "🔍 Click for details",
    indicadores_clave = "Key Indicators",
    
    # Filters
    filtros_titulo = "Analysis Filters",
    departamento = "Department:",
    todos_departamentos = "All departments",
    ambito_analisis = "Analysis Scope:",
    ambito_acr = "RCA (Regional Conservation Area)",
    ambito_zi = "IZ (Influence Zone)",
    ambito_ambos = "Both (RCA + IZ)",
    seleccionar_acr = "Select RCA(s):",
    rango_anios = "Year Range:",
    btn_aplicar = "Apply Filters",
    btn_limpiar = "Clear Filters",
    
    # Map
    mapa_titulo = "Interactive Deforestation Map",
    
    # Charts
    graficos_titulo = "Graphical Analysis",
    deforestacion_por_anio = "Deforestation by Year",
    deforestacion_por_acr = "Deforestation by RCA",
    distribucion_causas = "Cause Distribution",
    tendencia_temporal = "Temporal Trend",
    
    # Tables
    tablas_titulo = "Tabular Data",
    tabla_resumen = "General Summary",
    tabla_detallada = "Detailed Data",
    descargar_excel = "Download Excel",
    descargar_csv = "Download CSV",
    
    # Relevant Data by Region
    datos_relevantes = "Relevant Data by Region",
    frentes_activos = "Active Deforestation Fronts",
    zona_critica = "Critical zone: Iquitos-Nauta road axis",
    tendencia_decada = "Trend: +18.6% last decade",
    impacto_acr = "Impact: 4 RCAs under high pressure",
    ver_analisis = "View full analysis",
    
    # Trends
    tendencias_hero_red = "Temporal Trend Analysis",
    tendencias_hero_main = "Historical deforestation analysis in RCAs",
    tendencias_hero_desc = "Historical analysis of deforestation in the RCAs of the GFP Subnational Program (2001-2024). Visualization of temporal trends and analysis of deforestation patterns based on time series.",
    
    config_analisis = "Analysis Configuration",
    tipo_analisis = "Analysis Type:",
    tendencia_general = "General Trend",
    por_acr_individual = "Individual RCA",
    comparativa_acrs = "RCA Comparison",
    seleccionar_acr_s = "Select RCA(s):",
    mostrar_tendencia = "Show trend line",
    btn_generar_analisis = "🔍 Generate Analysis",
    
    analisis_tendencias_title = "Trend Analysis",
    analisis_tendencias_msg = "Configure the parameters in the left panel and click 'Generate Analysis' to visualize deforestation trends.",
    grafico_tendencia = "Temporal Trend Chart",
    
    # Reports
    reportes_titulo = "Reports, data and methodologies",
    reportes_desc = "Shapefiles, GeoTIFF, CSV, PDF reports and methodological notes.",
    descargar_datos = "Download data",
    ver_informe = "View report",
    ver = "View",
    pdf = "PDF",
    actualizado = "Updated:",
    
    # Months
    enero = "January",
    febrero = "February",
    marzo = "March",
    abril = "April",
    mayo = "May",
    junio = "June",
    julio = "July",
    agosto = "August",
    septiembre = "September",
    octubre = "October",
    noviembre = "November",
    diciembre = "December",
    
    # Units
    hectareas = "ha",
    año = "Year",
    años = "Years"
  )
)

# Función para obtener traducción
t <- function(key, lang = "es") {
  if (!lang %in% c("es", "en")) lang <- "es"
  
  texto <- translations[[lang]][[key]]
  
  if (is.null(texto)) {
    return(key)  # Si no existe la traducción, devolver la clave
  }
  
  return(texto)
}