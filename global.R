# ========================================
# GLOBAL.R - VERSIÓN CORREGIDA
#  Funciona con los archivos que REALMENTE tienes
#  Maneja ausencia de ZI de Cusco
#  Maneja ausencia de deforestación ZI Loreto/San Martín
# ========================================

library(shiny)
library(leaflet)
library(sf)
library(dplyr)
library(plotly)
library(DT)
library(shinythemes)
library(tidyr)
library(shinyjs)
library(zip)
library(leaflet.extras)
library(digest)

# ========================================
# CONFIGURACIÓN
# ========================================

sf_use_s2(FALSE)

options(
  shiny.maxRequestSize = 50*1024^2,
  scipen = 999,
  stringsAsFactors = FALSE
)

# ========================================
# CARGAR MÓDULOS
# ========================================

source("utils/cargar_datos.R", encoding = "UTF-8")
source("utils/helpers.R", encoding = "UTF-8")
source("utils/cache_manager.R", encoding = "UTF-8")
source("utils/semaforo.R", encoding = "UTF-8")
source("utils/KPI_Calculator.R", encoding = "UTF-8")
source("utils/datos_temporales_acr.R", encoding = "UTF-8")
source("data/datos_temporales_acr.R", encoding = "UTF-8")
source("modules/mod_filtros.R", encoding = "UTF-8")
source("modules/mod_mapa.R", encoding = "UTF-8")
source("modules/mod_graficos.R", encoding = "UTF-8")
source("modules/mod_tablas.R", encoding = "UTF-8")
source("modules/mod_prediccion.R", encoding = "UTF-8")
source("utils/footer_component.R", encoding = "UTF-8")
source("utils/datos_decretos_acr.R", encoding = "UTF-8")

# ========================================
# COLORES
# ========================================

color_acr <- c(
  "ACR_AA"    = "#f1c40f",
  "ACR_ANPCH" = "#f39c12",
  "ACR_MK"    = "#f4d03f",
  "ACR_CTT"   = "#f7dc6f",
  "ACR_BSM"   = "#f8c471",
  "ACR_CE"    = "#f5b041",
  "ACR_CHQ"   = "#f9e79f",
  "ACR_CHU"   = "#f7dc6f",
  "ACR_QK"    = "#f1c40f"
)

color_zi <- c(
  "ZI_AA"    = "#bdc3c7",
  "ZI_ANPCH" = "#95a5a6",
  "ZI_CTT"   = "#7f8c8d",
  "ZI_MK"    = "#d5d8dc",
  "ZI_BSM"   = "#c0c0c0",
  "ZI_CE"    = "#a6acaf",
  "ZI_CHQ"   = "#95a5a6",
  "ZI_CHU"   = "#bdc3c7",
  "ZI_QK"    = "#7f8c8d"
)

colores_causas <- c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3", "#a6d854", 
                    "#ffd92f", "#e5c494", "#b3b3b3", "#fb8072", "#80b1d3", "#fdb462")

# ========================================
# INICIO DE CARGA
# ========================================

cat("\n========================================\n")
cat("⚡ CARGA OPTIMIZADA - INICIANDO\n")
cat("========================================\n")

tiempo_inicio <- Sys.time()

# ========================================
# CARGAR GEOMETRÍAS
# ========================================

ACRS <- cargar_geometrias_acr()
ZIS <- cargar_geometrias_zi()

limites <- cargar_limites_departamentales()
loreto_boundary <- limites$loreto
san_martin_boundary <- limites$san_martin
cuzco_boundary <- limites$cuzco

estadisticas <- cargar_estadisticas_consolidadas()

acr_categoria <- estadisticas$acr_categoria
acr_categoria_sm <- estadisticas$acr_categoria_sm
acr_categoria_cz <- estadisticas$acr_categoria_cz

zi_categoria <- estadisticas$zi_categoria
zi_categoria_sm <- estadisticas$zi_categoria_sm
zi_categoria_cz <- estadisticas$zi_categoria_cz

causas_por_acr <- estadisticas$causas_por_acr
causas_por_zi <- estadisticas$causas_por_zi
causas_por_acr_sm <- estadisticas$causas_por_acr_sm
causas_por_zi_sm <- estadisticas$causas_por_zi_sm
causas_por_acr_cz <- estadisticas$causas_por_acr_cz
causas_por_zi_cz <- estadisticas$causas_por_zi_cz

