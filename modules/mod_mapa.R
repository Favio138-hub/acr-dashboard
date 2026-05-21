# ========================================
# MOD_MAPA.R - VERSIÓN HÍBRIDA PERFECTA
#  Mantiene tu estilo de polígonos ACR/ZI
#  Agrega clustering de puntos rojos
#  Súper rápido (3-5 segundos)
#  CORREGIDO: Filtra por ACR/ZI según ámbito
# ========================================

library(leaflet)
library(leaflet.extras)
library(sf)
library(dplyr)

# ========================================
# UI DEL MÓDULO MAPA
# ========================================

mapa_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    div(
      class = "panelbox",
      style = "margin-top: 30px;",
      
      h5(icon("map-marked-alt"), strong(" Mapa Interactivo de ACRs"), 
         class = "section-title",
         style = "margin-bottom: 20px;"),
      
      div(id = ns("loading_info"),
          style = "text-align: center; padding: 15px; background: #e8f5e9; border-radius: 8px; margin-bottom: 15px;",
          p(style = "margin: 0; color: #2e7d32; font-weight: 600;",
            icon("info-circle"), 
            " Click en las áreas para ver información detallada. Los puntos rojos representan deforestación.")
      ),
      
      leafletOutput(ns("mapa"), height = 600)
    )
  )
}

# ========================================
# SERVER DEL MÓDULO MAPA
# ========================================

