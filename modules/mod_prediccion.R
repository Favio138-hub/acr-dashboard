# ========================================
# MODULES/MOD_PREDICCION.R
# Módulo de tendencias
# ========================================

prediccion_ui <- function(id) {
  ns <- NS(id)
  
  fluidPage(
    
    fluidRow(
      column(12,
             
             div(
               style = "margin-bottom: 30px;",
               
               # Barra roja superior
               div(
                 style = "background: #d32f2f; color: white; padding: 12px 40px; text-align: center;",
                 h4(
                   style = "margin: 0; font-size: 18px; font-weight: 600;",
                   "Análisis de Tendencias Temporales"
                 )
               ),
               
               # Contenedor azul
               div(
                 style = "background: #2c5f7d; color: white; padding: 30px 40px;",
                 
                 h2(
                   style = "margin: 0 0 20px 0; font-size: 24px; font-weight: 700; text-align: center;",
                   "Análisis histórico de deforestación en ACRs"
                 ),
                 
                 p(
                   style = "margin: 0; font-size: 15px; line-height: 1.7; text-align: justify;",
                   "Análisis histórico de la deforestación en las ACRs del Programa GFP Subnacional (2001-2024). ",
                   "Visualización de tendencias temporales y análisis de patrones de deforestación basados en series de tiempo."
                 )
               )
             )
             
      )
    ),
    
    # Filtros de análisis
    fluidRow(
      column(3,
             wellPanel(
               h5(icon("sliders-h"), strong(" Configuración de Análisis")),
               
               selectInput(ns("tipo_analisis"),
                           "Tipo de Análisis:",
                           choices = c(
                             "Tendencia General" = "general",
                             "Por ACR Individual" = "individual",
                             "Comparativa entre ACRs" = "comparativa"
                           ),
                           selected = "general"),
               
               conditionalPanel(
                 condition = "input.tipo_analisis == 'individual' || input.tipo_analisis == 'comparativa'",
                 ns = ns,
                 selectizeInput(ns("acr_seleccion"),
                                "Seleccionar ACR(s):",
                                choices = list(
                                  "LORETO" = c(
                                    "ACR Ampiyacu Apayacu" = "ACR_AA",
                                    "ACR Alto Nanay" = "ACR_ANPCH",
                                    "ACR Maijuna Kichwa" = "ACR_MK",
                                    "ACR Tamshiyacu Tahuayo" = "ACR_CTT"
                                  ),
                                  "SAN MARTÍN" = c(
                                    "ACR Bosques de Shunté" = "ACR_BSM",
                                    "ACR Cordillera Escalera" = "ACR_CE"
                                  ),
                                  "CUSCO" = c(
                                    "ACR Choquequirao" = "ACR_CHQ",
                                    "ACR Chuyapi Urusayhua" = "ACR_CHU",
                                    "ACR Q'eros Kosñipata" = "ACR_QK"
                                  )
                                ),
                                multiple = TRUE,
                                options = list(placeholder = 'Seleccionar...'))
               ),
               
               sliderInput(ns("rango_anios"),
                           "Rango de Años:",
                           min = 2001,
                           max = 2024,
                           value = c(2001, 2024),
                           step = 1,
                           sep = ""),
               
               checkboxInput(ns("mostrar_tendencia"),
                             "Mostrar línea de tendencia",
                             value = TRUE),
               
               actionButton(ns("btn_analizar"),
                            "🔍 Generar Análisis",
                            class = "btn btn-success btn-block",
                            style = "margin-top: 15px;")
             )
      ),
      # ============ MENSAJE INICIAL (antes de hacer click) ============
      column(9,
             # Mensaje de bienvenida
             conditionalPanel(
               condition = "output.mostrar_mensaje_inicial",
               ns = ns,
               div(
                 style = "text-align: center; padding: 100px 40px; background: #f8f9fa; border-radius: 12px; border: 2px dashed #dee2e6;",
                 icon("chart-line", style = "font-size: 5em; color: #ccc; margin-bottom: 20px;"),
                 h3(style = "color: #666; margin: 0 0 15px 0;", "Análisis de Tendencias"),
                 p(style = "color: #999; font-size: 15px; max-width: 500px; margin: 0 auto;",
                   "Configura los parámetros en el panel izquierdo y haz clic en ",
                   tags$strong("'Generar Análisis'"), 
                   " para visualizar las tendencias de deforestación.")
               )
             ),
             # ============ GRÁFICO DE TENDENCIA (solo después de click) ============
             conditionalPanel(
               condition = "output.mostrar_graficos",
               ns = ns,
               div(class = "panelbox",
                   h5(icon("chart-area"), strong(" Gráfico de Tendencia Temporal"), 
                      class = "section-title"),
                   plotlyOutput(ns("grafico_tendencia"), height = 400)
               )
             )
      )
    )
  )
}

# ========================================
# SERVER
# ========================================

