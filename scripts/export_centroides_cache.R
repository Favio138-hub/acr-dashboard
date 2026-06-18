#!/usr/bin/env Rscript
# Exporta centroides de deforestación a CSV
# Loreto/San Martín: shapefiles con campo anp_codi (ZI ACR ... vs ACR ...)
# Cusco: archivos .rds dedicados ACR y ZI

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

resolver_archivo_defo <- function(...) {
  candidatos <- list(...)
  for (c in candidatos) {
    if (file.exists(c)) return(c)
  }
  candidatos[[1]]
}

resolver_ruta <- function(...) {
  for (rel in list(...)) {
    p <- if (grepl("^(data|Vectores)", rel)) file.path(root, rel) else rel
    if (file.exists(p)) return(p)
  }
  NA_character_
}

es_registro_zi <- function(anp_codi, zi_codi = NA_character_) {
  a <- trimws(as.character(anp_codi))
  z <- trimws(as.character(zi_codi))
  grepl("^ZI", a, ignore.case = TRUE) || (nzchar(z) && grepl("^ZI", z, ignore.case = TRUE))
}

capas <- list()

agregar_capa <- function(nombre, layer) {
  if (is.null(layer) || nrow(layer) == 0) return(invisible(NULL))
  sf_use_s2(FALSE)
  layer <- st_make_valid(layer)
  if (nombre %in% names(capas)) {
    capas[[nombre]] <<- rbind(capas[[nombre]], layer)
  } else {
    capas[[nombre]] <<- layer
  }
}

cargar_capa_rds <- function(nombre, archivo, tipo) {
  if (!file.exists(archivo)) {
    message(sprintf("  omitido (no existe): %s", basename(archivo)))
    return(invisible(NULL))
  }
  tryCatch({
    data <- readRDS(archivo)
    layer <- armonizar_columnas_defo(data, nombre, tipo)
    agregar_capa(nombre, layer)
    message(sprintf("  OK %s: %d poligonos", nombre, nrow(layer)))
  }, error = function(e) {
    message(sprintf("  ERROR %s: %s", nombre, e$message))
  })
}

cargar_shp_loreto <- function(rel_shp, codigo_acr, codigo_zi) {
  shp_path <- resolver_ruta(rel_shp)
  if (is.na(shp_path)) {
    message(sprintf("  omitido (no existe): %s", rel_shp))
    return(invisible(NULL))
  }
  tryCatch({
    data <- st_read(shp_path, quiet = TRUE)
    sf_use_s2(FALSE)
    data <- st_make_valid(st_transform(data, 4326))
    es_zi <- vapply(seq_len(nrow(data)), function(i) {
      zc <- if ("zi_codi" %in% names(data)) data$zi_codi[i] else NA_character_
      es_registro_zi(data$anp_codi[i], zc)
    }, logical(1))
    n_acr <- 0L
    n_zi <- 0L
    if (any(!es_zi)) {
      layer <- armonizar_columnas_defo(data[!es_zi, ], codigo_acr, "acr")
      agregar_capa(codigo_acr, layer)
      n_acr <- nrow(layer)
    }
    if (any(es_zi)) {
      layer <- armonizar_columnas_defo(data[es_zi, ], codigo_zi, "zi")
      agregar_capa(codigo_zi, layer)
      n_zi <- nrow(layer)
    }
    message(sprintf("  OK %s: ACR=%d ZI=%d", basename(rel_shp), n_acr, n_zi))
  }, error = function(e) {
    message(sprintf("  ERROR %s: %s", basename(rel_shp), e$message))
  })
}

leer_objectids_rds <- function(archivo) {
  if (!file.exists(archivo)) return(integer(0))
  d <- readRDS(archivo)
  if (!"OBJECTID" %in% names(d)) return(integer(0))
  as.integer(d$OBJECTID)
}

cargar_sm_zi_desde_rds <- function() {
  # Archivos con nombres invertidos (ver global.R):
  # deforestacion_ACR_BSM.rds -> territorio CE (anp_codi ACR01) = ZI Cordillera Escalera
  # datadeforestacion_ACR_CE.rds -> territorio BSM (anp_codi ACR21) = ZI Bosques de Shunté
  rds_zi_ce <- resolver_archivo_defo(
    file.path(root, "data/deforestacion_ACR_BSM.rds")
  )
  rds_zi_bsm <- resolver_archivo_defo(
    file.path(root, "data/datadeforestacion_ACR_CE.rds"),
    file.path(root, "data/deforestacion_ACR_CE.rds")
  )
  cargar_capa_rds("ZI_CE", rds_zi_ce, "zi")
  cargar_capa_rds("ZI_BSM", rds_zi_bsm, "zi")
}

