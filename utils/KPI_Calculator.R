# ========================================
# UTILS/KPI_CALCULATOR.R
# Funciones auxiliares para calcular KPIs
# ========================================

#' Calcular total de hectáreas deforestadas
#' 
#' @param datos DataFrame con columnas: Antropico, Perdida_natural, Falsa_alerta
#' @return Valor numérico del total en hectáreas
calcular_total_hectareas <- function(datos) {
  if (is.null(datos) || nrow(datos) == 0) {
    return(0)
  }
  
  total <- sum(datos$Total, na.rm = TRUE)
  return(round(total, 2))
}

#' Calcular variación porcentual entre dos períodos
#' 
#' @param datos_actuales Datos del período actual
#' @param datos_anteriores Datos del período anterior
#' @return Porcentaje de cambio
calcular_variacion_periodo <- function(datos_actuales, datos_anteriores) {
  total_actual <- sum(datos_actuales$Total, na.rm = TRUE)
  total_anterior <- sum(datos_anteriores$Total, na.rm = TRUE)
  
  if (total_anterior == 0) {
    return(0)
  }
  
  variacion <- ((total_actual - total_anterior) / total_anterior) * 100
  return(round(variacion, 1))
}

#' Calcular porcentaje de deforestación dentro de ACRs
#' 
#' @param datos_acr Datos de ACRs
#' @param datos_total Datos totales (ACRs + ZI + fuera)
#' @return Porcentaje
calcular_porcentaje_acr <- function(datos_acr, datos_total) {
  total_acr <- sum(datos_acr$Total, na.rm = TRUE)
  total_general <- sum(datos_total$Total, na.rm = TRUE)
  
  if (total_general == 0) {
    return(0)
  }
  
  porcentaje <- (total_acr / total_general) * 100
  return(round(porcentaje, 1))
}

#' Identificar la causa principal de deforestación
#' 
#' @param datos_causas DataFrame con columnas: Causa, Area_Ha
#' @return String con el nombre de la causa principal
identificar_causa_principal <- function(datos_causas) {
  if (is.null(datos_causas) || nrow(datos_causas) == 0) {
    return("Sin datos")
  }
  
  causa_principal <- datos_causas %>%
    arrange(desc(Area_Ha)) %>%
    slice(1) %>%
    pull(Causa)
  
  return(as.character(causa_principal))
}

#' Calcular estadísticas de tendencia temporal
#' 
#' @param datos_temporales DataFrame con columnas: Anio, Deforestacion_ha
#' @return Lista con estadísticas: pendiente, r2, prediccion_5anios
calcular_tendencia_temporal <- function(datos_temporales) {
  if (nrow(datos_temporales) < 3) {
    return(list(
      pendiente = 0,
      r2 = 0,
      prediccion_5anios = 0
    ))
  }
  
  # Ajustar modelo lineal
  modelo <- lm(Deforestacion_ha ~ Anio, data = datos_temporales)
  
  # Extraer estadísticas
  pendiente <- coef(modelo)[2]
  r2 <- summary(modelo)$r.squared
  
  # Predecir próximos 5 años
  ultimo_anio <- max(datos_temporales$Anio)
  anios_futuros <- data.frame(Anio = (ultimo_anio + 1):(ultimo_anio + 5))
  predicciones <- predict(modelo, newdata = anios_futuros)
  prediccion_5anios <- sum(predicciones)
  
  return(list(
    pendiente = round(pendiente, 2),
    r2 = round(r2, 3),
    prediccion_5anios = round(prediccion_5anios, 0),
    direccion = ifelse(pendiente > 0, "creciente", "decreciente")
  ))
}

