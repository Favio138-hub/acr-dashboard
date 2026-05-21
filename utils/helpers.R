# ========================================
# HELPERS.R - FUNCIONES BASE
# ========================================

#' Obtener datos filtrados (FUNCIÓN BASE - SIN CACHÉ)
#' 
#' @param filtros Vector de ACRs seleccionados
#' @param departamento Departamento seleccionado
#' @param tipo "acr" o "zi"
#' @return Data.frame filtrado
obtener_datos_filtrados <- function(filtros = NULL, departamento = "todos", tipo = "acr") {
  
  # ========================================
  # PASO 1: SELECCIONAR DATASET BASE
  # ========================================
  
  if (tipo == "acr") {
    df <- bind_rows(acr_categoria, acr_categoria_sm, acr_categoria_cz)
  } else {
    df <- bind_rows(zi_categoria, zi_categoria_sm, zi_categoria_cz)
  }
  
  # Agregar columna Departamento si no existe
  if (!"Departamento" %in% names(df)) {
    df$Departamento <- "Desconocido"
  }
  
  # ========================================
  # PASO 2: FILTRAR POR DEPARTAMENTO
  # ========================================
  
  if (!is.null(departamento) && departamento != "todos") {
    if (departamento == "loreto") {
      df <- df[df$Departamento == "Loreto", ]
    } else if (departamento == "san_martin") {
      df <- df[df$Departamento == "San Martín", ]
    } else if (departamento == "cusco") {
      df <- df[df$Departamento == "Cusco", ]
    }
  }
  
  # ========================================
  # PASO 3: FILTRAR POR ACR ESPECÍFICOS
  # ========================================
  
  if (!is.null(filtros) && length(filtros) > 0) {
    df <- df[df$ACR %in% filtros, ]
  }
  
  return(df)
}

