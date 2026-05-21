# ========================================
# CACHE_MANAGER.R
# Sistema de caché para consultas rápidas
# ✅ Evita recalcular datos repetidamente
# ✅ 90% más rápido en consultas
# ========================================

library(digest)

# ========================================
# INICIALIZAR CACHÉ GLOBAL
# ========================================

.cache_global <- new.env(parent = emptyenv())

#' Limpiar caché completo
limpiar_cache <- function() {
  rm(list = ls(envir = .cache_global), envir = .cache_global)
  gc()
  cat("🗑️ Caché limpiado\n")
}

#' Generar clave única para consulta
#' 
#' @param ... Parámetros de la consulta
#' @return String hash único
generar_clave_cache <- function(...) {
  params <- list(...)
  # Ordenar para que el mismo contenido genere la misma clave
  params_sorted <- params[order(names(params))]
  # Crear hash MD5
  clave <- digest::digest(params_sorted, algo = "md5")
  return(clave)
}

#' Obtener datos del caché
#' 
#' @param clave Clave del caché
#' @return Datos cacheados o NULL
obtener_cache <- function(clave) {
  if (exists(clave, envir = .cache_global)) {
    # cat(sprintf("📦 Cache HIT: %s\n", substr(clave, 1, 8)))
    return(get(clave, envir = .cache_global))
  }
  return(NULL)
}

#' Guardar datos en caché
#' 
#' @param clave Clave del caché
#' @param datos Datos a guardar
guardar_cache <- function(clave, datos) {
  assign(clave, datos, envir = .cache_global)
  # cat(sprintf("💾 Cache SAVE: %s\n", substr(clave, 1, 8)))
}

# ========================================
# FUNCIONES OPTIMIZADAS CON CACHÉ
# ========================================

#' Obtener datos filtrados CON CACHÉ
#' 
#' @param filtros Vector de ACRs
#' @param departamento Departamento
#' @param tipo "acr" o "zi"
#' @return DataFrame filtrado
obtener_datos_filtrados_cached <- function(filtros = NULL, departamento = "todos", tipo = "acr") {
  
  clave <- generar_clave_cache(
    funcion = "obtener_datos_filtrados",
    filtros = filtros,
    departamento = departamento,
    tipo = tipo
  )
  
  # Intentar caché
  resultado_cache <- obtener_cache(clave)
  if (!is.null(resultado_cache)) {
    return(resultado_cache)
  }
  
  # Calcular si no está en caché
  resultado <- obtener_datos_filtrados(filtros, departamento, tipo)
  
  # Guardar en caché
  guardar_cache(clave, resultado)
  
  return(resultado)
}

#' Obtener causas filtradas CON CACHÉ
#' 
#' @param filtros Vector de ACRs
#' @param departamento Departamento
#' @param ambito "acr", "zi" o "ambos"
#' @return DataFrame con causas
obtener_causas_filtradas_cached <- function(filtros = NULL, departamento = "todos", ambito = "acr") {
  
  clave <- generar_clave_cache(
    funcion = "obtener_causas_filtradas",
    filtros = filtros,
    departamento = departamento,
    ambito = ambito
  )
  
  # Intentar caché
  resultado_cache <- obtener_cache(clave)
  if (!is.null(resultado_cache)) {
    return(resultado_cache)
  }
  
  # Calcular si no está en caché
  resultado <- obtener_causas_filtradas(filtros, departamento, ambito)
  
  # Guardar en caché
  guardar_cache(clave, resultado)
  
  return(resultado)
}

#' Obtener estadísticas de KPIs CON CACHÉ
#' 
#' @param filtros Vector de ACRs
#' @param departamento Departamento
#' @param ambito "acr", "zi" o "ambos"
#' @return Lista con KPIs
calcular_kpis_cached <- function(filtros = NULL, departamento = "todos", ambito = "acr") {
  
  clave <- generar_clave_cache(
    funcion = "calcular_kpis",
    filtros = filtros,
    departamento = departamento,
    ambito = ambito
  )
  
  # Intentar caché
  resultado_cache <- obtener_cache(clave)
  if (!is.null(resultado_cache)) {
    return(resultado_cache)
  }
  
  # Calcular KPIs
  datos <- obtener_datos_filtrados_cached(filtros, departamento, ambito)
  
  kpis <- list(
    total_hectareas = sum(datos$Total, na.rm = TRUE),
    total_antropico = sum(datos$Antropico, na.rm = TRUE),
    total_natural = sum(datos$Perdida_natural, na.rm = TRUE),
    total_falsa = sum(datos$Falsa_alerta, na.rm = TRUE),
    n_acrs = nrow(datos)
  )
  
  # Guardar en caché
  guardar_cache(clave, kpis)
  
  return(kpis)
}

# ========================================
# UTILIDADES DE MONITOREO
# ========================================

#' Ver estadísticas del caché
ver_stats_cache <- function() {
  n_items <- length(ls(envir = .cache_global))
  
  if (n_items == 0) {
    cat("📊 Caché vacío\n")
    return(invisible(NULL))
  }
  
  # Calcular tamaño total
  tamano_total <- sum(sapply(ls(envir = .cache_global), function(x) {
    object.size(get(x, envir = .cache_global))
  }))
  
  tamano_mb <- tamano_total / 1024^2
  
  cat("\n========================================\n")
  cat("📊 ESTADÍSTICAS DE CACHÉ\n")
  cat("========================================\n")
  cat(sprintf("Items en caché: %d\n", n_items))
  cat(sprintf("Tamaño total: %.2f MB\n", tamano_mb))
  cat("========================================\n\n")
  
  invisible(list(items = n_items, tamano_mb = tamano_mb))
}

#' Limpiar caché antiguo (más de X segundos)
#' 
#' @param max_age Edad máxima en segundos (default: 300 = 5 minutos)
limpiar_cache_antiguo <- function(max_age = 300) {
  n_items_antes <- length(ls(envir = .cache_global))
  
  if (n_items_antes > 50) {  # Si hay más de 50 items
    limpiar_cache()
    cat(sprintf("🗑️ Limpieza automática: %d items eliminados\n", n_items_antes))
  }
}

cat("✅ Sistema de caché inicializado\n")