causas_acr <- estadisticas$causas_acr
causas_zi <- estadisticas$causas_zi
causas_acr_sm <- estadisticas$causas_acr_sm
causas_zi_sm <- estadisticas$causas_zi_sm
causas_acr_cz <- estadisticas$causas_acr_cz
causas_zi_cz <- estadisticas$causas_zi_cz

# ========================================
# DEFORESTACIÓN - VERSIÓN CORREGIDA
# ========================================

cat("\n🔴 Cargando capas de deforestación...\n")

#  FUNCIÓN DE ARMONIZACIÓN
armonizar_columnas_defo <- function(data, nombre_codigo, tipo = "acr") {
  
  data_armonizado <- data.frame(
    CODIGO = character(nrow(data)),
    TIPO = character(nrow(data)),
    anp_codi = character(nrow(data)),
    zi_codi = character(nrow(data)),
    md_anno = character(nrow(data)),
    md_fecimg = character(nrow(data)),
    md_sup = numeric(nrow(data)),
    md_exa = character(nrow(data)),
    md_zonif = character(nrow(data)),
    stringsAsFactors = FALSE
  )
  
  data_armonizado$CODIGO <- nombre_codigo
  data_armonizado$TIPO <- tipo
  
  if ("anp_codi" %in% names(data)) {
    data_armonizado$anp_codi <- as.character(data$anp_codi)
  } else {
    data_armonizado$anp_codi <- if (tipo == "acr") nombre_codigo else "N/A"
  }
  
  if ("zi_codi" %in% names(data)) {
    data_armonizado$zi_codi <- as.character(data$zi_codi)
  } else {
    data_armonizado$zi_codi <- if (tipo == "zi") nombre_codigo else "N/A"
  }
  
  if ("md_anno" %in% names(data)) {
    data_armonizado$md_anno <- as.character(data$md_anno)
  } else if ("year" %in% names(data)) {
    data_armonizado$md_anno <- as.character(data$year)
  } else {
    data_armonizado$md_anno <- "N/A"
  }
  
  if ("md_fecimg" %in% names(data)) {
    data_armonizado$md_fecimg <- as.character(data$md_fecimg)
  } else if ("fecha" %in% names(data)) {
    data_armonizado$md_fecimg <- as.character(data$fecha)
  } else {
    data_armonizado$md_fecimg <- "N/A"
  }
  
  if ("md_sup" %in% names(data)) {
    data_armonizado$md_sup <- as.numeric(data$md_sup)
  } else if ("area_ha" %in% names(data)) {
    data_armonizado$md_sup <- as.numeric(data$area_ha)
  } else if ("AREA_HA" %in% names(data)) {
    data_armonizado$md_sup <- as.numeric(data$AREA_HA)
  } else {
    data_armonizado$md_sup <- 0
  }
  
  if ("md_exa" %in% names(data)) {
    data_armonizado$md_exa <- as.character(data$md_exa)
  } else {
    data_armonizado$md_exa <- "N/A"
  }
  
  if ("md_zonif" %in% names(data)) {
    data_armonizado$md_zonif <- as.character(data$md_zonif)
  } else if ("zonificacion" %in% names(data)) {
    data_armonizado$md_zonif <- as.character(data$zonificacion)
  } else {
    data_armonizado$md_zonif <- "N/A"
  }
  
  data_armonizado <- st_sf(data_armonizado, geometry = st_geometry(data))
  
  return(data_armonizado)
}

resolver_archivo_defo <- function(...) {
  candidatos <- list(...)
  for (c in candidatos) {
    if (file.exists(c)) return(c)
  }
  candidatos[[1]]
}

#  ARCHIVOS DE DEFORESTACIÓN ACR 
archivos_defo_acr <- list(
  # LORETO
  ACR_AA = "data/deforestacion_ACR_AA.rds",
  ACR_ANPCH = "data/deforestacion_ACR_ANPCH.rds",
  ACR_CTT = "data/deforestacion_ACR_CTT.rds",
  ACR_MK = "data/deforestacion_ACR_MK.rds",
  
  # SAN MARTÍN
  ACR_BSM = "data/deforestacion_ACR_BSM.rds",
  ACR_CE = resolver_archivo_defo("data/deforestacion_ACR_CE.rds", "data/datadeforestacion_ACR_CE.rds"),
  
  # CUSCO
  ACR_CHQ = "data/deforestacion_ACR_CHQ.rds",
  ACR_CHU = "data/deforestacion_ACR_CHU.rds",
  ACR_QK = "data/deforestacion_ACR_QK.rds"
)

