# ========================================
# SCRIPT: Convertir Shapefile de CUSCO a RDS
# Deforestación de las 3 ACRs de Cusco
# ========================================

library(sf)
library(dplyr)

# ========================================
# CONFIGURACIÓN
# ========================================

# Ruta donde están tus shapefiles de Cusco
ruta_shp <- "C:/Users/Favio Campos Rivera/Desktop/ACR_dashboard/vectores_shp_Cuzco"

# Nombre del archivo shapefile de deforestación
archivo_shp <- "DEFOR_ZI_ACR_3_EN_1.shp"  # Ajusta si el nombre es diferente

# Ruta donde se guardará el RDS
ruta_salida <- "data"

# Crear carpeta si no existe
if (!dir.exists(ruta_salida)) {
  dir.create(ruta_salida)
}

# ========================================
# PROCESAR SHAPEFILE DE CUSCO
# ========================================

cat("\n")
cat("╔════════════════════════════════════════╗\n")
cat("║  CONVERSIÓN SHAPEFILE CUSCO           ║\n")
cat("╚════════════════════════════════════════╝\n\n")

# Construir ruta completa
ruta_completa <- file.path(ruta_shp, archivo_shp)

# Verificar que existe
if (!file.exists(ruta_completa)) {
  cat("❌ ERROR: No se encontró el archivo:\n")
  cat("   ", ruta_completa, "\n\n")
  cat("💡 Archivos disponibles en la carpeta:\n")
  archivos <- list.files(ruta_shp, pattern = "\\.shp$")
  print(archivos)
  stop("Archivo no encontrado")
}

cat("📂 Leyendo shapefile de Cusco...\n")

# Desactivar S2 para evitar problemas de geometría
sf_use_s2(FALSE)

# Leer shapefile
shp <- st_read(ruta_completa, quiet = TRUE)

cat("✅ Registros leídos:", nrow(shp), "\n")
cat("📊 Columnas encontradas:\n")
print(names(shp))
cat("\n")

# ========================================
# IDENTIFICAR ACRs EN EL SHAPEFILE
# ========================================

cat("🔍 Identificando ACRs en el shapefile...\n")

# Ver si hay columna que identifique el ACR
if ("anp_codi" %in% names(shp)) {
  cat("✅ Columna 'anp_codi' encontrada\n")
  cat("   Códigos únicos:\n")
  acrs_unicos <- unique(shp$anp_codi)
  print(acrs_unicos)
  cat("\n")
} else if ("ACR_CODIGO" %in% names(shp)) {
  cat("✅ Columna 'ACR_CODIGO' encontrada\n")
  acrs_unicos <- unique(shp$ACR_CODIGO)
  print(acrs_unicos)
  cat("\n")
} else {
  cat("⚠️  No se encontró columna identificadora de ACR\n")
  cat("   Guardando todo junto\n\n")
  acrs_unicos <- NULL
}

# ========================================
# REPARAR GEOMETRÍAS
# ========================================

cat("🔧 Reparando geometrías inválidas...\n")

# Validar geometrías
invalidas <- !st_is_valid(shp)
n_invalidas <- sum(invalidas)

if (n_invalidas > 0) {
  cat("⚠️  Geometrías inválidas encontradas:", n_invalidas, "/", nrow(shp), "\n")
  cat("🔨 Reparando...\n")
  
  shp <- st_make_valid(shp)
  
  invalidas_despues <- !st_is_valid(shp)
  n_invalidas_despues <- sum(invalidas_despues)
  
  if (n_invalidas_despues == 0) {
    cat("✅ Todas las geometrías reparadas exitosamente\n")
  } else {
    cat("⚠️  Aún quedan", n_invalidas_despues, "geometrías inválidas\n")
    shp <- st_buffer(shp, dist = 0)
  }
} else {
  cat("✅ Todas las geometrías son válidas\n")
}

# ========================================
# TRANSFORMAR CRS
# ========================================

cat("\n🌐 Verificando sistema de coordenadas...\n")

if (is.na(st_crs(shp))) {
  cat("⚠️  CRS no definido, asumiendo WGS84...\n")
  st_crs(shp) <- 4326
} else if (st_crs(shp)$epsg != 4326) {
  cat("🔄 Transformando a WGS84 (EPSG:4326)...\n")
  shp <- st_transform(shp, 4326)
  cat("✅ Transformación completada\n")
} else {
  cat("✅ Ya está en WGS84\n")
}

