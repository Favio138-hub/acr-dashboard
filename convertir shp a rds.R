# ========================================
# SCRIPT: Convertir Shapefile de San Martín a RDS
# Para ACR Bosques de Shunté y ACR Cordillera Escalera
# ========================================

library(sf)
library(dplyr)

# ========================================
# CONFIGURACIÓN
# ========================================

# Ruta donde está tu shapefile de San Martín
ruta_shp <- "C:/Users/Favio Campos Rivera/Desktop/ACR_dashboard/Vectores_shp_San_Martin"

# Nombre del archivo shapefile (el que ví en tu imagen)
archivo_shp <- "MonitoreoDeforestacionAcumulado_ACR_SM.shp"

# Ruta donde se guardará el RDS
ruta_salida <- "data"

# Crear carpeta si no existe
if (!dir.exists(ruta_salida)) {
  dir.create(ruta_salida)
}

# ========================================
# PROCESAR SHAPEFILE DE SAN MARTÍN
# ========================================

cat("\n")
cat("╔════════════════════════════════════════╗\n")
cat("║  CONVERSIÓN SHAPEFILE SAN MARTÍN      ║\n")
cat("╚════════════════════════════════════════╝\n\n")

# Construir ruta completa
ruta_completa <- file.path(ruta_shp, archivo_shp)

# Verificar que existe
if (!file.exists(ruta_completa)) {
  cat("❌ ERROR: No se encontró el archivo:\n")
  cat("   ", ruta_completa, "\n\n")
  cat("💡 Verifica que el nombre del archivo sea correcto.\n")
  stop("Archivo no encontrado")
}

cat("📂 Leyendo shapefile de San Martín...\n")

# Desactivar S2 para evitar problemas de geometría
sf_use_s2(FALSE)

# Leer shapefile
shp <- st_read(ruta_completa, quiet = TRUE)

cat("✅ Registros leídos:", nrow(shp), "\n")
cat("📊 Columnas encontradas:\n")
print(names(shp))
cat("\n")

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
  
  # Reparar geometrías inválidas
  shp <- st_make_valid(shp)
  
  # Verificar que se repararon
  invalidas_despues <- !st_is_valid(shp)
  n_invalidas_despues <- sum(invalidas_despues)
  
  if (n_invalidas_despues == 0) {
    cat("✅ Todas las geometrías reparadas exitosamente\n")
  } else {
    cat("⚠️  Aún quedan", n_invalidas_despues, "geometrías inválidas\n")
    cat("   Intentando método alternativo...\n")
    
    # Método alternativo: buffer de 0
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
# VERIFICAR COLUMNAS Y SEPARAR POR ACR
# ========================================

cat("\n🔍 Analizando contenido del shapefile...\n")

# Ver si hay columna que identifique el ACR
if ("anp_codi" %in% names(shp)) {
  cat("✅ Columna 'anp_codi' encontrada\n")
  cat("   Códigos únicos:\n")
  print(unique(shp$anp_codi))
  
  # Separar por ACR si hay dos ACRs diferentes
  acrs_unicos <- unique(shp$anp_codi)
  
  if (length(acrs_unicos) == 2) {
    cat("\n📦 Se detectaron 2 ACRs, guardando archivos separados...\n")
    
    # Guardar cada ACR por separado
    for (codigo_acr in acrs_unicos) {
      shp_acr <- shp %>% filter(anp_codi == codigo_acr)
      
      # Determinar nombre del archivo según el código
      if (grepl("BSM|SHUNTE|SHUNTE", codigo_acr, ignore.case = TRUE)) {
        archivo_salida <- "deforestacion_ACR_BSM.rds"
        cat("  • ACR Bosques de Shunté:", nrow(shp_acr), "polígonos\n")
      } else if (grepl("CE|ESCALERA", codigo_acr, ignore.case = TRUE)) {
        archivo_salida <- "deforestacion_ACR_CE.rds"
        cat("  • ACR Cordillera Escalera:", nrow(shp_acr), "polígonos\n")
      } else {
        archivo_salida <- paste0("deforestacion_", gsub("[^A-Za-z0-9]", "_", codigo_acr), ".rds")
        cat("  •", codigo_acr, ":", nrow(shp_acr), "polígonos\n")
      }
      
      ruta_archivo <- file.path(ruta_salida, archivo_salida)
      saveRDS(shp_acr, ruta_archivo)
      cat("    💾 Guardado en:", ruta_archivo, "\n")
    }
    
  } else {
    cat("\n⚠️  Solo se encontró 1 ACR, guardando archivo único\n")
    archivo_salida <- "deforestacion_SAN_MARTIN.rds"
    ruta_archivo <- file.path(ruta_salida, archivo_salida)
    saveRDS(shp, ruta_archivo)
    cat("💾 Guardado en:", ruta_archivo, "\n")
  }
  
} else {
  # Si no hay columna identificadora, guardar todo junto
  cat("⚠️  No se encontró columna 'anp_codi'\n")
  cat("   Guardando todos los datos en un solo archivo...\n")
  
  archivo_salida <- "deforestacion_SAN_MARTIN.rds"
  ruta_archivo <- file.path(ruta_salida, archivo_salida)
  saveRDS(shp, ruta_archivo)
  cat("💾 Guardado en:", ruta_archivo, "\n")
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
cat("Columnas importantes encontradas:\n")

# Mostrar columnas relevantes
cols_importantes <- c("anp_codi", "md_anno", "md_exa", "md_sup", "md_zonif", "md_causa")
cols_presentes <- intersect(cols_importantes, names(shp))

for (col in cols_presentes) {
  cat("  •", col, "\n")
}

cat("\n✅ Proceso completado exitosamente.\n")
cat("\n📌 PRÓXIMO PASO:\n")
cat("   Copiar los archivos .rds generados a la carpeta 'data/' de tu proyecto Shiny\n\n")