#  ARCHIVOS DE DEFORESTACIÓN ZI
archivos_defo_zi <- list(
  ZI_CHQ = "data/deforestacion_ZI_CHQ.rds",
  ZI_CHU = "data/deforestacion_ZI_CHU.rds",
  ZI_QK = "data/deforestacion_ZI_QK.rds"
)

#  CARGAR DEFORESTACIÓN ACR
cat("\n📂 Cargando deforestación de ACR...\n")
deforestacion_cache_acr <- list()

for (nombre_var in names(archivos_defo_acr)) {
  archivo <- archivos_defo_acr[[nombre_var]]
  
  if (file.exists(archivo)) {
    tryCatch({
      cat(sprintf("  📂 Cargando %s...\n", nombre_var))
      
      data <- readRDS(archivo)
      data <- armonizar_columnas_defo(data, nombre_var, tipo = "acr")
      
      sf_use_s2(FALSE)
      data <- st_make_valid(data)
      sf_use_s2(TRUE)
      
      deforestacion_cache_acr[[nombre_var]] <- data
      
      cat(sprintf("  ✅ %s: %d polígonos\n", nombre_var, nrow(data)))
      
    }, error = function(e) {
      cat(sprintf("  ❌ Error %s: %s\n", nombre_var, e$message))
    })
  } else {
    cat(sprintf("  ⚠️  %s no existe\n", nombre_var))
  }
}

#  CARGAR DEFORESTACIÓN ZI (SOLO CUSCO)
cat("\n📂 Cargando deforestación de ZI (solo Cusco disponible)...\n")
deforestacion_cache_zi <- list()

for (nombre_var in names(archivos_defo_zi)) {
  archivo <- archivos_defo_zi[[nombre_var]]
  
  if (file.exists(archivo)) {
    tryCatch({
      cat(sprintf("  📂 Cargando %s...\n", nombre_var))
      
      data <- readRDS(archivo)
      data <- armonizar_columnas_defo(data, nombre_var, tipo = "zi")
      
      sf_use_s2(FALSE)
      data <- st_make_valid(data)
      sf_use_s2(TRUE)
      
      deforestacion_cache_zi[[nombre_var]] <- data
      
      cat(sprintf("  ✅ %s: %d polígonos\n", nombre_var, nrow(data)))
      
    }, error = function(e) {
      cat(sprintf("  ❌ Error %s: %s\n", nombre_var, e$message))
    })
  } else {
    cat(sprintf("  ⚠️  %s no existe\n", nombre_var))
  }
}

# ⚠️ NOTA: ZI de Loreto y San Martín NO TIENEN archivos de deforestación
cat("\n⚠️  NOTA: No hay archivos de deforestación para ZI de Loreto y San Martín\n")
cat("   Esto es normal si no fueron generados aún.\n")

#  COMBINAR TODO
cat("\n📦 Combinando capas de deforestación...\n")

deforestacion_completa <- NULL

tryCatch({
  
  # ACR
  if (length(deforestacion_cache_acr) > 0) {
    defo_acr <- do.call(rbind, deforestacion_cache_acr)
    cat(sprintf("   ✅ ACR: %d polígonos\n", nrow(defo_acr)))
    deforestacion_completa <- defo_acr
  }
  
  # ZI
  if (length(deforestacion_cache_zi) > 0) {
    defo_zi <- do.call(rbind, deforestacion_cache_zi)
    cat(sprintf("   ✅ ZI: %d polígonos\n", nrow(defo_zi)))
    
    if (!is.null(deforestacion_completa)) {
      deforestacion_completa <- rbind(deforestacion_completa, defo_zi)
    } else {
      deforestacion_completa <- defo_zi
    }
  }
  
  if (!is.null(deforestacion_completa)) {
    cat(sprintf("\n✅ Deforestación TOTAL: %d polígonos\n", nrow(deforestacion_completa)))
    cat(sprintf("   💾 Tamaño: %.1f MB\n", as.numeric(object.size(deforestacion_completa)) / 1024^2))
  } else {
    cat("\n⚠️  No se cargó ninguna deforestación\n")
  }
  
}, error = function(e) {
  cat("❌ Error combinando:", e$message, "\n")
  deforestacion_completa <- NULL
})

# ========================================
# CALCULAR CENTROIDES
# ========================================