# ========================================
# SIMPLIFICAR GEOMETRÍAS
# ========================================

cat("\n⚡ Simplificando geometrías para mejor rendimiento...\n")

tamaño_antes <- format(object.size(shp), units = "MB")

tryCatch({
  shp <- st_simplify(shp, dTolerance = 0.0001, preserveTopology = TRUE)
  cat("✅ Simplificación exitosa\n")
}, error = function(e) {
  cat("⚠️  Error en simplificación, usando tolerancia mayor...\n")
  shp <- st_simplify(shp, dTolerance = 0.001, preserveTopology = FALSE)
})

tamaño_despues <- format(object.size(shp), units = "MB")

cat("📦 Tamaño antes:", tamaño_antes, "\n")
cat("📦 Tamaño después:", tamaño_despues, "\n")

# ========================================
# SEPARAR Y GUARDAR POR ACR
# ========================================

cat("\n💾 Guardando archivos RDS...\n")

if (!is.null(acrs_unicos) && length(acrs_unicos) > 1) {
  
  cat("📦 Se detectaron", length(acrs_unicos), "ACRs, guardando archivos separados...\n\n")
  
  for (codigo_acr in acrs_unicos) {
    
    # Filtrar por ACR
    if ("anp_codi" %in% names(shp)) {
      shp_acr <- shp %>% filter(anp_codi == codigo_acr)
    } else {
      shp_acr <- shp %>% filter(ACR_CODIGO == codigo_acr)
    }
    
    # Determinar nombre del archivo
    if (grepl("CHQ|CHOQUEQUIRAO", codigo_acr, ignore.case = TRUE)) {
      archivo_salida <- "deforestacion_ACR_CHQ.rds"
      cat("  • ACR Choquequirao:", nrow(shp_acr), "polígonos\n")
    } else if (grepl("CHU|CHUYAPI", codigo_acr, ignore.case = TRUE)) {
      archivo_salida <- "deforestacion_ACR_CHU.rds"
      cat("  • ACR Chuyapi Urusayhua:", nrow(shp_acr), "polígonos\n")
    } else if (grepl("QK|QEROS|Q'EROS", codigo_acr, ignore.case = TRUE)) {
      archivo_salida <- "deforestacion_ACR_QK.rds"
      cat("  • ACR Q'eros Kosñipata:", nrow(shp_acr), "polígonos\n")
    } else {
      # Usar el código tal cual
      codigo_limpio <- gsub("[^A-Za-z0-9]", "_", codigo_acr)
      archivo_salida <- paste0("deforestacion_", codigo_limpio, ".rds")
      cat("  •", codigo_acr, ":", nrow(shp_acr), "polígonos\n")
    }
    
    ruta_archivo <- file.path(ruta_salida, archivo_salida)
    saveRDS(shp_acr, ruta_archivo)
    cat("    💾 Guardado en:", ruta_archivo, "\n\n")
  }
  
} else {
  # Guardar todo junto
  cat("💾 Guardando archivo único con todas las ACRs de Cusco...\n")
  
  archivo_salida <- "deforestacion_CUSCO.rds"
  ruta_archivo <- file.path(ruta_salida, archivo_salida)
  saveRDS(shp, ruta_archivo)
  cat("✅ Guardado en:", ruta_archivo, "\n")
}

# Reactivar S2
sf_use_s2(TRUE)

# ========================================
# RESUMEN FINAL
# ========================================

cat("\n")
cat("╔════════════════════════════════════════╗\n")
cat("║  CONVERSIÓN COMPLETADA                ║\n")
cat("╚════════════════════════════════════════╝\n\n")

cat("📊 ESTADÍSTICAS:\n")
cat("────────────────────────────────────────\n")
cat("Total de polígonos:", nrow(shp), "\n")
cat("Área total:", round(sum(shp$md_sup, na.rm = TRUE), 2), "ha\n")

cat("\n✅ Proceso completado exitosamente.\n")
cat("\n📌 PRÓXIMO PASO:\n")
cat("   Los archivos .rds ya están en la carpeta 'data/'\n")
cat("   Ahora debes agregar estos archivos a global.R\n\n")

