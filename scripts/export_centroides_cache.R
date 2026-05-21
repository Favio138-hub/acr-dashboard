#!/usr/bin/env Rscript
# Exporta centroides de deforestación a CSV (misma lógica que global.R)
# Uso: Rscript scripts/export_centroides_cache.R

suppressPackageStartupMessages({
  if (!requireNamespace("sf", quietly = TRUE)) {
    stop("Instale el paquete R 'sf': install.packages('sf')")
  }
  library(sf)
})

sf_use_s2(FALSE)

root <- if (dir.exists("data")) "." else if (dir.exists(file.path("..", "data"))) ".." else "."
cache_dir <- file.path(root, "data", "cache")
dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
out_csv <- file.path(cache_dir, "centroides_deforestacion.csv")

armonizar_columnas_defo <- function(data, nombre_codigo, tipo = "acr") {
  n <- nrow(data)
  data_armonizado <- data.frame(
    CODIGO = rep(nombre_codigo, n),
    TIPO = rep(tipo, n),
    anp_codi = "N/A",
    zi_codi = "N/A",
    md_anno = "N/A",
    md_fecimg = "N/A",
    md_sup = 0,
    md_exa = "N/A",
    md_zonif = "N/A",
    stringsAsFactors = FALSE
  )

  if ("anp_codi" %in% names(data)) data_armonizado$anp_codi <- as.character(data$anp_codi)
  else data_armonizado$anp_codi <- if (tipo == "acr") nombre_codigo else "N/A"

  if ("zi_codi" %in% names(data)) data_armonizado$zi_codi <- as.character(data$zi_codi)
  else data_armonizado$zi_codi <- if (tipo == "zi") nombre_codigo else "N/A"

  if ("md_anno" %in% names(data)) data_armonizado$md_anno <- as.character(data$md_anno)
  else if ("year" %in% names(data)) data_armonizado$md_anno <- as.character(data$year)

  if ("md_fecimg" %in% names(data)) data_armonizado$md_fecimg <- as.character(data$md_fecimg)
  else if ("fecha" %in% names(data)) data_armonizado$md_fecimg <- as.character(data$fecha)

  if ("md_sup" %in% names(data)) data_armonizado$md_sup <- as.numeric(data$md_sup)
  else if ("area_ha" %in% names(data)) data_armonizado$md_sup <- as.numeric(data$area_ha)
  else if ("AREA_HA" %in% names(data)) data_armonizado$md_sup <- as.numeric(data$AREA_HA)

  if ("md_exa" %in% names(data)) data_armonizado$md_exa <- as.character(data$md_exa)
  if ("md_zonif" %in% names(data)) data_armonizado$md_zonif <- as.character(data$md_zonif)
  else if ("zonificacion" %in% names(data)) data_armonizado$md_zonif <- as.character(data$zonificacion)

  st_sf(data_armonizado, geometry = st_geometry(data))
}

archivos_defo_acr <- list(
  ACR_AA = file.path(root, "data/deforestacion_ACR_AA.rds"),
  ACR_ANPCH = file.path(root, "data/deforestacion_ACR_ANPCH.rds"),
  ACR_CTT = file.path(root, "data/deforestacion_ACR_CTT.rds"),
  ACR_MK = file.path(root, "data/deforestacion_ACR_MK.rds"),
  ACR_BSM = file.path(root, "data/deforestacion_ACR_BSM.rds"),
  ACR_CE = file.path(root, "data/deforestacion_ACR_CE.rds"),
  ACR_CHQ = file.path(root, "data/deforestacion_ACR_CHQ.rds"),
  ACR_CHU = file.path(root, "data/deforestacion_ACR_CHU.rds"),
  ACR_QK = file.path(root, "data/deforestacion_ACR_QK.rds")
)

archivos_defo_zi <- list(
  ZI_CHQ = file.path(root, "data/deforestacion_ZI_CHQ.rds"),
  ZI_CHU = file.path(root, "data/deforestacion_ZI_CHU.rds"),
  ZI_QK = file.path(root, "data/deforestacion_ZI_QK.rds")
)

capas <- list()

cargar_capa <- function(nombre, archivo, tipo) {
  if (!file.exists(archivo)) {
    message(sprintf("  omitido (no existe): %s", basename(archivo)))
    return(invisible(NULL))
  }
  tryCatch({
    data <- readRDS(archivo)
    data <- armonizar_columnas_defo(data, nombre, tipo)
    sf_use_s2(FALSE)
    data <- st_make_valid(data)
    capas[[nombre]] <<- data
    message(sprintf("  OK %s: %d poligonos", nombre, nrow(data)))
  }, error = function(e) {
    message(sprintf("  ERROR %s: %s", nombre, e$message))
  })
}

message("Cargando deforestacion ACR...")
for (nm in names(archivos_defo_acr)) {
  cargar_capa(nm, archivos_defo_acr[[nm]], "acr")
}

message("Cargando deforestacion ZI (Cusco)...")
for (nm in names(archivos_defo_zi)) {
  cargar_capa(nm, archivos_defo_zi[[nm]], "zi")
}

if (length(capas) == 0) {
  stop("No se cargo ninguna capa de deforestacion. Verifique data/*.rds")
}

deforestacion_completa <- do.call(rbind, capas)
message(sprintf("Total poligonos: %d", nrow(deforestacion_completa)))

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

write.csv(centroides_df, out_csv, row.names = FALSE)
message(sprintf("Centroides guardados: %s (%d puntos)", out_csv, nrow(centroides_df)))