#' Generar resumen estadístico completo para KPIs
#' 
#' @param filtros Vector con nombres de ACRs seleccionadas
#' @param depto Departamento seleccionado
#' @param ambito Ámbito (acr, zi, ambos)
#' @return Lista con todos los KPIs calculados
generar_resumen_kpis <- function(filtros = NULL, depto = "todos", ambito = "acr") {
  
  # Obtener datos según filtros
  if (!is.null(filtros) && length(filtros) > 0) {
    if (is.null(ambito) || ambito == "acr") {
      datos <- obtener_datos_filtrados(filtros, depto, "acr")
    } else if (ambito == "zi") {
      datos <- obtener_datos_filtrados(filtros, depto, "zi")
    } else {
      datos_acr <- obtener_datos_filtrados(filtros, depto, "acr")
      datos_zi <- obtener_datos_filtrados(filtros, depto, "zi")
      datos <- bind_rows(datos_acr, datos_zi)
    }
  } else {
    if (ambito == "zi") {
      datos <- obtener_datos_filtrados(NULL, depto, "zi")
    } else if (ambito == "acr") {
      datos <- obtener_datos_filtrados(NULL, depto, "acr")
    } else {
      datos_acr <- obtener_datos_filtrados(NULL, depto, "acr")
      datos_zi <- obtener_datos_filtrados(NULL, depto, "zi")
      datos <- bind_rows(datos_acr, datos_zi)
    }
  }
  
  # Calcular KPIs
  total_ha <- calcular_total_hectareas(datos)
  
  # Obtener causa principal
  ambito_val <- if (is.null(ambito)) "acr" else ambito
  causas <- obtener_causas_filtradas(filtros, depto, ambito_val)
  causa_principal <- identificar_causa_principal(causas)
  
  # Calcular porcentajes por categoría
  total_antropico <- sum(datos$Antropico, na.rm = TRUE)
  total_natural <- sum(datos$Perdida_natural, na.rm = TRUE)
  total_falsa <- sum(datos$Falsa_alerta, na.rm = TRUE)
  
  pct_antropico <- ifelse(total_ha > 0, round((total_antropico / total_ha) * 100, 1), 0)
  pct_natural <- ifelse(total_ha > 0, round((total_natural / total_ha) * 100, 1), 0)
  pct_falsa <- ifelse(total_ha > 0, round((total_falsa / total_ha) * 100, 1), 0)
  
  # Retornar lista con todos los KPIs
  return(list(
    total_hectareas = total_ha,
    total_antropico = total_antropico,
    total_natural = total_natural,
    total_falsa = total_falsa,
    pct_antropico = pct_antropico,
    pct_natural = pct_natural,
    pct_falsa = pct_falsa,
    causa_principal = causa_principal,
    n_acrs = nrow(datos),
    fecha_calculo = Sys.Date()
  ))
}

#' Formatear número con separadores de miles
#' 
#' @param numero Valor numérico
#' @return String formateado
formatear_numero <- function(numero) {
  format(round(numero, 0), big.mark = ",", scientific = FALSE)
}

#' Generar texto de interpretación para variación
#' 
#' @param variacion Porcentaje de variación
#' @return Lista con texto, color e ícono
interpretar_variacion <- function(variacion) {
  if (variacion > 10) {
    return(list(
      texto = "Incremento significativo",
      color = "#d9534f",
      icono = "arrow-up",
      alerta = "CRÍTICO"
    ))
  } else if (variacion > 5) {
    return(list(
      texto = "Incremento moderado",
      color = "#f0ad4e",
      icono = "arrow-up",
      alerta = "ALERTA"
    ))
  } else if (variacion > 0) {
    return(list(
      texto = "Incremento leve",
      color = "#f0ad4e",
      icono = "arrow-up",
      alerta = "PRECAUCIÓN"
    ))
  } else if (variacion > -5) {
    return(list(
      texto = "Reducción leve",
      color = "#5cb85c",
      icono = "arrow-down",
      alerta = "ESTABLE"
    ))
  } else {
    return(list(
      texto = "Reducción significativa",
      color = "#5cb85c",
      icono = "arrow-down",
      alerta = "POSITIVO"
    ))
  }
}