prediccion_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # Reactivo para controlar si se generó el análisis
    analisis_generado <- reactiveVal(FALSE)
    
    # Acción del botón
    observeEvent(input$btn_analizar, {
      analisis_generado(TRUE)
    })
    
    # Controlar qué mostrar
    output$mostrar_mensaje_inicial <- reactive({
      !analisis_generado()
    })
    outputOptions(output, "mostrar_mensaje_inicial", suspendWhenHidden = FALSE)
    
    output$mostrar_graficos <- reactive({
      analisis_generado()
    })
    outputOptions(output, "mostrar_graficos", suspendWhenHidden = FALSE)
    
    # ========== DATOS POR ACR (REALES) ==========
    datos_por_acr <- reactive({
      tipo <- input$tipo_analisis
      seleccion <- input$acr_seleccion
      
      datos <- datos_temporales_reales
      
      # Filtrar por ACR si es individual o comparativa
      if (tipo %in% c("individual", "comparativa") && !is.null(seleccion)) {
        datos <- datos %>% filter(ACR_codigo %in% seleccion)
      }
      
      return(datos)
    })
    
    # ========== GRÁFICO DE TENDENCIA ==========
    output$grafico_tendencia <- renderPlotly({
      
      datos <- datos_por_acr()
      rango <- input$rango_anios
      tipo <- input$tipo_analisis
      
      datos_filtrados <- datos %>%
        filter(Anio >= rango[1] & Anio <= rango[2])
      
      # Cambio porcentual
      if (tipo %in% c("general", "individual")) {
        datos_filtrados <- datos_filtrados %>%
          mutate(Cambio_Pct = c(NA, round(diff(Deforestacion_ha) / head(Deforestacion_ha, -1) * 100, 1)))
      } else {
        datos_filtrados <- datos_filtrados %>%
          group_by(ACR_codigo) %>%
          mutate(Cambio_Pct = c(NA, round(diff(Deforestacion_ha) / head(Deforestacion_ha, -1) * 100, 1))) %>%
          ungroup()
      }
      
      # Gráfico
      if (tipo %in% c("general", "individual")) {
        p <- plot_ly(datos_filtrados, 
                     x = ~Anio, 
                     y = ~Deforestacion_ha,
                     type = 'scatter',
                     mode = 'lines+markers',
                     name = 'Deforestación',
                     line = list(color = '#1a4d2e', width = 3),
                     marker = list(size = 8, color = '#1a4d2e'),
                     text = ~paste0(
                       '<b>Año:</b> ', Anio, '<br>',
                       '<b>Deforestación:</b> ', format(round(Deforestacion_ha, 2), big.mark = ','), ' ha<br>',
                       '<b>% Cambio:</b> ', ifelse(is.na(Cambio_Pct), 'N/A', paste0(Cambio_Pct, '%'))
                     ),
                     hovertemplate = '%{text}<extra></extra>')
        
        if (input$mostrar_tendencia) {
          modelo <- lm(Deforestacion_ha ~ Anio, data = datos_filtrados)
          datos_filtrados$Tendencia <- predict(modelo, newdata = datos_filtrados)
          
          p <- p %>%
            add_trace(x = ~Anio, y = ~Tendencia, data = datos_filtrados,
                      type = 'scatter', mode = 'lines',
                      name = 'Tendencia',
                      line = list(color = '#d9534f', width = 2, dash = 'dash'),
                      text = ~paste0('<b>Tendencia:</b> ', format(round(Tendencia, 2), big.mark = ','), ' ha'),
                      hovertemplate = '%{text}<extra></extra>')
        }
        
        titulo <- if (tipo == "individual") paste0("Tendencia de Deforestación - ", datos_filtrados$ACR_codigo[1]) else "Tendencia de Deforestación (2001-2024)"
        
        p <- p %>% layout(
          title = list(text = titulo, font = list(size = 16)),
          xaxis = list(title = "<b>Año</b>"),
          yaxis = list(title = "<b>Deforestación (ha)</b>"),
          legend = list(orientation = 'h', y = -0.15),
          hovermode = 'x unified'
        )
        
      } else {
        colores <- c('#1a4d2e','#006D5B','#4CAF50','#66c2a5','#f0ad4e','#d9534f','#5cb85c','#337ab7','#8e44ad')
        p <- plot_ly()
        acrs <- unique(datos_filtrados$ACR_codigo)
        
        for (i in seq_along(acrs)) {
          acr <- acrs[i]
          datos_acr <- datos_filtrados %>% filter(ACR_codigo == acr)
          nombre_corto <- gsub("ACR_", "", acr)
          
          p <- p %>%
            add_trace(x = ~Anio, y = ~Deforestacion_ha, data = datos_acr,
                      type = 'scatter', mode = 'lines+markers',
                      name = nombre_corto,
                      line = list(color = colores[i], width = 2.5),
                      marker = list(size = 6, color = colores[i]),
                      text = ~paste0('<b>ACR:</b> ', nombre_corto,
                                     '<br><b>Año:</b> ', Anio,
                                     '<br><b>Deforestación:</b> ', format(round(Deforestacion_ha,2), big.mark = ','), ' ha',
                                     '<br><b>% Cambio:</b> ', ifelse(is.na(Cambio_Pct),'N/A',paste0(Cambio_Pct,'%'))),
                      hovertemplate = '%{text}<extra></extra>')
        }
        
        p <- p %>% layout(
          title = list(text = "Comparativa de Tendencias entre ACRs", font = list(size = 16)),
          xaxis = list(title = "<b>Año</b>"),
          yaxis = list(title = "<b>Deforestación (ha)</b>"),
          legend = list(orientation = 'h', y = -0.15),
          hovermode = 'x unified'
        )
      }
      
      return(p)
    })
    
  })
}