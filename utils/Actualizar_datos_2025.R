# ========================================
# SCRIPT DEFINITIVO: ACTUALIZAR TODO A 2025
# Actualiza TODOS los archivos de Loreto con datos 2025
# ========================================

library(sf)
library(dplyr)

cat("\n")
cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║  ACTUALIZACIÓN COMPLETA A 2025 - LORETO                        ║\n")
cat("║  Actualiza: Gráficos + Mapa + Tablas + KPIs                    ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

# ========================================
# CONFIGURACIÓN - AJUSTA ESTAS RUTAS
# ========================================

# Ruta de tu shapefile 2025
ruta_shp_2025 <- "C:/Users/Favio Campos Rivera/Desktop/ACR_dashboard/Vectores_shp_Loreto/2025/MonitoreoDeforestacionAcumulado2025.shp"

# Carpeta de datos (donde están los .rds)
carpeta_data <- "data"

# ========================================
# MAPEO DE CÓDIGOS ACR
# ========================================

# Si tu shapefile usa códigos diferentes, ajústalos aquí
mapeo_acr <- list(
  "ACR09" = "ACR_AA",       # Ampiyacu Apayacu
  "ACR10" = "ACR_ANPCH",    # Alto Nanay - Pintuyacu - Chambira
  "ACR04" = "ACR_CTT",      # Comunal Tamshiyacu Tahuayo
  "ACR17" = "ACR_MK"        # Maijuna Kichwa
)

# Si tu shapefile dice solo "AA", "ANPCH", etc., usa esto en su lugar:
# mapeo_acr <- list(
#   "AA" = "ACR_AA",
#   "ANPCH" = "ACR_ANPCH",
#   "CTT" = "ACR_CTT",
#   "MK" = "ACR_MK"
# )

# ========================================
# VERIFICACIONES INICIALES
# ========================================

cat("🔍 Verificando archivos...\n")
cat("════════════════════════════════════════\n\n")

if (!file.exists(ruta_shp_2025)) {
  cat("❌ ERROR: No se encontró el shapefile 2025\n")
  cat("   Ruta buscada:\n")
  cat("   ", ruta_shp_2025, "\n\n")
  stop("Archivo no encontrado. Verifica la ruta.")
}

cat("✅ Shapefile 2025 encontrado\n")

if (!dir.exists(carpeta_data)) {
  cat("❌ ERROR: No existe la carpeta 'data'\n")
  stop("Carpeta data/ no encontrada")
}

cat("✅ Carpeta data/ encontrada\n\n")

# ========================================
# PASO 1: LEER SHAPEFILE 2025
# ========================================

cat("\n📂 PASO 1: Leyendo shapefile 2025...\n")
cat("════════════════════════════════════════\n")

sf_use_s2(FALSE)

shp_2025 <- st_read(ruta_shp_2025, quiet = FALSE)

cat(sprintf("\n✅ Shapefile leído: %d polígonos\n", nrow(shp_2025)))

# Mostrar columnas
cat("\n📊 Columnas detectadas:\n")
for (col in names(shp_2025)) {
  if (col != "geometry") {
    cat(sprintf("   • %s\n", col))
  }
}

# ========================================
# PASO 2: ARMONIZAR COLUMNAS
# ========================================

cat("\n🔧 PASO 2: Armonizando columnas...\n")
cat("════════════════════════════════════════\n")

# Renombrar zi_codi a md_causa si existe
if ("zi_codi" %in% names(shp_2025)) {
  cat("✅ Renombrando 'zi_codi' → 'md_causa'\n")
  names(shp_2025)[names(shp_2025) == "zi_codi"] <- "md_causa"
} else if ("md_causa" %in% names(shp_2025)) {
  cat("✅ Columna 'md_causa' ya existe\n")
} else {
  cat("⚠️  Creando columna 'md_causa' vacía\n")
  shp_2025$md_causa <- "No especificado"
}

# Asegurar que md_anno sea 2025
if ("md_anno" %in% names(shp_2025)) {
  shp_2025$md_anno <- "2025"
  cat("✅ Columna 'md_anno' establecida en 2025\n")
} else {
  cat("⚠️  Creando columna 'md_anno' = 2025\n")
  shp_2025$md_anno <- "2025"
}

# Asegurar columnas mínimas requeridas
columnas_requeridas <- c("anp_codi", "md_anno", "md_sup", "md_fecimg")

for (col in columnas_requeridas) {
  if (!col %in% names(shp_2025)) {
    cat(sprintf("⚠️  Falta columna '%s', creando con valores por defecto\n", col))
    
    if (col == "md_sup") {
      shp_2025$md_sup <- 0.09
    } else if (col == "md_fecimg") {
      shp_2025$md_fecimg <- "2025-01-01"
    } else {
      shp_2025[[col]] <- "N/A"
    }
  }
}

# ========================================
# PASO 3: PROCESAR GEOMETRÍAS
# ========================================

cat("\n🔧 PASO 3: Procesando geometrías...\n")
cat("════════════════════════════════════════\n")

# Reparar geometrías
cat("🔨 Reparando geometrías inválidas...\n")
shp_2025 <- st_make_valid(shp_2025)

# Asegurar WGS84
if (is.na(st_crs(shp_2025))) {
  cat("⚠️  Sin CRS, estableciendo WGS84\n")
  st_crs(shp_2025) <- 4326
} else if (st_crs(shp_2025)$epsg != 4326) {
  cat("🔄 Transformando a WGS84...\n")
  shp_2025 <- st_transform(shp_2025, 4326)
}

# Simplificar
cat("⚡ Simplificando geometrías...\n")
shp_2025 <- st_simplify(shp_2025, dTolerance = 0.0001, preserveTopology = TRUE)

cat("✅ Geometrías procesadas\n")

# ========================================
# PASO 4: IDENTIFICAR ACRs
# ========================================

cat("\n📊 PASO 4: Identificando ACRs en el shapefile...\n")
cat("════════════════════════════════════════\n\n")

cat("ACRs detectados en 'anp_codi':\n")
acrs_detectados <- unique(shp_2025$anp_codi)

for (acr in acrs_detectados) {
  n <- sum(shp_2025$anp_codi == acr, na.rm = TRUE)
  cat(sprintf("   • %s: %d polígonos\n", acr, n))
}

cat("\n💡 Mapeo que se usará:\n")
for (codigo_orig in names(mapeo_acr)) {
  codigo_nuevo <- mapeo_acr[[codigo_orig]]
  cat(sprintf("   %s → %s\n", codigo_orig, codigo_nuevo))
}

# ========================================
# PASO 5: ACTUALIZAR CADA ACR
# ========================================

cat("\n🔀 PASO 5: Actualizando archivos RDS...\n")
cat("════════════════════════════════════════\n\n")

resultados <- list()

for (codigo_orig in names(mapeo_acr)) {
  
  codigo_nuevo <- mapeo_acr[[codigo_orig]]
  nombre_archivo <- paste0("deforestacion_", codigo_nuevo, ".rds")
  ruta_archivo <- file.path(carpeta_data, nombre_archivo)
  
  cat(sprintf("📂 %s (%s)\n", codigo_nuevo, codigo_orig))
  cat("   ────────────────────────────────────\n")
  
  # Filtrar datos 2025 de este ACR
  datos_2025_acr <- shp_2025 %>% 
    filter(anp_codi == codigo_orig)
  
  if (nrow(datos_2025_acr) == 0) {
    cat(sprintf("   ⚠️  Sin datos 2025 para %s\n\n", codigo_orig))
    resultados[[codigo_nuevo]] <- list(
      exito = FALSE,
      mensaje = "Sin datos 2025",
      n_2025 = 0,
      n_total = 0
    )
    next
  }
  
  cat(sprintf("   📥 Datos 2025: %d polígonos\n", nrow(datos_2025_acr)))
  
  # Agregar código ACR
  datos_2025_acr$ACR_CODIGO <- codigo_nuevo
  
  # Leer datos existentes si existen
  if (file.exists(ruta_archivo)) {
    
    cat("   📂 Leyendo datos existentes...\n")
    datos_existentes <- readRDS(ruta_archivo)
    cat(sprintf("   📥 Datos existentes: %d polígonos\n", nrow(datos_existentes)))
    
    # Verificar si ya hay datos 2025
    if ("md_anno" %in% names(datos_existentes)) {
      datos_2025_viejos <- datos_existentes %>% 
        filter(md_anno == "2025" | md_anno == 2025)
      
      if (nrow(datos_2025_viejos) > 0) {
        cat(sprintf("   ⚠️  Eliminando %d polígonos 2025 antiguos\n", nrow(datos_2025_viejos)))
        datos_existentes <- datos_existentes %>% 
          filter(md_anno != "2025" & md_anno != 2025)
      }
    }
    
    # Armonizar columnas antes de combinar
    columnas_comunes <- intersect(names(datos_existentes), names(datos_2025_acr))
    columnas_comunes <- columnas_comunes[columnas_comunes != "geometry"]
    
    # Seleccionar solo columnas comunes
    datos_existentes_armonizados <- datos_existentes[, c(columnas_comunes, "geometry")]
    datos_2025_armonizados <- datos_2025_acr[, c(columnas_comunes, "geometry")]
    
    # Combinar
    cat("   🔀 Combinando con datos históricos...\n")
    datos_combinados <- rbind(datos_existentes_armonizados, datos_2025_armonizados)
    
  } else {
    cat("   ℹ️  No existe archivo previo, creando nuevo\n")
    datos_combinados <- datos_2025_acr
  }
  
  # Guardar
  cat("   💾 Guardando archivo actualizado...\n")
  saveRDS(datos_combinados, ruta_archivo)
  
  n_total <- nrow(datos_combinados)
  n_2025 <- sum(datos_combinados$md_anno == "2025" | datos_combinados$md_anno == 2025, na.rm = TRUE)
  
  cat(sprintf("   ✅ Guardado: %s\n", nombre_archivo))
  cat(sprintf("      Total: %d polígonos\n", n_total))
  cat(sprintf("      2025: %d polígonos\n", n_2025))
  cat("\n")
  
  resultados[[codigo_nuevo]] <- list(
    exito = TRUE,
    n_2025 = n_2025,
    n_total = n_total
  )
}

sf_use_s2(TRUE)

# ========================================
# RESUMEN FINAL
# ========================================

cat("\n")
cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║  ACTUALIZACIÓN COMPLETADA                                      ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

cat("📊 RESUMEN DE ACTUALIZACIÓN:\n")
cat("════════════════════════════════════════\n\n")

exitos <- 0
fallos <- 0

for (codigo in names(resultados)) {
  res <- resultados[[codigo]]
  
  if (res$exito) {
    exitos <- exitos + 1
    cat(sprintf("✅ %s\n", codigo))
    cat(sprintf("   Total: %d polígonos | 2025: %d polígonos\n\n", 
                res$n_total, res$n_2025))
  } else {
    fallos <- fallos + 1
    cat(sprintf("⚠️  %s: %s\n\n", codigo, res$mensaje))
  }
}

cat("════════════════════════════════════════\n")
cat(sprintf("✅ Exitosos: %d\n", exitos))
cat(sprintf("⚠️  Con advertencias: %d\n", fallos))
cat("════════════════════════════════════════\n\n")

# ========================================
# PRÓXIMOS PASOS
# ========================================

cat("📌 PRÓXIMOS PASOS:\n")
cat("────────────────────────────────────────\n")
cat("1. Cierra RStudio COMPLETAMENTE\n")
cat("2. Vuelve a abrir RStudio\n")
cat("3. Ejecuta: shiny::runApp()\n")
cat("4. Verifica que:\n")
cat("   • Los gráficos muestren hasta 2025\n")
cat("   • El mapa tenga puntos rojos de 2025\n")
cat("   • Las tablas incluyan datos 2025\n")
cat("   • Los KPIs reflejen los nuevos datos\n\n")

cat("✅ ¡ACTUALIZACIÓN COMPLETA!\n")
cat("✅ El dashboard ahora incluye datos 2025 de Loreto\n\n")

