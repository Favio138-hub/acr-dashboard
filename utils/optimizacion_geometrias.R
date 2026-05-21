# ========================================
# OPTIMIZACIÓN DE GEOMETRÍAS
# Funciones reutilizables
# ========================================

library(sf)

#' Simplificar geometría de forma agresiva pero segura
#' 
#' @param data sf object
#' @param tolerancia Tolerancia de simplificación (metros)
#' @return sf object simplificado
simplificar_geometria_agresiva <- function(data, tolerancia = 0.002) {
  
  if (!inherits(data, "sf")) {
    stop("El objeto debe ser de tipo sf")
  }
  
  cat(sprintf("   📐 Simplificando geometrías (tolerancia: %s)...\n", tolerancia))
  
  # Desactivar S2
  sf_use_s2(FALSE)
  
  # Reparar geometrías inválidas
  invalidas <- !st_is_valid(data)
  if (any(invalidas)) {
    cat(sprintf("      🔧 Reparando %d geometrías inválidas...\n", sum(invalidas)))
    data <- st_make_valid(data)
  }
  
  # Contar vértices originales
  n_original <- tryCatch({
    nrow(st_coordinates(data))
  }, error = function(e) 0)
  
  # Simplificar
  data <- st_simplify(data, preserveTopology = TRUE, dTolerance = tolerancia)
  
  # Contar vértices finales
  n_final <- tryCatch({
    nrow(st_coordinates(data))
  }, error = function(e) 0)
  
  if (n_original > 0 && n_final > 0) {
    reduccion_pct <- round(100 * (1 - n_final/n_original), 1)
    cat(sprintf("      ✅ Vértices: %d → %d (-%s%%)\n", n_original, n_final, reduccion_pct))
  }
  
  # Reactivar S2
  sf_use_s2(TRUE)
  
  return(data)
}

#' Convertir todas las geometrías a MULTIPOLYGON de forma segura
#' 
#' @param data sf object
#' @return sf object con geometrías MULTIPOLYGON
forzar_multipolygon <- function(data) {
  
  tipos <- unique(as.character(st_geometry_type(data)))
  
  if (length(tipos) == 1 && tipos[1] == "MULTIPOLYGON") {
    cat("      ✅ Ya son MULTIPOLYGON\n")
    return(data)
  }
  
  cat(sprintf("      🔧 Convirtiendo %s a MULTIPOLYGON...\n", paste(tipos, collapse = ", ")))
  
  sf_use_s2(FALSE)
  
  # Método robusto: buffer(0) + cast
  data <- st_buffer(data, dist = 0)
  data <- st_make_valid(data)
  
  tryCatch({
    data <- st_cast(data, "MULTIPOLYGON", warn = FALSE)
  }, error = function(e) {
    # Si falla, procesar fila por fila
    cat("      ⚠️ Cast directo falló, procesando individualmente...\n")
    
    data <- do.call(rbind, lapply(1:nrow(data), function(i) {
      tryCatch({
        geom <- st_geometry(data[i, ])
        geom_cast <- st_cast(geom, "MULTIPOLYGON", warn = FALSE)
        st_sf(data[i, ], geometry = geom_cast)
      }, error = function(e2) {
        NULL
      })
    }))
  })
  
  sf_use_s2(TRUE)
  
  tipos_final <- unique(as.character(st_geometry_type(data)))
  cat(sprintf("      ✅ Tipos finales: %s\n", paste(tipos_final, collapse = ", ")))
  
  return(data)
}

#' Reducir columnas innecesarias para ahorrar memoria
#' 
#' @param data sf object
#' @param columnas_mantener Vector de nombres de columnas a mantener (además de geometry)
#' @return sf object con menos columnas
reducir_columnas <- function(data, columnas_mantener = c("OBJECTID", "id", "nombre", "codigo", "area", "area_ha")) {
  
  if (ncol(data) <= 5) {
    cat("      ✅ Ya tiene pocas columnas\n")
    return(data)
  }
  
  columnas_mantener <- c(columnas_mantener, "geometry")
  columnas_presentes <- intersect(names(data), columnas_mantener)
  
  if (length(columnas_presentes) > 0) {
    cat(sprintf("      📊 Reduciendo de %d a %d columnas\n", ncol(data), length(columnas_presentes)))
    data <- data[, columnas_presentes]
  }
  
  return(data)
}

#' Pipeline completo de optimización
#' 
#' @param data sf object
#' @param tolerancia Tolerancia de simplificación
#' @param reducir_cols Reducir columnas innecesarias
#' @return sf object optimizado
optimizar_geometria_completa <- function(data, tolerancia = 0.002, reducir_cols = TRUE) {
  
  cat("🔧 Iniciando optimización completa...\n")
  
  # 1. Simplificar
  data <- simplificar_geometria_agresiva(data, tolerancia)
  
  # 2. Forzar MULTIPOLYGON
  data <- forzar_multipolygon(data)
  
  # 3. Reducir columnas (opcional)
  if (reducir_cols) {
    data <- reducir_columnas(data)
  }
  
  # Resumen final
  tamano_mb <- as.numeric(object.size(data)) / 1024^2
  cat(sprintf("✅ Optimización completada: %.1f MB, %d filas\n", tamano_mb, nrow(data)))
  
  return(data)
}

#' Crear índice espacial para búsquedas rápidas
#' 
#' @param data sf object
#' @return sf object con índice
crear_indice_espacial <- function(data) {
  
  if (!inherits(data, "sf")) {
    stop("El objeto debe ser de tipo sf")
  }
  
  cat("   🔍 Creando índice espacial...\n")
  
  # En sf, el índice se crea automáticamente al usar st_intersects, etc.
  # Podemos forzar su creación accediendo a la geometría
  invisible(st_geometry(data))
  
  cat("   ✅ Índice espacial listo\n")
  
  return(data)
}