mapa_server <- function(id, filtros_reactive) {
  moduleServer(id, function(input, output, session) {
    
    # ========================================
    # FUNCIÓN PARA CREAR POPUP ACR
    # ========================================
    
    crear_popup_acr <- function(nombre_acr, stats, codigo_acr = NA) {
      
      info_decreto <- if (!is.na(codigo_acr)) {
        obtener_info_decreto(codigo_acr)
      } else {
        data.frame(decreto = "No disponible", fecha = "—")
      }
      
  
      sprintf(
        "<div style='font-family: Arial; min-width: 250px; padding: 5px;'>
      <h4 style='margin: 0 0 12px 0; color: #2E7D32; border-bottom: 3px solid #4CAF50; padding-bottom: 5px;'>
        <b>%s</b>
      </h4>
      <table style='width: 100%%; font-size: 14px; line-height: 1.8;'>
        <tr style='background: #ffebee;'>
          <td><b>🔴 Antrópico:</b></td>
          <td align='right'><b>%s ha</b></td>
        </tr>
        <tr style='background: #e8f5e9;'>
          <td><b>🟢 Natural:</b></td>
          <td align='right'><b>%s ha</b></td>
        </tr>
        <tr style='background: #fff3e0;'>
          <td><b>🟡 Falsa Alerta:</b></td>
          <td align='right'><b>%s ha</b></td>
        </tr>
        <tr style='border-top: 2px solid #ddd; background: #f5f5f5;'>
          <td><b>📊 TOTAL:</b></td>
          <td align='right'><b style='color: #2E7D32; font-size: 16px;'>%s ha</b></td>
        </tr>
      </table>
      
      <!-- SECCIÓN DE DECRETO (NUEVA) -->
      <div style='margin-top: 15px; padding-top: 12px; border-top: 2px solid #4CAF50;'>
        <div style='background: #e8f5e9; padding: 8px; border-radius: 5px; margin-bottom: 6px;'>
          <p style='margin: 0; font-size: 12px; color: #1B5E20;'>
            <b>📜 Decreto Supremo:</b><br>
            <span style='font-size: 13px; color: #2E7D32; font-weight: 600;'>%s</span>
          </p>
        </div>
        <div style='background: #f1f8e9; padding: 8px; border-radius: 5px;'>
          <p style='margin: 0; font-size: 12px; color: #1B5E20;'>
            <b>📅 Fecha de Creación:</b><br>
            <span style='font-size: 13px; color: #558B2F; font-weight: 600;'>%s</span>
          </p>
        </div>
      </div>
    </div>",
        stats$Nombre[1],
        format(round(stats$Antropico[1], 2), big.mark = ","),
        format(round(stats$Perdida_natural[1], 2), big.mark = ","),
        format(round(stats$Falsa_alerta[1], 2), big.mark = ","),
        format(round(stats$Total[1], 2), big.mark = ","),
        info_decreto$decreto,    # ⬅
        info_decreto$fecha       # ⬅
      )
    }
    
    # ========================================
    # FUNCIÓN PARA CREAR POPUP ZI
    # ========================================
    
    crear_popup_zi <- function(nombre_zi, stats) {
      sprintf(
        "<div style='font-family: Arial; min-width: 250px; padding: 5px;'>
          <h4 style='margin: 0 0 12px 0; color: #555; border-bottom: 3px solid #9E9E9E; padding-bottom: 5px;'>
            <b>%s (ZI)</b>
          </h4>
          <table style='width: 100%%; font-size: 14px; line-height: 1.8;'>
            <tr style='background: #ffebee;'>
              <td><b>🔴 Antrópico:</b></td>
              <td align='right'><b>%s ha</b></td>
            </tr>
            <tr style='background: #e8f5e9;'>
              <td><b>🟢 Natural:</b></td>
              <td align='right'><b>%s ha</b></td>
            </tr>
            <tr style='background: #fff3e0;'>
              <td><b>🟡 Falsa Alerta:</b></td>
              <td align='right'><b>%s ha</b></td>
            </tr>
            <tr style='border-top: 2px solid #ddd; background: #f5f5f5;'>
              <td><b>📊 TOTAL:</b></td>
              <td align='right'><b style='color: #757575; font-size: 16px;'>%s ha</b></td>
            </tr>
          </table>
        </div>",
        stats$Nombre[1],
        format(round(stats$Antropico[1], 2), big.mark = ","),
        format(round(stats$Perdida_natural[1], 2), big.mark = ","),
        format(round(stats$Falsa_alerta[1], 2), big.mark = ","),
        format(round(stats$Total[1], 2), big.mark = ",")
      )
    }
    
    # ========================================
    # RENDERIZAR MAPA BASE
    # ========================================
    
    output$mapa <- renderLeaflet({
      
      cat("\n🗺️ Creando mapa base...\n")
      
      leaflet(options = leafletOptions(
        scrollWheelZoom = TRUE,
        preferCanvas = TRUE,
        zoomControl = TRUE
      )) %>%
        addProviderTiles(providers$OpenStreetMap,
                         group = "🗺️ Calles (OSM)",
                         options = providerTileOptions(opacity = 0.9)) %>%
        addProviderTiles(providers$Esri.WorldImagery,
                         group = "🛰️ Satelital (Esri)",
                         options = providerTileOptions(opacity = 1)) %>%
        addProviderTiles(providers$Esri.WorldTopoMap,
                         group = "⛰️ Topográfico",
                         options = providerTileOptions(opacity = 0.9)) %>%
        setView(lng = -74.5, lat = -7.5, zoom = 6) %>%
        addScaleBar(position = "bottomleft", 
                    options = scaleBarOptions(imperial = FALSE)) %>%
        
        # Leyenda
        addLegend(
          position = "bottomright",
          colors = c("#4CAF50", "#9E9E9E", "#FF0000"),
          labels = c(
            "<b>🟢 Áreas de Conservación Regional (ACR)</b>",
            "<b>⚫ Zonas de Influencia (ZI)</b>",
            "<b>🔴 Deforestación (Clustering)</b>"
          ),
          title = "<div style='font-size: 14px; font-weight: bold; margin-bottom: 8px;'>🔍 Leyenda del Mapa</div>",
          opacity = 1,
          layerId = "legend_main"
        ) %>%
        
        addLayersControl(
          baseGroups = c("🗺️ Calles (OSM)", "🛰️ Satelital (Esri)", "⛰️ Topográfico"),
          overlayGroups = c("ACRs", "Zonas de Influencia", "🔴 Deforestación", "Límites Departamentales"),
          options = layersControlOptions(collapsed = FALSE),
          position = "topright"
        ) %>%
        hideGroup("🔴 Deforestación")  # Ocultar al inicio
    })
    
    # ========================================
    # ✅ OBSERVADOR PARA ACTUALIZAR CAPAS
    # ========================================
    
    observe({
      
      filtros <- filtros_reactive$nombre_acr()
      ambito <- filtros_reactive$ambito()
      depto <- filtros_reactive$departamento()
      
      cat("\n🔄 Actualizando mapa...\n")
      cat(sprintf("   Filtros: %s\n", paste(filtros, collapse = ", ")))
      cat(sprintf("   Ámbito: %s\n", ifelse(is.null(ambito), "acr", ambito)))
      cat(sprintf("   Depto: %s\n", depto))
      
      # Limpiar capas anteriores
      leafletProxy("mapa", session) %>%
        clearShapes() %>%
        clearControls() %>%
        clearMarkerClusters()  
      
      # ========================================
      #  LÍMITES DEPARTAMENTALES
      # ========================================
      
      if (depto == "loreto" || depto == "todos") {
        if (!is.null(loreto_boundary) && inherits(loreto_boundary, "sf") && nrow(loreto_boundary) > 0) {
          tryCatch({
            leafletProxy("mapa", session) %>%
              addPolygons(
                data = loreto_boundary,
                color = "#006D5B", weight = 2, fillOpacity = 0,
                dashArray = "5, 5", label = "Loreto",
                group = "Límites Departamentales"
              )
          }, error = function(e) cat("⚠️ Error límite Loreto\n"))
        }
      }
      
      if (depto == "san_martin" || depto == "todos") {
        if (!is.null(san_martin_boundary) && inherits(san_martin_boundary, "sf") && nrow(san_martin_boundary) > 0) {
          tryCatch({
            leafletProxy("mapa", session) %>%
              addPolygons(
                data = san_martin_boundary,
                color = "#D32F2F", weight = 2, fillOpacity = 0,
                dashArray = "5, 5", label = "San Martín",
                group = "Límites Departamentales"
              )
          }, error = function(e) cat("⚠️ Error límite San Martín\n"))
        }
      }
      
      if (depto == "cusco" || depto == "todos") {
        if (!is.null(cuzco_boundary) && inherits(cuzco_boundary, "sf") && nrow(cuzco_boundary) > 0) {
          tryCatch({
            leafletProxy("mapa", session) %>%
              addPolygons(
                data = cuzco_boundary,
                color = "#FF6F00", weight = 2, fillOpacity = 0,
                dashArray = "5, 5", label = "Cusco",
                group = "Límites Departamentales"
              )
          }, error = function(e) cat("⚠️ Error límite Cusco\n"))
        }
      }
      
      # ========================================
      #  ZONAS DE INFLUENCIA (ZI)
      # ========================================
      
      zis_mostrar <- if (!is.null(filtros) && length(filtros) > 0) {
        # Convertir ACR_XX a ZI_XX
        filtros_zi <- gsub("^ACR_", "ZI_", filtros)
        ZIS[names(ZIS) %in% filtros_zi]
      } else {
        if (depto == "loreto") {
          ZIS[names(ZIS) %in% c("ZI_AA", "ZI_ANPCH", "ZI_MK", "ZI_CTT")]
        } else if (depto == "san_martin") {
          ZIS[names(ZIS) %in% c("ZI_BSM", "ZI_CE")]
        } else if (depto == "cusco") {
          ZIS[names(ZIS) %in% c("ZI_CHQ", "ZI_CHU", "ZI_QK")]
        } else {
          ZIS
        }
      }
      
      mostrar_zi <- is.null(ambito) || ambito == "zi" || ambito == "ambos"
      
      if (mostrar_zi && length(zis_mostrar) > 0) {
        
        cat(sprintf("🔸 Dibujando %d ZIs...\n", length(zis_mostrar)))
        
        for (nombre_zi in names(zis_mostrar)) {
          zi_geom <- zis_mostrar[[nombre_zi]]
          
          if (is.null(zi_geom) || !inherits(zi_geom, "sf") || nrow(zi_geom) == 0) next
          
          stats <- obtener_datos_filtrados(nombre_zi, depto, "zi")
          
          popup_text <- if (nrow(stats) > 0) {
            crear_popup_zi(nombre_zi, stats)
          } else {
            sprintf("<b>%s</b>", gsub("_", " ", nombre_zi))
          }
          
          nombre_legible <- gsub("ZI_", "ZI ", gsub("_", " ", nombre_zi))
          
          tryCatch({
            leafletProxy("mapa", session) %>%
              addPolygons(
                data = zi_geom,
                fillColor = "#9E9E9E",
                fillOpacity = 0.25,
                color = "#616161",
                weight = 2,
                opacity = 0.8,
                popup = popup_text,
                label = if (nrow(stats) > 0) stats$Nombre[1] else nombre_legible,
                highlightOptions = highlightOptions(
                  weight = 4,
                  color = "#424242",
                  fillOpacity = 0.6,
                  bringToFront = FALSE
                ),
                group = "Zonas de Influencia"
              )
            
            cat(sprintf("   ✅ %s\n", nombre_zi))
            
          }, error = function(e) {
            cat(sprintf("   ❌ Error %s: %s\n", nombre_zi, e$message))
          })
        }
      }
      
      # ========================================
      #  ACRs (TU ESTILO)
      # ========================================
      
      acrs_mostrar <- if (!is.null(filtros) && length(filtros) > 0) {
        ACRS[names(ACRS) %in% filtros]
      } else {
        if (depto == "loreto") {
          ACRS[names(ACRS) %in% c("ACR_AA", "ACR_ANPCH", "ACR_MK", "ACR_CTT")]
        } else if (depto == "san_martin") {
          ACRS[names(ACRS) %in% c("ACR_BSM", "ACR_CE")]
        } else if (depto == "cusco") {
          ACRS[names(ACRS) %in% c("ACR_CHQ", "ACR_CHU", "ACR_QK")]
        } else {
          ACRS
        }
      }
      
      mostrar_acrs <- is.null(ambito) || ambito == "acr" || ambito == "ambos"
      
      if (mostrar_acrs && length(acrs_mostrar) > 0) {
        
        cat(sprintf("🔹 Dibujando %d ACRs...\n", length(acrs_mostrar)))
        
        for (nombre_acr in names(acrs_mostrar)) {
          acr_geom <- acrs_mostrar[[nombre_acr]]
          
          if (is.null(acr_geom) || !inherits(acr_geom, "sf") || nrow(acr_geom) == 0) next
          
          stats <- obtener_datos_filtrados(nombre_acr, depto, "acr")
          
          popup_text <- if (nrow(stats) > 0) {
            crear_popup_acr(
              nombre_acr = nombre_acr,
              stats      = stats,
              codigo_acr = nombre_acr
            )
          } else {
            sprintf("<b>%s</b>", gsub("_", " ", nombre_acr))
          }
          
          nombre_legible <- gsub("ACR_", "ACR ", gsub("_", " ", nombre_acr))
          
          tryCatch({
            leafletProxy("mapa", session) %>%
              addPolygons(
                data = acr_geom,
                fillColor = "#4CAF50",
                fillOpacity = 0.4,
                color = "#2E7D32",
                weight = 2.5,
                opacity = 0.9,
                popup = popup_text,
                label = if (nrow(stats) > 0) stats$Nombre[1] else nombre_legible,
                highlightOptions = highlightOptions(
                  weight = 4,
                  color = "#1B5E20",
                  fillOpacity = 0.65,
                  bringToFront = TRUE
                ),
                group = "ACRs"
              )
            
            cat(sprintf("   ✅ %s\n", nombre_acr))
            
          }, error = function(e) {
            cat(sprintf("   ❌ Error %s: %s\n", nombre_acr, e$message))
          })
        }
      }
      
      # ========================================
      # 4️⃣ DEFORESTACIÓN CON CLUSTERING
      # ✅ CORREGIDO: Filtra por ACR y ZI según ámbito
      # ========================================
      
      cat("🔴 Agregando clustering de deforestación...\n")
      
      # Obtener centroides desde caché
      centroides_df <- obtener_cache("centroides_deforestacion")
      
      if (!is.null(centroides_df) && nrow(centroides_df) > 0) {
        
        # ✅ FILTRAR POR ÁMBITO
        if (!is.null(ambito) && ambito == "acr") {
          centroides_df <- centroides_df[centroides_df$tipo == "acr", ]
          cat("   📌 Mostrando solo puntos de ACR\n")
        } else if (!is.null(ambito) && ambito == "zi") {
          centroides_df <- centroides_df[centroides_df$tipo == "zi", ]
          cat("   📌 Mostrando solo puntos de ZI\n")
        } else {
          cat("   📌 Mostrando puntos de ACR y ZI\n")
        }
        
        # Filtrar por departamento
        if (depto == "loreto") {
          centroides_df <- centroides_df[centroides_df$codigo %in% c("ACR_AA", "ACR_ANPCH", "ACR_MK", "ACR_CTT", "ZI_AA", "ZI_ANPCH", "ZI_MK", "ZI_CTT"), ]
        } else if (depto == "san_martin") {
          centroides_df <- centroides_df[centroides_df$codigo %in% c("ACR_BSM", "ACR_CE", "ZI_BSM", "ZI_CE"), ]
        } else if (depto == "cusco") {
          centroides_df <- centroides_df[centroides_df$codigo %in% c("ACR_CHQ", "ACR_CHU", "ACR_QK", "ZI_CHQ", "ZI_CHU", "ZI_QK"), ]
        }
        
        # Filtrar por ACRs seleccionados
        if (!is.null(filtros) && length(filtros) > 0) {
          filtros_con_zi <- c(filtros, gsub("^ACR_", "ZI_", filtros))
          centroides_df <- centroides_df[centroides_df$codigo %in% filtros_con_zi, ]
        }
        
        if (nrow(centroides_df) > 0) {
          
          cat(sprintf("   🎯 Dibujando %d puntos con clustering...\n", nrow(centroides_df)))
          
          tryCatch({
            
            # ✅ AGREGAR MARCADORES CON CLUSTERING
            leafletProxy("mapa", session) %>%
              addMarkers(
                data = centroides_df,
                lng = ~lon,
                lat = ~lat,
                popup = ~sprintf(
                  "<div style='font-family:Arial;min-width:200px;'>
                    <h4 style='margin:0 0 8px 0;color:#d32f2f;'>🔴 Deforestación</h4>
                    <table style='width:100%%;font-size:13px;'>
                      <tr><td><b>Zona:</b></td><td>%s</td></tr>
                      <tr><td><b>Tipo:</b></td><td>%s</td></tr>
                      <tr><td><b>Año:</b></td><td>%s</td></tr>
                      <tr><td><b>Área:</b></td><td><b style='color:#d32f2f;'>%s ha</b></td></tr>
                    </table>
                  </div>",
                  gsub("ACR_|ZI_", "", codigo),
                  ifelse(tipo == "acr", "ACR", "ZI"),
                  anno,
                  format(round(area, 4), nsmall = 4, big.mark = ",")
                ),
                label = ~sprintf("🔴 %s (%s) - %s", 
                                 gsub("ACR_|ZI_", "", codigo), 
                                 ifelse(tipo == "acr", "ACR", "ZI"),
                                 anno),
                clusterOptions = markerClusterOptions(
                  showCoverageOnHover = TRUE,
                  zoomToBoundsOnClick = TRUE,
                  spiderfyOnMaxZoom = TRUE,
                  removeOutsideVisibleBounds = TRUE,
                  animate = TRUE,
                  animateAddingMarkers = TRUE,
                  maxClusterRadius = 80,
                  disableClusteringAtZoom = 15,
                  spiderfyDistanceMultiplier = 1.5,
                  iconCreateFunction = JS("
                    function(cluster) {
                      var count = cluster.getChildCount();
                      var size;
                      if (count < 100) {
                        size = 'small';
                      } else if (count < 1000) {
                        size = 'medium';
                      } else {
                        size = 'large';
                      }
                      return new L.DivIcon({
                        html: '<div><span>' + count + '</span></div>',
                        className: 'marker-cluster marker-cluster-' + size,
                        iconSize: new L.Point(40, 40)
                      });
                    }
                  ")
                ),
                group = "🔴 Deforestación"
              )
            
            cat(sprintf("   ✅ Clustering agregado exitosamente\n"))
            
          }, error = function(e) {
            cat(sprintf("   ❌ Error clustering: %s\n", e$message))
          })
          
        } else {
          cat("   ℹ️ No hay puntos después de filtrar\n")
        }
        
      } else {
        cat("   ⚠️ No hay centroides en caché\n")
      }
      
      # ========================================
      # RE-AGREGAR CONTROLES Y LEYENDA
      # ========================================
      
      leafletProxy("mapa", session) %>%
        addLayersControl(
          baseGroups = c("🗺️ Calles (OSM)", "🛰️ Satelital (Esri)", "⛰️ Topográfico"),
          overlayGroups = c("ACRs", "Zonas de Influencia", "🔴 Deforestación", "Límites Departamentales"),
          options = layersControlOptions(collapsed = FALSE),
          position = "topright"
        ) %>%
        addLegend(
          position = "bottomright",
          colors = c("#4CAF50", "#9E9E9E", "#FF0000"),
          labels = c(
            "<b>🟢 Áreas de Conservación Regional (ACR)</b>",
            "<b>⚫ Zonas de Influencia (ZI)</b>",
            "<b>🔴 Deforestación (Clustering)</b>"
          ),
          title = "<div style='font-size: 14px; font-weight: bold; margin-bottom: 8px;'>🔍 Leyenda del Mapa</div>",
          opacity = 1,
          layerId = "legend_main"
        )
      
      cat("✅ Mapa actualizado completamente\n\n")
      
    })
    
  })
}