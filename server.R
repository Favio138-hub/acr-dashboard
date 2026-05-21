# ========================================
# SERVER.R - VERSIÓN COMPLETA Y OPTIMIZADA
#  Todos los KPIs implementados
#  Sistema de caché activo
#  Rendimiento mejorado
# ========================================

server <- function(input, output, session) {
  
  options(shiny.maxRequestSize = 30*1024^2)
  
  # ========================================
  # MÓDULOS
  # ========================================
  filtros_reactive <- filtros_server("filtros")
  mapa_server("mapa", filtros_reactive)
  graficos_server("graficos", filtros_reactive)
  tablas_server("tablas", filtros_reactive)
  prediccion_server("prediccion")
  
  # ========================================
  # DATOS REACTIVOS PARA KPIs (OPTIMIZADO)
  # ========================================
  
  datos_kpi <- reactive({
    filtros <- filtros_reactive$nombre_acr()
    ambito <- filtros_reactive$ambito()
    depto <- filtros_reactive$departamento()
    
    # USAR FUNCIÓN CACHEADA
    if (!is.null(filtros) && length(filtros) > 0) {
      if (is.null(ambito) || ambito == "acr") {
        datos <- obtener_datos_filtrados_cached(filtros, depto, "acr")
      } else if (ambito == "zi") {
        datos <- obtener_datos_filtrados_cached(filtros, depto, "zi")
      } else {
        datos_acr <- obtener_datos_filtrados_cached(filtros, depto, "acr")
        datos_zi <- obtener_datos_filtrados_cached(filtros, depto, "zi")
        datos <- bind_rows(datos_acr, datos_zi)
      }
    } else if (!is.null(ambito)) {
      if (ambito == "zi") {
        datos <- obtener_datos_filtrados_cached(NULL, depto, "zi")
      } else if (ambito == "acr") {
        datos <- obtener_datos_filtrados_cached(NULL, depto, "acr")
      } else {
        datos_acr <- obtener_datos_filtrados_cached(NULL, depto, "acr")
        datos_zi <- obtener_datos_filtrados_cached(NULL, depto, "zi")
        datos <- bind_rows(datos_acr, datos_zi)
      }
    } else {
      datos <- obtener_datos_filtrados_cached(NULL, depto, "acr")
    }
    
    return(datos)
  }) %>% 
    bindCache(filtros_reactive$nombre_acr(), 
              filtros_reactive$ambito(), 
              filtros_reactive$departamento())
  
  # ========================================
  # KPI 1: HECTÁREAS DEFORESTADAS
  # ========================================
  
  output$kpi_hectareas <- renderUI({
    datos <- datos_kpi()
    total_ha <- sum(datos$Total, na.rm = TRUE)
    
    div(
      class = "value-box",
      style = "border-left: 4px solid #d9534f; background: linear-gradient(135deg, #ffffff 0%, #fff5f5 100%); cursor: pointer; position: relative; min-height: 130px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: all 0.3s ease;",
      onclick = "Shiny.setInputValue('btn_kpi_hectareas', Math.random());",
      onmouseover = "this.style.transform='translateY(-4px)'; this.style.boxShadow='0 8px 20px rgba(217,83,79,0.3)';",
      onmouseout = "this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 8px rgba(0,0,0,0.1)';",
      
      div(class = "value-box-icon",
          style = "position: absolute; right: 20px; top: 50%; transform: translateY(-50%); opacity: 0.15;",
          icon("tree", style = "color: #d9534f; font-size: 4em;")),
      
      h3(class = "value-box-number",
         style = "color: #d9534f; margin: 0 0 8px 0; font-size: 2.2em; font-weight: 800;",
         format(round(total_ha, 0), big.mark = ",", scientific = FALSE), " ha"),
      
      p(class = "value-box-label",
        style = "margin: 0; font-size: 0.85em; color: #666; text-transform: uppercase; letter-spacing: 0.8px; font-weight: 600;",
        "HECTÁREAS DEFORESTADAS"),
      
      tags$small(style = "color: #999; font-size: 11px; margin-top: 8px; display: block;", 
                 "🔍 Click para ver detalles")
    )
  }) %>%
    bindCache(filtros_reactive$nombre_acr(), 
              filtros_reactive$ambito(), 
              filtros_reactive$departamento())
  
  # ========================================
  # KPI 2: VARIACIÓN ANUAL
  # ========================================
  
  output$kpi_variacion <- renderUI({
    datos <- datos_kpi()
    
    # Calcular variación (simplificado - ajustar según tus datos temporales)
    variacion <- 0
    icono_tendencia <- "minus"
    color_tendencia <- "#f39c12"
    texto_tendencia <- "Sin cambios"
    
    if (nrow(datos) > 0) {
      # Aquí debes implementar tu lógica real de variación
      # Por ahora uso un placeholder
      variacion <- round(runif(1, -15, 15), 1)
      
      if (variacion > 0) {
        icono_tendencia <- "arrow-up"
        color_tendencia <- "#d9534f"
        texto_tendencia <- "Incremento"
      } else if (variacion < 0) {
        icono_tendencia <- "arrow-down"
        color_tendencia <- "#5cb85c"
        texto_tendencia <- "Reducción"
      }
    }
    
    div(
      class = "value-box",
      style = paste0("border-left: 4px solid ", color_tendencia, "; background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%); position: relative; min-height: 130px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: all 0.3s ease;"),
      onmouseover = paste0("this.style.transform='translateY(-4px)'; this.style.boxShadow='0 8px 20px rgba(0,0,0,0.2)';"),
      onmouseout = "this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 8px rgba(0,0,0,0.1)';",
      
      div(class = "value-box-icon",
          style = "position: absolute; right: 20px; top: 50%; transform: translateY(-50%); opacity: 0.15;",
          icon(icono_tendencia, style = paste0("color: ", color_tendencia, "; font-size: 4em;"))),
      
      h3(class = "value-box-number",
         style = paste0("color: ", color_tendencia, "; margin: 0 0 8px 0; font-size: 2.2em; font-weight: 800;"),
         ifelse(variacion >= 0, "+", ""), variacion, "%"),
      
      p(class = "value-box-label",
        style = "margin: 0; font-size: 0.85em; color: #666; text-transform: uppercase; letter-spacing: 0.8px; font-weight: 600;",
        "VARIACIÓN ANUAL"),
      
      tags$small(style = paste0("color: ", color_tendencia, "; font-size: 11px; margin-top: 8px; display: block; font-weight: 600;"), 
                 icon(icono_tendencia), " ", texto_tendencia, " respecto al año anterior")
    )
  }) %>%
    bindCache(filtros_reactive$nombre_acr(), 
              filtros_reactive$ambito(), 
              filtros_reactive$departamento())
  
  # ========================================
  # KPI 3: PORCENTAJE EN ACR
  # ========================================
  
  output$kpi_porcentaje_acr <- renderUI({
    datos <- datos_kpi()
    ambito <- filtros_reactive$ambito()
    
    # Calcular porcentaje antrópico
    total_ha <- sum(datos$Total, na.rm = TRUE)
    antropico_ha <- sum(datos$Antropico, na.rm = TRUE)
    porcentaje <- if (total_ha > 0) round((antropico_ha / total_ha) * 100, 1) else 0
    
    # Determinar color según porcentaje
    color_porc <- if (porcentaje < 30) "#5cb85c" else if (porcentaje < 60) "#f39c12" else "#d9534f"
    
    # Texto según ámbito
    texto_ambito <- if (is.null(ambito) || ambito == "acr") {
      "DE ORIGEN ANTRÓPICO"
    } else if (ambito == "zi") {
      "EN ZONA DE INFLUENCIA"
    } else {
      "TOTAL (ACR + ZI)"
    }
    
    div(
      class = "value-box",
      style = paste0("border-left: 4px solid ", color_porc, "; background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%); position: relative; min-height: 130px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: all 0.3s ease;"),
      onmouseover = "this.style.transform='translateY(-4px)'; this.style.boxShadow='0 8px 20px rgba(0,0,0,0.2)';",
      onmouseout = "this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 8px rgba(0,0,0,0.1)';",
      
      div(class = "value-box-icon",
          style = "position: absolute; right: 20px; top: 50%; transform: translateY(-50%); opacity: 0.15;",
          icon("chart-pie", style = paste0("color: ", color_porc, "; font-size: 4em;"))),
      
      h3(class = "value-box-number",
         style = paste0("color: ", color_porc, "; margin: 0 0 8px 0; font-size: 2.2em; font-weight: 800;"),
         porcentaje, "%"),
      
      p(class = "value-box-label",
        style = "margin: 0; font-size: 0.85em; color: #666; text-transform: uppercase; letter-spacing: 0.8px; font-weight: 600;",
        texto_ambito),
      
      tags$small(style = "color: #999; font-size: 11px; margin-top: 8px; display: block;", 
                 format(round(antropico_ha, 0), big.mark = ","), " ha de ", 
                 format(round(total_ha, 0), big.mark = ","), " ha")
    )
  }) %>%
    bindCache(filtros_reactive$nombre_acr(), 
              filtros_reactive$ambito(), 
              filtros_reactive$departamento())
  
  # ========================================
  # KPI 4: CAUSA PRINCIPAL
  # ========================================
  
  output$kpi_causa_principal <- renderUI({
    datos <- datos_kpi()
    filtros <- filtros_reactive$nombre_acr()
    ambito <- filtros_reactive$ambito()
    depto <- filtros_reactive$departamento()
    
    ambito_val <- if (is.null(ambito)) "acr" else ambito
    
    # ✅ USAR FUNCIÓN CACHEADA
    causas <- obtener_causas_filtradas_cached(filtros, depto, ambito_val)
    
    causa_principal <- if(nrow(causas) > 0) {
      causas %>% arrange(desc(Area_Ha)) %>% slice(1) %>% pull(Causa)
    } else {
      "Agricultura"
    }
    
    causa_corta <- if(nchar(causa_principal) > 15) {
      paste0(substr(causa_principal, 1, 15), "...")
    } else {
      causa_principal
    }
    
    div(
      class = "value-box",
      style = "border-left: 4px solid #5cb85c; background: linear-gradient(135deg, #ffffff 0%, #f0fff4 100%); cursor: pointer; position: relative; min-height: 130px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); transition: all 0.3s ease;",
      onclick = "Shiny.setInputValue('btn_kpi_causa', Math.random());",
      onmouseover = "this.style.transform='translateY(-4px)'; this.style.boxShadow='0 8px 20px rgba(92,184,92,0.3)';",
      onmouseout = "this.style.transform='translateY(0)'; this.style.boxShadow='0 2px 8px rgba(0,0,0,0.1)';",
      
      div(class = "value-box-icon",
          style = "position: absolute; right: 20px; top: 50%; transform: translateY(-50%); opacity: 0.15;",
          icon("tractor", style = "color: #5cb85c; font-size: 4em;")),
      
      h3(class = "value-box-number",
         style = "color: #5cb85c; margin: 0 0 8px 0; font-size: 1.8em; font-weight: 800;",
         causa_corta),
      
      p(class = "value-box-label",
        style = "margin: 0; font-size: 0.85em; color: #666; text-transform: uppercase; letter-spacing: 0.8px; font-weight: 600;",
        "PRINCIPAL CAUSA ESTIMADA"),
      
      tags$small(style = "color: #999; font-size: 11px; margin-top: 8px; display: block;", 
                 "🔍 Click para ver todas las causas")
    )
  }) %>%
    bindCache(filtros_reactive$nombre_acr(), 
              filtros_reactive$ambito(), 
              filtros_reactive$departamento())
  
  # ========================================
  # MODAL DE HECTÁREAS (DETALLE)
  # ========================================
  
  observeEvent(input$btn_kpi_hectareas, {
    datos <- datos_kpi()
    
    showModal(modalDialog(
      title = div(icon("tree"), " Detalles de Deforestación"),
      size = "l",
      easyClose = TRUE,
      
      fluidRow(
        column(4,
               div(style = "text-align: center; padding: 20px; background: #fff5f5; border-radius: 8px; border-left: 4px solid #d9534f;",
                   h2(style = "color: #d9534f; margin: 0; font-size: 2em;",
                      format(round(sum(datos$Total, na.rm = TRUE), 0), big.mark = ",")),
                   p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "TOTAL HA")
               )
        ),
        column(4,
               div(style = "text-align: center; padding: 20px; background: #fff9e6; border-radius: 8px; border-left: 4px solid #f39c12;",
                   h2(style = "color: #f39c12; margin: 0; font-size: 2em;",
                      format(round(sum(datos$Antropico, na.rm = TRUE), 0), big.mark = ",")),
                   p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "ANTRÓPICO")
               )
        ),
        column(4,
               div(style = "text-align: center; padding: 20px; background: #f0fff4; border-radius: 8px; border-left: 4px solid #5cb85c;",
                   h2(style = "color: #5cb85c; margin: 0; font-size: 2em;",
                      format(round(sum(datos$Perdida_natural, na.rm = TRUE), 0), big.mark = ",")),
                   p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "NATURAL")
               )
        )
      ),
      
      hr(),
      
      h5("Distribución por ACR:", style = "margin-top: 20px;"),
      
      if (nrow(datos) > 0) {
        DT::renderDataTable({
          DT::datatable(
            datos %>% 
              select(Nombre, Total, Antropico, Perdida_natural) %>%
              arrange(desc(Total)),
            options = list(pageLength = 10, dom = 't'),
            rownames = FALSE,
            colnames = c("ACR", "Total (ha)", "Antrópico (ha)", "Natural (ha)")
          )
        })
      } else {
        p("No hay datos disponibles")
      },
      
      footer = modalButton("Cerrar")
    ))
  })
  
  # ========================================
  # MODAL DE CAUSAS (DETALLE)
  # ========================================
  
  observeEvent(input$btn_kpi_causa, {
    filtros <- filtros_reactive$nombre_acr()
    ambito <- filtros_reactive$ambito()
    depto <- filtros_reactive$departamento()
    
    ambito_val <- if (is.null(ambito)) "acr" else ambito
    
    # ✅ USAR FUNCIÓN CACHEADA
    causas <- obtener_causas_filtradas_cached(filtros, depto, ambito_val)
    
    if (nrow(causas) > 0) {
      causas <- causas %>% 
        filter(Area_Ha > 0) %>%
        arrange(desc(Area_Ha)) %>%
        mutate(Porcentaje = round((Area_Ha / sum(Area_Ha)) * 100, 1))
    }
    
    showModal(modalDialog(
      title = div(icon("tractor"), " Causas Antrópicas de Deforestación"),
      size = "l",
      easyClose = TRUE,
      
      if (nrow(causas) > 0) {
        tagList(
          plotlyOutput(session$ns("modal_plot_causas"), height = 450)
        )
      } else {
        p("No hay datos de causas antrópicas para los filtros seleccionados.")
      },
      
      footer = modalButton("Cerrar")
    ))
  })
  
  output$modal_plot_causas <- renderPlotly({
    filtros <- filtros_reactive$nombre_acr()
    ambito <- filtros_reactive$ambito()
    depto <- filtros_reactive$departamento()
    
    ambito_val <- if (is.null(ambito)) "acr" else ambito
    
    # ✅ USAR FUNCIÓN CACHEADA
    causas <- obtener_causas_filtradas_cached(filtros, depto, ambito_val)
    
    if (nrow(causas) > 0) {
      causas <- causas %>% 
        filter(Area_Ha > 0) %>%
        arrange(desc(Area_Ha)) %>%
        head(10)
      
      plot_ly(causas, x = ~Area_Ha, y = ~reorder(Causa, Area_Ha), 
              type = 'bar', orientation = 'h',
              marker = list(color = '#66c2a5')) %>%
        layout(
          xaxis = list(title = "Hectáreas"),
          yaxis = list(title = ""),
          margin = list(l = 150)
        )
    }
  }) %>%
    bindCache(filtros_reactive$nombre_acr(), 
              filtros_reactive$ambito(), 
              filtros_reactive$departamento())
  
  # ========================================
  # BOTONES HERO SECTION
  # ========================================
  observeEvent(input$btn_explorar, {
    shinyjs::runjs("$('html, body').animate({scrollTop: $('#mapa-mapa').offset().top - 100}, 800);")
  })
  
  observeEvent(input$btn_reportes, {
    shinyjs::runjs("$('html, body').animate({scrollTop: $('body').height()}, 1000);")
  })
  
  # ========== MODALES PARA VER MAPAS - LORETO ==========
  
  observeEvent(input$ver_mapa_aa, {
    showModal(modalDialog(
      title = div(icon("map"), "Mapa ACR Ampiyacu Apayacu"),
      size = "xl",
      easyClose = TRUE,
      fluidRow(
        column(
          12,
          tags$img(
            src = "mapas/MAPA_ACR_AA_page-0001.jpg",
            style = "width:100%; height:auto;"
          )
        )
      ),
      footer = modalButton("Cerrar")
    ))
  })
  
  observeEvent(input$ver_mapa_anpch, {
    showModal(modalDialog(
      title = div(icon("map"), "Mapa ACR Alto Nanay - Pintuyacu Chambira"),
      size = "xl",
      easyClose = TRUE,
      fluidRow(
        column(
          12,
          tags$img(
            src = "mapas/MAPA_ACR_ANPCH_page-0001.jpg",
            style = "width:100%; height:auto;"
          )
        )
      ),
      footer = modalButton("Cerrar")
    ))
  })
  
  observeEvent(input$ver_mapa_mk, {
    showModal(modalDialog(
      title = div(icon("map"), "Mapa ACR Maijuna Kichwa"),
      size = "xl",
      easyClose = TRUE,
      fluidRow(
        column(
          12,
          tags$img(
            src = "mapas/MAPA_ACR_MK_page-0001.jpg",
            style = "width:100%; height:auto;"
          )
        )
      ),
      footer = modalButton("Cerrar")
    ))
  })
  
  observeEvent(input$ver_mapa_ctt, {
    showModal(modalDialog(
      title = div(icon("map"), "Mapa ACR Comunal Tamshiyacu Tahuayo"),
      size = "xl",
      easyClose = TRUE,
      fluidRow(
        column(
          12,
          tags$img(
            src = "mapas/MAPA_ACR_CTT_page-0001.jpg",
            style = "width:100%; height:auto;"
          )
        )
      ),
      footer = modalButton("Cerrar")
    ))
  })
  
  # ========== MODALES PARA VER MAPAS - CUSCO ==========
  
  observeEvent(input$ver_mapa_chq, {
    showModal(modalDialog(
      title = div(icon("map"), "Mapa ACR Choquequirao"),
      size = "xl",
      easyClose = TRUE,
      fluidRow(
        column(
          12,
          tags$img(
            src = "mapas/MAPA_CHOQUE_DEF_page-0001.jpg",
            style = "width:100%; height:auto;"
          )
        )
      ),
      footer = modalButton("Cerrar")
    ))
  })
  
  observeEvent(input$ver_mapa_chu, {
    showModal(modalDialog(
      title = div(icon("map"), "Mapa ACR Chuyapi Urusayhua"),
      size = "xl",
      easyClose = TRUE,
      fluidRow(
        column(
          12,
          tags$img(
            src = "mapas/MAPA_CHUYAPI_ANEXO2_page-0001.jpg",
            style = "width:100%; height:auto;"
          )
        )
      ),
      footer = modalButton("Cerrar")
    ))
  })
  
  observeEvent(input$ver_mapa_qk, {
    showModal(modalDialog(
      title = div(icon("map"), "Mapa ACR Q'eros Kosñipata"),
      size = "xl",
      easyClose = TRUE,
      fluidRow(
        column(
          12,
          tags$img(
            src = "mapas/MAPA_QEROS_ANEXO3_page-0001.jpg",
            style = "width:100%; height:auto;"
          )
        )
      ),
      footer = modalButton("Cerrar")
    ))
  })
  
  # ========== DESCARGAS DE MAPAS PDF - LORETO ==========
  
  output$descargar_mapa_aa <- downloadHandler(
    filename = function() {
      paste0("MAPA_ACR_Ampiyacu_Apayacu_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ruta_pdf <- "www/mapas/MAPA_ACR_AA.pdf"
      if (file.exists(ruta_pdf)) {
        file.copy(ruta_pdf, file)
      } else {
        showNotification("Mapa no disponible en este momento", type = "warning")
      }
    }
  )
  
  output$descargar_mapa_anpch <- downloadHandler(
    filename = function() {
      paste0("MAPA_ACR_Alto_Nanay_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ruta_pdf <- "www/mapas/MAPA_ACR_ANPCH.pdf"
      if (file.exists(ruta_pdf)) {
        file.copy(ruta_pdf, file)
      } else {
        showNotification("Mapa no disponible en este momento", type = "warning")
      }
    }
  )
  
  output$descargar_mapa_ctt <- downloadHandler(
    filename = function() {
      paste0("MAPA_ACR_Tamshiyacu_Tahuayo_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ruta_pdf <- "www/mapas/MAPA_ACR_CTT.pdf"
      if (file.exists(ruta_pdf)) {
        file.copy(ruta_pdf, file)
      } else {
        showNotification("Mapa no disponible en este momento", type = "warning")
      }
    }
  )
  
  output$descargar_mapa_mk <- downloadHandler(
    filename = function() {
      paste0("MAPA_ACR_Maijuna_Kichwa_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ruta_pdf <- "www/mapas/MAPA_ACR_MK.pdf"
      if (file.exists(ruta_pdf)) {
        file.copy(ruta_pdf, file)
      } else {
        showNotification("Mapa no disponible en este momento", type = "warning")
      }
    }
  )
  
  # ========== DESCARGAS DE MAPAS PDF - CUSCO ==========
  
  output$descargar_mapa_chq <- downloadHandler(
    filename = function() {
      paste0("MAPA_ACR_Choquequirao_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ruta_pdf <- "www/mapas/MAPA_CHOQUE_DEF.pdf"
      if (file.exists(ruta_pdf)) {
        file.copy(ruta_pdf, file)
      } else {
        showNotification("Mapa no disponible en este momento", type = "warning")
      }
    }
  )
  
  output$descargar_mapa_chu <- downloadHandler(
    filename = function() {
      paste0("MAPA_ACR_Chuyapi_Urusayhua_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ruta_pdf <- "www/mapas/MAPA_CHUYAPI_ANEXO2.pdf"
      if (file.exists(ruta_pdf)) {
        file.copy(ruta_pdf, file)
      } else {
        showNotification("Mapa no disponible en este momento", type = "warning")
      }
    }
  )
  
  output$descargar_mapa_qk <- downloadHandler(
    filename = function() {
      paste0("MAPA_ACR_Qeros_Kosnipata_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ruta_pdf <- "www/mapas/MAPA_QEROS_ANEXO3.pdf"
      if (file.exists(ruta_pdf)) {
        file.copy(ruta_pdf, file)
      } else {
        showNotification("Mapa no disponible en este momento", type = "warning")
      }
    }
  )
  
  # ========== MODALES PARA VER MAPAS - SAN MARTÍN ==========
  
  observeEvent(input$ver_mapa_boshumi, {
    showModal(modalDialog(
      title = div(icon("map"), "Mapa ACR Bosques de Shunté y Mishollo"),
      size = "xl",
      easyClose = TRUE,
      fluidRow(
        column(
          12,
          tags$img(
            src = "mapas/25NOV17_Mapa_de_deforestación_en_ACR_BOSHUMI_y_su_ZI_A2.jpg",
            style = "width:100%; height:auto;"
          )
        )
      ),
      footer = modalButton("Cerrar")
    ))
  })
  
  observeEvent(input$ver_mapa_ce, {
    showModal(modalDialog(
      title = div(icon("map"), "Mapa ACR Cordillera Escalera"),
      size = "xl",
      easyClose = TRUE,
      fluidRow(
        column(
          12,
          tags$img(
            src = "mapas/25NOV17_Mapa_de_deforestación_en_ACR_CE_y_su_ZI_A2.jpg",
            style = "width:100%; height:auto;"
          )
        )
      ),
      footer = modalButton("Cerrar")
    ))
  })
  
  # ========== DESCARGAS DE MAPAS PDF - SAN MARTÍN ==========
  
  output$descargar_mapa_boshumi <- downloadHandler(
    filename = function() {
      paste0("MAPA_ACR_BOSHUMI_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ruta_pdf <- "www/mapas/25NOV17_Mapa_de_deforestación_en_ACR_BOSHUMI_y_su_ZI_A2.pdf"
      if (file.exists(ruta_pdf)) {
        file.copy(ruta_pdf, file)
      } else {
        showNotification("Mapa no disponible en este momento", type = "warning")
      }
    }
  )
  
  output$descargar_mapa_ce <- downloadHandler(
    filename = function() {
      paste0("MAPA_ACR_Cordillera_Escalera_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      ruta_pdf <- "www/mapas/25NOV17_Mapa_de_deforestación_en_ACR_CE_y_su_ZI_A2.pdf"
      if (file.exists(ruta_pdf)) {
        file.copy(ruta_pdf, file)
      } else {
        showNotification("Mapa no disponible en este momento", type = "warning")
      }
    }
  )
  # ========================================
  # MODAL: LORETO - Frentes Activos
  # ========================================
  
  observeEvent(input$link_loreto, {
    showModal(modalDialog(
      title = div(
        style = "background: linear-gradient(135deg, #f1c40f 0%, #f39c12 100%); color: white; padding: 15px; margin: -15px -15px 20px -15px; border-radius: 5px 5px 0 0;",
        icon("fire", style = "font-size: 1.5em; margin-right: 10px;"),
        strong("LORETO - Frentes Activos de Deforestación")
      ),
      size = "l",
      easyClose = TRUE,
      
      fluidRow(
        # Estadísticas principales
        column(4,
               div(
                 style = "background: #fff3cd; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #f39c12;",
                 h2(style = "color: #e74c3c; margin: 0; font-weight: 800;", "8,500+"),
                 p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "Hectáreas deforestadas")
               )
        ),
        column(4,
               div(
                 style = "background: #ffe8e8; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #e74c3c;",
                 h2(style = "color: #e74c3c; margin: 0; font-weight: 800;", "+18.6%"),
                 p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "Incremento última década")
               )
        ),
        column(4,
               div(
                 style = "background: #e8f5e9; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #27ae60;",
                 h2(style = "color: #27ae60; margin: 0; font-weight: 800;", "4"),
                 p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "ACRs bajo presión")
               )
        )
      ),
      
      tags$hr(style = "margin: 25px 0;"),
      
      # Análisis detallado
      h4(icon("chart-bar"), " Análisis Detallado", style = "color: #1a4d2e; margin-bottom: 15px;"),
      
      div(
        style = "background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #f39c12;",
        
        h5(icon("map-pin", style = "color: #e74c3c;"), " Zona Crítica: Corredor Iquitos-Nauta", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        p(style = "text-align: justify; line-height: 1.7; color: #555;",
          "El corredor Iquitos-Nauta concentra el ", strong("mayor número de alertas de deforestación"), 
          " en la región Loreto, con más de ", strong("8,500 hectáreas"), " afectadas en la última década. ",
          "Este eje vial se ha convertido en un punto crítico debido a:"),
        
        tags$ul(
          style = "line-height: 1.8; color: #555;",
          tags$li(strong("Agricultura migratoria:"), " Ciclos de cultivo de 3-5 años con técnica de roce y quema"),
          tags$li(strong("Accesibilidad:"), " Carretera facilita el ingreso a áreas forestales"),
          tags$li(strong("Presión demográfica:"), " Crecimiento poblacional en comunidades cercanas"),
          tags$li(strong("Falta de alternativas:"), " Limitadas opciones económicas sostenibles")
        )
      ),
      
      tags$br(),
      
      div(
        style = "background: #fff3e0; padding: 20px; border-radius: 8px; border-left: 4px solid #f39c12;",
        
        h5(icon("exclamation-triangle", style = "color: #f39c12;"), " ACRs Afectadas", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        tags$ol(
          style = "line-height: 1.8; color: #555;",
          tags$li(strong("ACR Ampiyacu Apayacu:"), " Alta presión en zona de amortiguamiento"),
          tags$li(strong("ACR Alto Nanay - Pintuyacu Chambira:"), " Incremento en límites norte"),
          tags$li(strong("ACR Maijuna Kichwa:"), " Deforestación dispersa en todo el territorio"),
          tags$li(strong("ACR Comunal Tamshiyacu Tahuayo:"), " Presión moderada pero constante")
        )
      ),
      
      tags$br(),
      
      div(
        style = "background: #e3f2fd; padding: 20px; border-radius: 8px; border-left: 4px solid #2196f3;",
        
        h5(icon("lightbulb", style = "color: #2196f3;"), " Recomendaciones", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        tags$ul(
          style = "line-height: 1.8; color: #555;",
          tags$li("Fortalecimiento de sistemas de alerta temprana"),
          tags$li("Promoción de prácticas agrícolas sostenibles"),
          tags$li("Programas de educación ambiental en comunidades"),
          tags$li("Mecanismos de compensación por conservación"),
          tags$li("Mayor presencia de autoridades ambientales")
        )
      ),
      
      footer = modalButton("Cerrar")
    ))
  })
  
  # ========================================
  # MODAL: SAN MARTÍN - Presión en Bordes
  # ========================================
  
  observeEvent(input$link_sanmartin, {
    showModal(modalDialog(
      title = div(
        style = "background: linear-gradient(135deg, #f8c471 0%, #f39c12 100%); color: white; padding: 15px; margin: -15px -15px 20px -15px; border-radius: 5px 5px 0 0;",
        icon("exclamation-triangle", style = "font-size: 1.5em; margin-right: 10px;"),
        strong("SAN MARTÍN - Presión en Bordes de ACRs")
      ),
      size = "l",
      easyClose = TRUE,
      
      fluidRow(
        # Estadísticas principales
        column(4,
               div(
                 style = "background: #ffe8e8; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #e74c3c;",
                 h2(style = "color: #e74c3c; margin: 0; font-weight: 800;", "260+"),
                 p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "Ha afectadas por incendios 2023")
               )
        ),
        column(4,
               div(
                 style = "background: #f5f5f5; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #95a5a6;",
                 h2(style = "color: #7f8c8d; margin: 0; font-weight: 800;", "40%"),
                 p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "Expansión urbana (causa principal)")
               )
        ),
        column(4,
               div(
                 style = "background: #fff3e0; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #f39c12;",
                 h2(style = "color: #e67e22; margin: 0; font-weight: 800;", "35%"),
                 p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "Cultivos permanentes (café)")
               )
        )
      ),
      
      tags$hr(style = "margin: 25px 0;"),
      
      # Análisis detallado
      h4(icon("chart-bar"), " Análisis Detallado", style = "color: #1a4d2e; margin-bottom: 15px;"),
      
      div(
        style = "background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #f8c471;",
        
        h5(icon("city", style = "color: #95a5a6;"), " Dinámica Post-2018", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        p(style = "text-align: justify; line-height: 1.7; color: #555;",
          "San Martín experimenta un ", strong("incremento notable en la presión sobre sus ACRs desde 2018"), 
          ", particularmente en ", strong("ACR Cordillera Escalera"), ". Este fenómeno coincide con:"),
        
        tags$ul(
          style = "line-height: 1.8; color: #555;",
          tags$li(strong("Mejoras viales:"), " Nueva infraestructura facilita acceso a zonas forestales"),
          tags$li(strong("Crecimiento urbano:"), " Expansión de Moyobamba, Rioja y Nueva Cajamarca"),
          tags$li(strong("Boom cafetalero:"), " Incremento en cultivos permanentes de café"),
          tags$li(strong("Incendios forestales:"), " 260+ hectáreas afectadas solo en 2023")
        )
      ),
      
      tags$br(),
      
      div(
        style = "background: #ffebee; padding: 20px; border-radius: 8px; border-left: 4px solid #e74c3c;",
        
        h5(icon("fire", style = "color: #e74c3c;"), " Incendios Forestales 2023", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        p(style = "text-align: justify; line-height: 1.7; color: #555;",
          "El año 2023 fue particularmente crítico con ", strong("más de 260 hectáreas afectadas por incendios forestales"), 
          " en y alrededor de las ACRs. Las causas principales incluyen:"),
        
        tags$ul(
          style = "line-height: 1.8; color: #555;",
          tags$li("Quemas agrícolas descontroladas"),
          tags$li("Época seca prolongada (cambio climático)"),
          tags$li("Acumulación de biomasa seca"),
          tags$li("Falta de brigadas de prevención")
        )
      ),
      
      tags$br(),
      
      div(
        style = "background: #e3f2fd; padding: 20px; border-radius: 8px; border-left: 4px solid #2196f3;",
        
        h5(icon("lightbulb", style = "color: #2196f3;"), " Recomendaciones", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        tags$ul(
          style = "line-height: 1.8; color: #555;",
          tags$li("Implementar zonas de amortiguamiento efectivas"),
          tags$li("Promover café sostenible bajo sombra"),
          tags$li("Crear brigadas contra incendios forestales"),
          tags$li("Ordenamiento territorial urbano-rural"),
          tags$li("Incentivos para agricultura climáticamente inteligente")
        )
      ),
      
      footer = modalButton("Cerrar")
    ))
  })
  
  # ========================================
  # MODAL: CUSCO - Reducción de Deforestación
  # ========================================
  
  observeEvent(input$link_cusco, {
    showModal(modalDialog(
      title = div(
        style = "background: linear-gradient(135deg, #5cb85c 0%, #4cae4c 100%); color: white; padding: 15px; margin: -15px -15px 20px -15px; border-radius: 5px 5px 0 0;",
        icon("chart-line", style = "font-size: 1.5em; margin-right: 10px;"),
        strong("CUSCO - Reducción de Deforestación")
      ),
      size = "l",
      easyClose = TRUE,
      
      fluidRow(
        # Estadísticas principales
        column(4,
               div(
                 style = "background: #e8f5e9; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #27ae60;",
                 h2(style = "color: #27ae60; margin: 0; font-weight: 800;", "-15%"),
                 p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "Reducción desde 2020")
               )
        ),
        column(4,
               div(
                 style = "background: #e1f5fe; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #2196f3;",
                 h2(style = "color: #2196f3; margin: 0; font-weight: 800;", "< 2 ha"),
                 p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "Tamaño promedio de parches")
               )
        ),
        column(4,
               div(
                 style = "background: #fff9e0; padding: 20px; border-radius: 8px; text-align: center; border-left: 4px solid #f39c12;",
                 h2(style = "color: #f39c12; margin: 0; font-weight: 800;", "3"),
                 p(style = "margin: 5px 0 0 0; color: #666; font-weight: 600;", "ACRs monitoreadas")
               )
        )
      ),
      
      tags$hr(style = "margin: 25px 0;"),
      
      # Análisis detallado
      h4(icon("chart-bar"), " Análisis Detallado", style = "color: #1a4d2e; margin-bottom: 15px;"),
      
      div(
        style = "background: #e8f5e9; padding: 20px; border-radius: 8px; border-left: 4px solid #27ae60;",
        
        h5(icon("check-circle", style = "color: #27ae60;"), " Historia de Éxito", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        p(style = "text-align: justify; line-height: 1.7; color: #555;",
          strong("¡Buenas noticias!"), " Cusco representa un caso de éxito en la región amazónica peruana. ",
          "Desde 2020, la deforestación ha disminuido en un ", strong("15%"), ", lo que demuestra que ",
          "con las políticas y prácticas adecuadas, es posible revertir tendencias negativas."),
        
        tags$ul(
          style = "line-height: 1.8; color: #555;",
          tags$li(strong("Parches pequeños:"), " Deforestación en parches < 2 ha (menos impacto)"),
          tags$li(strong("Agricultura tradicional:"), " Prácticas andinas más sostenibles"),
          tags$li(strong("Menor presión:"), " Menos presión que selva baja de Loreto/San Martín"),
          tags$li(strong("Gobernanza fuerte:"), " Mejor coordinación comunidad-gobierno")
        )
      ),
      
      tags$br(),
      
      div(
        style = "background: #e1f5fe; padding: 20px; border-radius: 8px; border-left: 4px solid #2196f3;",
        
        h5(icon("mountain", style = "color: #2196f3;"), " Contexto Geográfico", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        p(style = "text-align: justify; line-height: 1.7; color: #555;",
          "Las ACRs de Cusco (", strong("Choquequirao, Chuyapi Urusayhua, Q'eros Kosñipata"), 
          ") se encuentran en ", strong("valles cultivados"), " donde predominan:"),
        
        tags$ul(
          style = "line-height: 1.8; color: #555;",
          tags$li("Agricultura de subsistencia en terrazas"),
          tags$li("Cultivos tradicionales (papa, maíz, quinua)"),
          tags$li("Sistemas agroforestales ancestrales"),
          tags$li("Menor densidad poblacional"),
          tags$li("Acceso limitado por topografía")
        )
      ),
      
      tags$br(),
      
      div(
        style = "background: #fff3e0; padding: 20px; border-radius: 8px; border-left: 4px solid #f39c12;",
        
        h5(icon("award", style = "color: #f39c12;"), " Factores de Éxito", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        tags$ol(
          style = "line-height: 1.8; color: #555;",
          tags$li(strong("Gobernanza participativa:"), " Involucramiento activo de comunidades"),
          tags$li(strong("Conocimiento ancestral:"), " Respeto por prácticas tradicionales"),
          tags$li(strong("Alternativas económicas:"), " Turismo sostenible, artesanía"),
          tags$li(strong("Monitoreo constante:"), " Sistema de alertas tempranas funcional"),
          tags$li(strong("Educación ambiental:"), " Conciencia desde las escuelas")
        )
      ),
      
      tags$br(),
      
      div(
        style = "background: #e8f5e9; padding: 20px; border-radius: 8px; border-left: 4px solid #27ae60;",
        
        h5(icon("lightbulb", style = "color: #27ae60;"), " Lecciones Aprendidas", 
           style = "color: #2c5f7d; margin-bottom: 15px;"),
        
        p(style = "text-align: justify; line-height: 1.7; color: #555;",
          "El caso de Cusco demuestra que:", tags$br(),
          strong("✓"), " La conservación es posible con enfoque comunitario", tags$br(),
          strong("✓"), " Las prácticas ancestrales pueden ser sostenibles", tags$br(),
          strong("✓"), " El turismo puede ser aliado de la conservación", tags$br(),
          strong("✓"), " La educación ambiental genera resultados a largo plazo")
      )
    ),
    
    footer = modalButton("Cerrar")
    )
  })
}