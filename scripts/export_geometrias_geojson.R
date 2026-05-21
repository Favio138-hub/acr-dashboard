#!/usr/bin/env Rscript
# Exporta geometrías ACR, ZI y límites a GeoJSON (para mapa web con polígonos reales)

suppressPackageStartupMessages({
  library(sf)
})

sf_use_s2(FALSE)

root <- if (dir.exists("utils")) "." else if (dir.exists(file.path("..", "utils"))) ".." else "."
setwd(root)

source(file.path("utils", "cargar_datos.R"), encoding = "UTF-8")

out_dir <- file.path("data", "cache", "geojson")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

message("Cargando geometrías...")
ACRS <- cargar_geometrias_acr()
ZIS <- cargar_geometrias_zi()
limites <- cargar_limites_departamentales()

append_codigo <- function(x, codigo, layer) {
  if (is.null(x) || !inherits(x, "sf") || nrow(x) == 0) return(NULL)
  x <- st_transform(x, 4326)
  # Solo codigo + layer + geometria (evita error rbind por columnas distintas)
  st_sf(
    codigo = rep(codigo, nrow(x)),
    layer = rep(layer, nrow(x)),
    geometry = st_geometry(x)
  )
}

rbind_sf_list <- function(lst) {
  if (length(lst) == 0) return(NULL)
  if (length(lst) == 1) return(lst[[1]])
  Reduce(function(a, b) rbind(a, b), lst)
}

acr_list <- lapply(names(ACRS), function(nm) append_codigo(ACRS[[nm]], nm, "acr"))
acr_list <- Filter(Negate(is.null), acr_list)

zi_list <- lapply(names(ZIS), function(nm) append_codigo(ZIS[[nm]], nm, "zi"))
zi_list <- Filter(Negate(is.null), zi_list)

if (length(acr_list) > 0) {
  acr_all <- rbind_sf_list(acr_list)
  acr_all <- st_make_valid(acr_all)
  acr_all <- st_simplify(acr_all, preserveTopology = TRUE, dTolerance = 0.002)
  out_acr <- file.path(out_dir, "acr_all.geojson")
  st_write(acr_all, out_acr, delete_dsn = TRUE, quiet = TRUE)
  message(sprintf("OK ACR: %d features -> %s", nrow(acr_all), out_acr))
}

if (length(zi_list) > 0) {
  zi_all <- rbind_sf_list(zi_list)
  zi_all <- st_make_valid(zi_all)
  zi_all <- st_simplify(zi_all, preserveTopology = TRUE, dTolerance = 0.002)
  out_zi <- file.path(out_dir, "zi_all.geojson")
  st_write(zi_all, out_zi, delete_dsn = TRUE, quiet = TRUE)
  message(sprintf("OK ZI: %d features -> %s", nrow(zi_all), out_zi))
}

lim_list <- list()
if (!is.null(limites$loreto)) lim_list$loreto <- append_codigo(limites$loreto, "LORETO", "limite")
if (!is.null(limites$san_martin)) lim_list$san_martin <- append_codigo(limites$san_martin, "SAN_MARTIN", "limite")
if (!is.null(limites$cuzco)) lim_list$cuzco <- append_codigo(limites$cuzco, "CUSCO", "limite")

if (length(lim_list) > 0) {
  lim_all <- rbind_sf_list(lim_list)
  out_lim <- file.path(out_dir, "limites.geojson")
  st_write(lim_all, out_lim, delete_dsn = TRUE, quiet = TRUE)
  message(sprintf("OK Limites: %s", out_lim))
}

message("Exportacion GeoJSON completada.")