#' Obtener causas antrópicas según filtros (FUNCIÓN BASE - SIN CACHÉ)
#' 
#' @param filtros Vector de ACRs seleccionados
#' @param departamento Departamento seleccionado
#' @param ambito "acr", "zi" o "ambos"
#' @return Data.frame con causas
obtener_causas_filtradas <- function(filtros = NULL, departamento = "todos", ambito = "acr") {
  
  # Estructura base de causas
  estructura_causas <- data.frame(
    Causa = c("Agricultura", "Extracción forestal", "Transporte", "Minería", 
              "Hidrocarburos", "Incendio Antrópico", "Ganadería", 
              "Ocupación humana", "Turismo", "Energía", "Otros"),
    Area_Ha = rep(0, 11),
    stringsAsFactors = FALSE
  )
  
  # Determinar listas según departamento
  base_acr <- estructura_causas
  base_zi <- estructura_causas
  causas_acr_list <- list()
  causas_zi_list <- list()
  
  if (!is.null(departamento) && departamento != "todos") {
    if (departamento == "loreto") {
      base_acr <- causas_acr
      base_zi <- causas_zi
      causas_acr_list <- causas_por_acr
      causas_zi_list <- causas_por_zi
    } else if (departamento == "san_martin") {
      base_acr <- causas_acr_sm
      base_zi <- causas_zi_sm
      causas_acr_list <- causas_por_acr_sm
      causas_zi_list <- causas_por_zi_sm
    } else if (departamento == "cusco") {
      base_acr <- causas_acr_cz
      base_zi <- causas_zi_cz
      causas_acr_list <- causas_por_acr_cz
      causas_zi_list <- causas_por_zi_cz
    }
  } else {
    # Combinar todas las regiones
    for (i in 1:nrow(base_acr)) {
      causa <- base_acr$Causa[i]
      base_acr$Area_Ha[i] <- 
        sum(causas_acr$Area_Ha[causas_acr$Causa == causa], na.rm = TRUE) +
        sum(causas_acr_sm$Area_Ha[causas_acr_sm$Causa == causa], na.rm = TRUE) +
        sum(causas_acr_cz$Area_Ha[causas_acr_cz$Causa == causa], na.rm = TRUE)
    }
    
    for (i in 1:nrow(base_zi)) {
      causa <- base_zi$Causa[i]
      base_zi$Area_Ha[i] <- 
        sum(causas_zi$Area_Ha[causas_zi$Causa == causa], na.rm = TRUE) +
        sum(causas_zi_sm$Area_Ha[causas_zi_sm$Causa == causa], na.rm = TRUE) +
        sum(causas_zi_cz$Area_Ha[causas_zi_cz$Causa == causa], na.rm = TRUE)
    }
    
    causas_acr_list <- c(causas_por_acr, causas_por_acr_sm, causas_por_acr_cz)
    causas_zi_list <- c(causas_por_zi, causas_por_zi_sm, causas_por_zi_cz)
  }
  
  # ========================================
  # PROCESAR FILTROS
  # ========================================
  
  if (!is.null(filtros) && length(filtros) > 0) {
    if (ambito == "acr") {
      datos_causas <- estructura_causas
      for (acr in filtros) {
        if (acr %in% names(causas_acr_list)) {
          datos_tmp <- causas_acr_list[[acr]]
          for (i in 1:nrow(datos_causas)) {
            causa_match <- datos_tmp$Area_Ha[datos_tmp$Causa == datos_causas$Causa[i]]
            if (length(causa_match) > 0 && !is.na(causa_match[1])) {
              datos_causas$Area_Ha[i] <- datos_causas$Area_Ha[i] + causa_match[1]
            }
          }
        }
      }
    } else if (ambito == "zi") {
      datos_causas <- estructura_causas
      for (acr in filtros) {
        zi_key <- gsub("^ACR_", "ZI_", acr)
        if (zi_key %in% names(causas_zi_list)) {
          datos_tmp <- causas_zi_list[[zi_key]]
          for (i in 1:nrow(datos_causas)) {
            causa_match <- datos_tmp$Area_Ha[datos_tmp$Causa == datos_causas$Causa[i]]
            if (length(causa_match) > 0 && !is.na(causa_match[1])) {
              datos_causas$Area_Ha[i] <- datos_causas$Area_Ha[i] + causa_match[1]
            }
          }
        }
      }
    } else {
      # Ambos
      datos_causas <- estructura_causas
      for (acr in filtros) {
        if (acr %in% names(causas_acr_list)) {
          datos_tmp <- causas_acr_list[[acr]]
          for (i in 1:nrow(datos_causas)) {
            causa_match <- datos_tmp$Area_Ha[datos_tmp$Causa == datos_causas$Causa[i]]
            if (length(causa_match) > 0 && !is.na(causa_match[1])) {
              datos_causas$Area_Ha[i] <- datos_causas$Area_Ha[i] + causa_match[1]
            }
          }
        }
      }
      for (acr in filtros) {
        zi_key <- gsub("^ACR_", "ZI_", acr)
        if (zi_key %in% names(causas_zi_list)) {
          datos_tmp <- causas_zi_list[[zi_key]]
          for (i in 1:nrow(datos_causas)) {
            causa_match <- datos_tmp$Area_Ha[datos_tmp$Causa == datos_causas$Causa[i]]
            if (length(causa_match) > 0 && !is.na(causa_match[1])) {
              datos_causas$Area_Ha[i] <- datos_causas$Area_Ha[i] + causa_match[1]
            }
          }
        }
      }
    }
  } else {
    if (ambito == "zi") {
      datos_causas <- base_zi
    } else if (ambito == "acr") {
      datos_causas <- base_acr
    } else {
      datos_causas <- estructura_causas
      datos_causas$Area_Ha <- base_acr$Area_Ha + base_zi$Area_Ha
    }
  }
  
  # Filtrar valores > 0
  datos_causas <- datos_causas[datos_causas$Area_Ha > 0, ]
  
  return(datos_causas)
}

#' Formatear número con separador de miles
#'
#' @param num Número a formatear
#' @return String formateado
formatear_numero <- function(num) {
  if (is.na(num) || is.null(num)) return("0.00")
  format(round(num, 2), big.mark = ",", nsmall = 2)
}