cargar_sm_acr_bsm_desde_rds <- function() {
  rds_bsm <- resolver_archivo_defo(
    file.path(root, "data/datadeforestacion_ACR_CE.rds"),
    file.path(root, "data/deforestacion_ACR_CE.rds")
  )
  cargar_capa_rds("ACR_BSM", rds_bsm, "acr")
}

cargar_sm_acr_desde_shapefile <- function() {
  shp_path <- resolver_ruta("Vectores_shp_San_Martin/MonitoreoDeforestacionAcumulado_ACR_SM.shp")
  if (is.na(shp_path)) {
    message("  omitido San Martin ACR (shapefile no encontrado)")
    return(invisible(NULL))
  }
  tryCatch({
    data <- st_read(shp_path, quiet = TRUE)
    sf_use_s2(FALSE)
    data <- st_make_valid(st_transform(data, 4326))

    ids_zi_ce <- leer_objectids_rds(
      resolver_archivo_defo(file.path(root, "data/deforestacion_ACR_BSM.rds"))
    )

    # ACR01 = Cordillera Escalera, ACR21 = Bosques de Shunté y Mishollo
    # Polígonos del RDS CE se exportan como ZI; el shapefile aporta el complemento ACR.
    sub_ce <- data[data$anp_codi == "ACR01", ]
    if (nrow(sub_ce) > 0) {
      if (length(ids_zi_ce) > 0) {
        sub_ce <- sub_ce[!sub_ce$OBJECTID %in% ids_zi_ce, ]
      }
      if (nrow(sub_ce) > 0) {
        layer <- armonizar_columnas_defo(sub_ce, "ACR_CE", "acr")
        agregar_capa("ACR_CE", layer)
        message(sprintf("  OK ACR_CE (shapefile \\ ZI_CE): %d poligonos", nrow(layer)))
      }
    }
  }, error = function(e) {
    message(sprintf("  ERROR San Martin ACR: %s", e$message))
  })
}

# --- Loreto: datos reales desde shapefile (anp_codi distingue ACR vs ZI) ---
message("Cargando Loreto desde shapefiles (anp_codi ACR / ZI ACR)...")
loreto_shps <- list(
  list(shp = "Vectores_shp_Loreto/ACR_AA/MonitoreoDeforestacionAcumulado_ACR09_ACRAA.shp", acr = "ACR_AA", zi = "ZI_AA"),
  list(shp = "Vectores_shp_Loreto/ACR_ANPCH/MonitoreoDeforestacionAcumulado_ACR10_ACRANPC.shp", acr = "ACR_ANPCH", zi = "ZI_ANPCH"),
  list(shp = "Vectores_shp_Loreto/ACR_CTT/MonitoreoDeforestacionAcumulado_ACR04_CTT.shp", acr = "ACR_CTT", zi = "ZI_CTT"),
  list(shp = "Vectores_shp_Loreto/ACR_MK/MonitoreoDeforestacionAcumulado_ACR17_ACRMK.shp", acr = "ACR_MK", zi = "ZI_MK")
)
for (par in loreto_shps) {
  cargar_shp_loreto(par$shp, par$acr, par$zi)
}

# --- San Martín: ZI desde RDS reales + ACR desde shapefile (complemento) ---
message("Cargando San Martin ZI desde RDS (deforestacion_ACR_BSM + datadeforestacion_ACR_CE)...")
cargar_sm_zi_desde_rds()
message("Cargando San Martin ACR_BSM desde RDS (datadeforestacion_ACR_CE)...")
cargar_sm_acr_bsm_desde_rds()
message("Cargando San Martin ACR_CE desde shapefile (poligonos fuera de RDS ZI_CE)...")
cargar_sm_acr_desde_shapefile()

# --- Cusco: archivos .rds ---
archivos_defo_acr_cusco <- list(
  ACR_CHQ = resolver_archivo_defo(file.path(root, "data/deforestacion_ACR_CHQ.rds")),
  ACR_CHU = resolver_archivo_defo(file.path(root, "data/deforestacion_ACR_CHU.rds")),
  ACR_QK = resolver_archivo_defo(file.path(root, "data/deforestacion_ACR_QK.rds"))
)
archivos_defo_zi <- list(
  ZI_CHQ = file.path(root, "data/deforestacion_ZI_CHQ.rds"),
  ZI_CHU = file.path(root, "data/deforestacion_ZI_CHU.rds"),
  ZI_QK = file.path(root, "data/deforestacion_ZI_QK.rds")
)

message("Cargando deforestacion ACR (Cusco)...")
for (nm in names(archivos_defo_acr_cusco)) {
  cargar_capa_rds(nm, archivos_defo_acr_cusco[[nm]], "acr")
}

message("Cargando deforestacion ZI (Cusco)...")
for (nm in names(archivos_defo_zi)) {
  cargar_capa_rds(nm, archivos_defo_zi[[nm]], "zi")
}

if (length(capas) == 0) {
  stop("No se cargo ninguna capa de deforestacion.")
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
