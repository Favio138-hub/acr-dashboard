# ========================================
# MODULES/MOD_GRAFICOS.R
# Módulo de gráficos - COMPLETO
# Con comparativa Y gráficos individuales
# ========================================

graficos_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # ========== GRÁFICOS INDIVIDUALES (1 ACR) ==========
    # NOTA: Solo se renderiza cuando hay 1 ACR seleccionada
    conditionalPanel(
      condition = "output.mostrar_individual",
      ns = ns,
      fluidRow(
        # Gráfico 1: Composición de la deforestación
        column(6,
               div(class = "panelbox",
                   h5(icon("chart-bar"), strong(" Composición de Deforestación"), class = "section-title"),
                   plotlyOutput(ns("grafico_composicion"), height = 300),
                   div(class = "legend-box",
                       div(class = "legend-title", "📊 Desglose por categoría"),
                       tags$p(style = "font-size: 12px; margin: 5px 0;",
                              "Distribución de hectáreas por tipo de alerta en el ACR seleccionada.")
                   )
               )
        ),
        
        # Gráfico 2: Causas antrópicas
        column(6,
               div(class = "panelbox",
                   h5(icon("tractor"), strong(" Principales Causas Antrópicas"), class = "section-title"),
                   plotlyOutput(ns("grafico_causas"), height = 300),
                   div(class = "legend-box",
                       div(class = "legend-title", "🔍 Top 5 causas identificadas"),
                       tags$p(style = "font-size: 12px; margin: 5px 0;",
                              "Ranking de las causas antrópicas con mayor impacto en hectáreas.")
                   )
               )
        )
      ),
      
      # Gráfico 3: Distribución porcentual (full width)
      fluidRow(
        column(12,
               div(class = "panelbox",
                   h5(icon("pie-chart"), strong(" Distribución Porcentual"), class = "section-title"),
                   plotlyOutput(ns("grafico_distribucion"), height = 300),
                   div(class = "legend-box",
                       div(class = "legend-title", "📈 Análisis porcentual"),
                       tags$p(style = "font-size: 12px; margin: 5px 0;",
                              "Proporción de cada categoría respecto al total de deforestación detectada.")
                   )
               )
        )
      )
    ),
    
    # ========== COMPARATIVA (2+ ACRs) - TU CÓDIGO ORIGINAL ==========
    conditionalPanel(
      condition = "output.mostrar_comparativa",
      ns = ns,
      fluidRow(
        column(12,
               div(class = "panelbox",
                   h5(icon("balance-scale"), strong(" Análisis Comparativo Detallado"), class = "section-title"),
                   plotlyOutput(ns("comparativa_detallada"), height = 350),
                   div(class = "legend-box",
                       div(class = "legend-title", "💡 Comparación entre las ACRs seleccionadas"),
                       tags$p(style = "font-size: 12px; margin: 5px 0;",
                              "Este gráfico muestra la comparación directa entre las ACRs que has seleccionado.")
                   )
               )
        )
      )
    )
  )
}

