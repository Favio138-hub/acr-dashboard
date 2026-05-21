# ========================================
# SCRIPT: Convertir Shapefile de ZI CUSCO a RDS
# Zonas de Influencia de las 3 ACRs de Cusco
# ========================================

library(sf)
library(dplyr)

# ========================================
# CONFIGURACIÓN
# ========================================

# Ruta donde están tus shapefiles de ZI Cusco
ruta_shp <- "C:/Users/Favio Campos Rivera/Desktop/ACR_dashboard/vectores_shp_Cuzco"

# Nombre del archivo shapefile de ZI
archivo_shp <- "ZI_ACR_CUZCO_3_EN_1.shp"  # Ajusta si el nombre es diferente

# Ruta donde se guardará el RDS
ruta_salida <- "data/geometrias_zi"

# Crear carpeta si no existe
if (!dir.exists(ruta_salida)) {
  dir.create(ruta_salida, recursive = TRUE)
}

# ========================================
# PROCESAR SHAPEFILE DE ZI CUSCO
# ========================================

cat("\n")
cat("╔════════════════════════════════════════╗\n")
cat("║  CONVERSIÓN SHAPEFILE ZI CUSCO        ║\n")
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

cat("📂 Leyendo shapefile de ZI Cusco...\n")

# Desactivar S2
sf_use_s2(FALSE)

# Leer shapefile
shp <- st_read(ruta_completa, quiet = TRUE)

cat("✅ Registros leídos:", nrow(shp), "\n")
cat("📊 Columnas encontradas:\n")
print(names(shp))
cat("\n")

# ========================================
# IDENTIFICAR ZIs EN EL SHAPEFILE
# ========================================

cat("🔍 Identificando ZIs en el shapefile...\n")

# Ver columnas identificadoras
if ("zi_codi" %in% names(shp)) {
  cat("✅ Columna 'zi_codi' encontrada\n")
  zis_unicos <- unique(shp$zi_codi)
  print(zis_unicos)
  cat("\n")
} else if ("ACR_CODIGO" %in% names(shp)) {
  cat("✅ Columna 'ACR_CODIGO' encontrada\n")
  zis_unicos <- unique(shp$ACR_CODIGO)
  print(zis_unicos)
  cat("\n")
} else {
  cat("⚠️  No se encontró columna identificadora de ZI\n")
  zis_unicos <- NULL
}

# ========================================
# REPARAR GEOMETRÍAS
# ========================================

cat("🔧 Reparando geometrías inválidas...\n")

invalidas <- !st_is_valid(shp)
n_invalidas <- sum(invalidas)

if (n_invalidas > 0) {
  cat("⚠️  Geometrías inválidas:", n_invalidas, "/", nrow(shp), "\n")
  shp <- st_make_valid(shp)
  cat("✅ Geometrías reparadas\n")
} else {
  cat("✅ Todas las geometrías son válidas\n")
}

# ========================================
# TRANSFORMAR CRS
# ========================================

cat("\n🌐 Verificando sistema de coordenadas...\n")

if (is.na(st_crs(shp))) {
  st_crs(shp) <- 4326
} else if (st_crs(shp)$epsg != 4326) {
  shp <- st_transform(shp, 4326)
  cat("✅ Transformado a WGS84\n")
} else {
  cat("✅ Ya está en WGS84\n")
}

# ========================================
# SIMPLIFICAR GEOMETRÍAS
# ========================================

cat("\n⚡ Simplificando geometrías...\n")

tryCatch({
  shp <- st_simplify(shp, dTolerance = 0.0001, preserveTopology = TRUE)
  cat("✅ Simplificación exitosa\n")
}, error = function(e) {
  shp <- st_simplify(shp, dTolerance = 0.001, preserveTopology = FALSE)
})

# ========================================
# SEPARAR Y GUARDAR POR ZI
# ========================================

cat("\n💾 Guardando archivos RDS...\n")

if (!is.null(zis_unicos) && length(zis_unicos) > 1) {
  
  cat("📦 Se detectaron", length(zis_unicos), "ZIs, guardando archivos separados...\n\n")
  
  for (codigo_zi in zis_unicos) {
    
    # Filtrar por ZI
    if ("zi_codi" %in% names(shp)) {
      shp_zi <- shp %>% filter(zi_codi == codigo_zi)
    } else {
      shp_zi <- shp %>% filter(ACR_CODIGO == codigo_zi)
    }
    
    # Determinar nombre del archivo
    if (grepl("CHQ|CHOQUEQUIRAO", codigo_zi, ignore.case = TRUE)) {
      archivo_salida <- "zi_chq.rds"
      cat("  • ZI Choquequirao:", nrow(shp_zi), "polígonos\n")
    } else if (grepl("CHU|CHUYAPI", codigo_zi, ignore.case = TRUE)) {
      archivo_salida <- "zi_chu.rds"
      cat("  • ZI Chuyapi Urusayhua:", nrow(shp_zi), "polígonos\n")
    } else if (grepl("QK|QEROS|Q'EROS", codigo_zi, ignore.case = TRUE)) {
      archivo_salida <- "zi_qk.rds"
      cat("  • ZI Q'eros Kosñipata:", nrow(shp_zi), "polígonos\n")
    } else {
      codigo_limpio <- gsub("[^A-Za-z0-9]", "_", tolower(codigo_zi))
      archivo_salida <- paste0("zi_", codigo_limpio, ".rds")
      cat("  •", codigo_zi, ":", nrow(shp_zi), "polígonos\n")
    }
    
    ruta_archivo <- file.path(ruta_salida, archivo_salida)
    saveRDS(shp_zi, ruta_archivo)
    cat("    💾 Guardado en:", ruta_archivo, "\n\n")
  }
  
} else {
  # Guardar todo junto
  cat("💾 Guardando archivo único con todas las ZIs de Cusco...\n")
  
  archivo_salida <- "zi_cusco_completo.rds"
  ruta_archivo <- file.path(ruta_salida, archivo_salida)
  saveRDS(shp, ruta_archivo)
  cat("✅ Guardado en:", ruta_archivo, "\n")
}

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
cat("Total de polígonos ZI:", nrow(shp), "\n")

cat("\n✅ Proceso completado exitosamente.\n")
cat("\n📌 PRÓXIMOS PASOS:\n")
cat("   1. Los archivos .rds están en 'data/geometrias_zi/'\n")
cat("   2. Estos se cargarán automáticamente con tu cargar_datos.R\n\n")

