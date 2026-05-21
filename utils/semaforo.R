# ========================================
# UTILS/SEMAFORO.R
# Sistema de semáforo para tabla
# ========================================

#' Obtener emoji de semáforo según valor
#'
#' @param valor Valor numérico
#' @param tipo "ACR" o "Zona de Influencia"
#' @param columna "Antropico", "Perdida_natural" o "Falsa_alerta"
#' @return Emoji string
get_semaforo <- function(valor, tipo, columna) {
  if (is.null(valor) || is.na(valor) || !is.numeric(valor)) {
    return("")
  }
  
  if (tipo == "TOTAL") return("")
  
  if (columna == "Antropico") {
    if (tipo == "ACR") {
      if (valor < 150) return("🟢")
      if (valor < 250) return("🟡")
      return("🔴")
    } else {
      if (valor < 1000) return("🟢")
      if (valor < 1700) return("🟡")
      return("🔴")
    }
  } else if (columna == "Perdida_natural") {
    if (tipo == "ACR") {
      if (valor < 150) return("🟢")
      if (valor < 300) return("🟡")
      return("🔴")
    } else {
      if (valor < 200) return("🟢")
      if (valor < 500) return("🟡")
      return("🔴")
    }
  } else if (columna == "Falsa_alerta") {
    if (tipo == "ACR") {
      if (valor < 100) return("🟢")
      if (valor < 250) return("🟡")
      return("🔴")
    } else {
      if (valor < 600) return("🟢")
      if (valor < 900) return("🟡")
      return("🔴")
    }
  }
  
  return("")
}

#' Aplicar semáforo a un data.frame
#'
#' @param datos Data.frame con columnas: Tipo, Antropico, Perdida_natural, Falsa_alerta
#' @return Data.frame con columnas display agregadas
aplicar_semaforo_tabla <- function(datos) {
  
  datos$Antropico_display <- sapply(1:nrow(datos), function(i) {
    semaforo <- tryCatch({
      valor <- datos$Antropico[i]
      tipo <- datos$Tipo[i]
      if (is.na(valor) || is.null(valor) || !is.numeric(valor)) {
        return("")
      }
      get_semaforo(valor, tipo, "Antropico")
    }, error = function(e) {
      return("")
    })
    paste(semaforo, format(round(datos$Antropico[i], 2), big.mark = ","))
  })
  
  datos$Natural_display <- sapply(1:nrow(datos), function(i) {
    semaforo <- tryCatch({
      valor <- datos$Perdida_natural[i]
      tipo <- datos$Tipo[i]
      if (is.na(valor) || is.null(valor) || !is.numeric(valor)) {
        return("")
      }
      get_semaforo(valor, tipo, "Perdida_natural")
    }, error = function(e) {
      return("")
    })
    paste(semaforo, format(round(datos$Perdida_natural[i], 2), big.mark = ","))
  })
  
  datos$Falsa_display <- sapply(1:nrow(datos), function(i) {
    semaforo <- tryCatch({
      valor <- datos$Falsa_alerta[i]
      tipo <- datos$Tipo[i]
      if (is.na(valor) || is.null(valor) || !is.numeric(valor)) {
        return("")
      }
      get_semaforo(valor, tipo, "Falsa_alerta")
    }, error = function(e) {
      return("")
    })
    paste(semaforo, format(round(datos$Falsa_alerta[i], 2), big.mark = ","))
  })
  
  datos$Total_display <- format(round(datos$Total, 2), big.mark = ",")
  
  return(datos)
}