graficos_server <- function(id, filtros_reactive) {
  moduleServer(id, function(input, output, session) {
    
    # ========== CONTROL DE VISIBILIDAD ==========
    
    # Mostrar gráficos individuales (solo 1 ACR seleccionada)
    output$mostrar_individual <- reactive({
      filtros <- filtros_reactive$nombre_acr()
      !is.null(filtros) && length(filtros) == 1
    })
    outputOptions(output, "mostrar_individual", suspendWhenHidden = FALSE)
    
    # Mostrar comparativa (2 o más ACRs seleccionadas) - TU CÓDIGO ORIGINAL
    output$mostrar_comparativa <- reactive({
      filtros <- filtros_reactive$nombre_acr()
      !is.null(filtros) && length(filtros) >= 2
    })
    outputOptions(output, "mostrar_comparativa", suspendWhenHidden = FALSE)
    
    # ========== GRÁFICO 1: COMPOSICIÓN (BARRAS APILADAS) ==========
    output$grafico_composicion <- renderPlotly({
      filtros <- filtros_reactive$nombre_acr()
      
      if (!is.null(filtros) && length(filtros) == 1) {
        ambito <- filtros_reactive$ambito()
        depto <- filtros_reactive$departamento()
        
        if (is.null(ambito) || ambito == "acr") {
          datos <- obtener_datos_filtrados(filtros, depto, "acr")
        } else if (ambito == "zi") {
          datos <- obtener_datos_filtrados(filtros, depto, "zi")
        } else {
          datos_acr <- obtener_datos_filtrados(filtros, depto, "acr")
          datos_zi <- obtener_datos_filtrados(filtros, depto, "zi")
          datos <- bind_rows(datos_acr, datos_zi)
        }
        
        if (nrow(datos) > 0) {
          # Preparar datos para gráfico de barras
          datos_plot <- data.frame(
            Categoria = c("Antrópico", "Natural", "Falsa Alerta"),
            Hectareas = c(
              datos$Antropico[1],
              datos$Perdida_natural[1],
              datos$Falsa_alerta[1]
            ),
            Color = c("#d9534f", "#5cb85c", "#f0ad4e")
          )
          
          plot_ly(datos_plot, x = ~Categoria, y = ~Hectareas, type = 'bar',
                  marker = list(color = ~Color),
                  text = ~paste0(format(round(Hectareas, 2), big.mark = ","), " ha"),
                  textposition = 'outside',
                  hovertemplate = paste('<b>%{x}</b><br>',
                                        'Hectáreas: %{y:,.2f}<br>',
                                        '<extra></extra>')) %>%
            layout(
              xaxis = list(title = ""),
              yaxis = list(title = "<b>Hectáreas</b>"),
              showlegend = FALSE,
              margin = list(t = 20)
            )
        }
      }
    })
    
    # ========== GRÁFICO 2: CAUSAS ANTRÓPICAS (HORIZONTAL) ==========
    output$grafico_causas <- renderPlotly({
      filtros <- filtros_reactive$nombre_acr()
      
      if (!is.null(filtros) && length(filtros) == 1) {
        ambito <- filtros_reactive$ambito()
        depto <- filtros_reactive$departamento()
        
        ambito_val <- if (is.null(ambito)) "acr" else ambito
        
        # ✅ USAR FUNCIÓN CACHEADA
        causas <- obtener_causas_filtradas_cached(filtros, depto, ambito_val)
        
        if (nrow(causas) > 0) {
          # Top 5 causas
          causas_top <- causas %>%
            filter(Area_Ha > 0) %>%
            arrange(desc(Area_Ha)) %>%
            head(5)
          
          if (nrow(causas_top) > 0) {
            plot_ly(causas_top, 
                    y = ~reorder(Causa, Area_Ha), 
                    x = ~Area_Ha,
                    type = 'bar',
                    orientation = 'h',
                    marker = list(color = '#66c2a5'),
                    text = ~paste0(format(round(Area_Ha, 2), big.mark = ","), " ha"),
                    textposition = 'outside',
                    hovertemplate = paste('<b>%{y}</b><br>',
                                          'Área: %{x:,.2f} ha<br>',
                                          '<extra></extra>')) %>%
              layout(
                xaxis = list(title = "<b>Hectáreas</b>"),
                yaxis = list(title = ""),
                margin = list(l = 150, t = 20)
              )
          }
        }
      }
    }) %>%
      bindCache(filtros_reactive$nombre_acr(), 
                filtros_reactive$ambito(), 
                filtros_reactive$departamento())  # ✅ SHINY BINDCACHE
    
    # ========== GRÁFICO 3: DISTRIBUCIÓN PORCENTUAL (DONUT) ==========
    output$grafico_distribucion <- renderPlotly({
      filtros <- filtros_reactive$nombre_acr()
      
      if (!is.null(filtros) && length(filtros) == 1) {
        ambito <- filtros_reactive$ambito()
        depto <- filtros_reactive$departamento()
        
        if (is.null(ambito) || ambito == "acr") {
          datos <- obtener_datos_filtrados(filtros, depto, "acr")
        } else if (ambito == "zi") {
          datos <- obtener_datos_filtrados(filtros, depto, "zi")
        } else {
          datos_acr <- obtener_datos_filtrados(filtros, depto, "acr")
          datos_zi <- obtener_datos_filtrados(filtros, depto, "zi")
          datos <- bind_rows(datos_acr, datos_zi)
        }
        
        if (nrow(datos) > 0) {
          # Calcular porcentajes
          total <- datos$Total[1]
          
          datos_pct <- data.frame(
            Categoria = c("Antrópico", "Natural", "Falsa Alerta"),
            Hectareas = c(
              datos$Antropico[1],
              datos$Perdida_natural[1],
              datos$Falsa_alerta[1]
            ),
            Porcentaje = c(
              round((datos$Antropico[1] / total) * 100, 1),
              round((datos$Perdida_natural[1] / total) * 100, 1),
              round((datos$Falsa_alerta[1] / total) * 100, 1)
            ),
            Color = c("#d9534f", "#5cb85c", "#f0ad4e")
          )
          
          plot_ly(datos_pct, labels = ~Categoria, values = ~Hectareas, type = 'pie',
                  marker = list(colors = ~Color),
                  textinfo = 'label+percent',
                  textposition = 'outside',
                  hovertemplate = paste('<b>%{label}</b><br>',
                                        'Hectáreas: %{value:,.2f}<br>',
                                        'Porcentaje: %{percent}<br>',
                                        '<extra></extra>'),
                  hole = 0.4) %>%  # Donut chart
            layout(
              showlegend = TRUE,
              legend = list(orientation = 'h', y = -0.1),
              margin = list(t = 20),
              annotations = list(
                text = paste0("<b>", format(round(total, 0), big.mark = ","), " ha</b>"),
                showarrow = FALSE,
                font = list(size = 20, color = "#1a4d2e")
              )
            )
        }
      }
    })
    
    # ========== COMPARATIVA DETALLADA (TU CÓDIGO ORIGINAL) ==========
    output$comparativa_detallada <- renderPlotly({
      filtros <- filtros_reactive$nombre_acr()
      
      if (!is.null(filtros) && length(filtros) >= 2) {
        ambito <- filtros_reactive$ambito()
        depto <- filtros_reactive$departamento()
        
        if (is.null(ambito) || ambito == "acr") {
          datos <- obtener_datos_filtrados(filtros, depto, "acr")
        } else if (ambito == "zi") {
          datos <- obtener_datos_filtrados(filtros, depto, "zi")
        } else {
          datos_acr <- obtener_datos_filtrados(filtros, depto, "acr")
          datos_zi <- obtener_datos_filtrados(filtros, depto, "zi")
          datos_acr$Sufijo <- " (ACR)"
          datos_zi$Sufijo <- " (ZI)"
          datos <- bind_rows(datos_acr, datos_zi)
        }
        
        if (nrow(datos) >= 2) {
          datos$Nombre_corto <- gsub("ACR ", "", datos$Nombre)
          datos$Nombre_corto <- gsub("ZI ", "", datos$Nombre_corto)
          
          if ("Sufijo" %in% names(datos)) {
            datos$Nombre_corto <- paste0(datos$Nombre_corto, datos$Sufijo)
          }
          
          plot_ly(datos, x = ~Nombre_corto, y = ~Antropico, 
                  type = 'bar', name = 'Antrópico', marker = list(color = '#d9534f')) %>%
            add_trace(y = ~Perdida_natural, name = 'Natural', marker = list(color = '#5cb85c')) %>%
            add_trace(y = ~Falsa_alerta, name = 'Falsa Alerta', marker = list(color = '#f0ad4e')) %>%
            layout(
              yaxis = list(title = '<b>Área (hectáreas)</b>'),
              xaxis = list(title = '', tickangle = -45),
              barmode = 'group',
              legend = list(orientation = 'h', y = -0.25),
              margin = list(l = 60, r = 20, t = 40, b = 120)
            )
        }
      }
    })
  })
}