if (!is.null(deforestacion_completa) && nrow(deforestacion_completa) > 0) {
  cat("\n🎯 Pre-calculando centroides...\n")
  
  tryCatch({
    centroides <- st_centroid(deforestacion_completa)
    coords <- st_coordinates(centroides)
    
    centroides_df <- data.frame(
      lon = coords[, "X"],
      lat = coords[, "Y"],
      codigo = deforestacion_completa$CODIGO,
      tipo = deforestacion_completa$TIPO,
      area = deforestacion_completa$md_sup,
      anno = deforestacion_completa$md_anno,
      stringsAsFactors = FALSE
    )
    
    centroides_df <- centroides_df[!is.na(centroides_df$lon) & !is.na(centroides_df$lat), ]
    
    guardar_cache("centroides_deforestacion", centroides_df)
    
    cat(sprintf("✅ %d centroides calculados\n", nrow(centroides_df)))
    cat(sprintf("   💾 Tamaño: %.1f MB\n", as.numeric(object.size(centroides_df)) / 1024^2))
    
    # Desglose
    n_acr <- sum(centroides_df$tipo == "acr")
    n_zi <- sum(centroides_df$tipo == "zi")
    cat(sprintf("   📊 ACR: %d | ZI: %d\n", n_acr, n_zi))
    
    # Por región
    cat("\n   📍 Por región:\n")
    
    # Loreto
    lor_acr <- sum(centroides_df$tipo == "acr" & grepl("ACR_(AA|ANPCH|CTT|MK)", centroides_df$codigo))
    lor_zi <- sum(centroides_df$tipo == "zi" & grepl("ZI_(AA|ANPCH|CTT|MK)", centroides_df$codigo))
    cat(sprintf("      LORETO - ACR: %d | ZI: %d\n", lor_acr, lor_zi))
    
    # San Martín
    sm_acr <- sum(centroides_df$tipo == "acr" & grepl("ACR_(BSM|CE)", centroides_df$codigo))
    sm_zi <- sum(centroides_df$tipo == "zi" & grepl("ZI_(BSM|CE)", centroides_df$codigo))
    cat(sprintf("      SAN MARTÍN - ACR: %d | ZI: %d\n", sm_acr, sm_zi))
    
    # Cusco
    cz_acr <- sum(centroides_df$tipo == "acr" & grepl("ACR_(CHQ|CHU|QK)", centroides_df$codigo))
    cz_zi <- sum(centroides_df$tipo == "zi" & grepl("ZI_(CHQ|CHU|QK)", centroides_df$codigo))
    cat(sprintf("      CUSCO - ACR: %d | ZI: %d\n", cz_acr, cz_zi))
    
    rm(deforestacion_completa, centroides, coords)
    gc()
    
    cat("\n✅ Memoria liberada\n")
    
  }, error = function(e) {
    cat(sprintf("⚠️ Error calculando centroides: %s\n", e$message))
  })
} else {
  cat("\n⚠️  No hay deforestación para calcular centroides\n")
}

# ========================================
# OPCIONES
# ========================================

options(DT.options = list(
  pageLength = 10, 
  language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json'),
  processing = FALSE,
  deferRender = TRUE
))

# ========================================
# RESUMEN FINAL
# ========================================

tiempo_total <- as.numeric(Sys.time() - tiempo_inicio)

cat("\n========================================\n")
cat("✅ CARGA COMPLETADA\n")
cat("========================================\n")
cat(sprintf("⏱️  Tiempo: %.1f seg\n", tiempo_total))
cat(sprintf("📊 ACRs: %d\n", length(ACRS)))
cat(sprintf("📊 ZIs: %d\n", length(ZIS)))

centroides_cache <- obtener_cache("centroides_deforestacion")
if (!is.null(centroides_cache)) {
  cat(sprintf("📊 Puntos deforestación: %d\n", nrow(centroides_cache)))
  cat(sprintf("   - ACR: %d\n", sum(centroides_cache$tipo == "acr")))
  cat(sprintf("   - ZI: %d\n", sum(centroides_cache$tipo == "zi")))
}

cat("========================================\n\n")

# Limpiar
if (exists("deforestacion_cache_acr")) rm(deforestacion_cache_acr)
if (exists("deforestacion_cache_zi")) rm(deforestacion_cache_zi)
if (exists("archivos_defo_acr")) rm(archivos_defo_acr)
if (exists("archivos_defo_zi")) rm(archivos_defo_zi)
gc()

cat("💡 Sistema listo\n")
cat("💡 Caché activo\n")
cat("💡 Centroides pre-calculados\n\n")