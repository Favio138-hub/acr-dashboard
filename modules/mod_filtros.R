# ========================================
# MODULES/MOD_FILTROS.R
# Módulo de filtros con preselección automática
# ========================================

filtros_ui <- function(id) {
  ns <- NS(id)
  
  wellPanel(
    h5(icon("filter"), strong(" Filtros de Búsqueda")),
    
    selectInput(ns("departamento"), 
                "Departamento:", 
                choices = c("Todos" = "todos", 
                            "Loreto" = "loreto", 
                            "San Martín" = "san_martin",
                            "Cusco" = "cusco"),
                selected = "todos"),
    
    selectInput(ns("ambito"), 
                "Sub categoría territorial:", 
                choices = c("Seleccionar..." = "", 
                            "ACR" = "acr", 
                            "Zona de Influencia" = "zi",
                            "Ambos (ACR + ZI)" = "ambos"),
                selected = ""),
    
    selectizeInput(ns("nombre_acr"), 
                   "Nombre ACR (selección múltiple):", 
                   choices = NULL,  # Se actualiza dinámicamente
                   selected = NULL,
                   multiple = TRUE,
                   options = list(placeholder = 'Seleccionar ACR(s)...')),
    
    hr(),
    uiOutput(ns("info_filtro")),
    
    conditionalPanel(
      condition = "output.mostrar_limpiar",
      ns = ns,
      br(),
      actionButton(ns("limpiar"), "Limpiar Filtros", 
                   class = "btn-warning btn-block",
                   icon = icon("eraser"))
    )
  )
}

filtros_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    # ========== ACTUALIZAR OPCIONES DE ACRs SEGÚN DEPARTAMENTO ==========
    observeEvent(input$departamento, {
      depto <- input$departamento
      
      opciones_acr <- if (depto == "loreto") {
        list(
          "LORETO" = c(
            "ACR Ampiyacu Apayacu" = "ACR_AA",
            "ACR Alto Nanay – Pintuyacu Chambira" = "ACR_ANPCH",
            "ACR Maijuna Kichwa" = "ACR_MK",
            "ACR Comunal Tamshiyacu Tahuayo" = "ACR_CTT"
          )
        )
      } else if (depto == "san_martin") {
        list(
          "SAN MARTÍN" = c(
            "ACR Bosques de Shunté y Mishollo" = "ACR_BSM",
            "ACR Cordillera Escalera" = "ACR_CE"
          )
        )
      } else if (depto == "cusco") {
        list(
          "CUSCO" = c(
            "ACR Choquequirao" = "ACR_CHQ",
            "ACR Chuyapi Urusayhua" = "ACR_CHU",
            "ACR Q'eros Kosñipata" = "ACR_QK"
          )
        )
      } else {
        # Todos los departamentos
        list(
          "LORETO" = c(
            "ACR Ampiyacu Apayacu" = "ACR_AA",
            "ACR Alto Nanay – Pintuyacu Chambira" = "ACR_ANPCH",
            "ACR Maijuna Kichwa" = "ACR_MK",
            "ACR Comunal Tamshiyacu Tahuayo" = "ACR_CTT"
          ),
          "SAN MARTÍN" = c(
            "ACR Bosques de Shunté y Mishollo" = "ACR_BSM",
            "ACR Cordillera Escalera" = "ACR_CE"
          ),
          "CUSCO" = c(
            "ACR Choquequirao" = "ACR_CHQ",
            "ACR Chuyapi Urusayhua" = "ACR_CHU",
            "ACR Q'eros Kosñipata" = "ACR_QK"
          )
        )
      }
      
      # Actualizar selectize con nuevas opciones
      updateSelectizeInput(session, "nombre_acr", 
                           choices = opciones_acr,
                           selected = character(0))
    })
    
    # Reactive para verificar si hay filtros activos
    hay_filtros <- reactive({
      !is.null(input$nombre_acr) && length(input$nombre_acr) > 0 || 
        (!is.null(input$ambito) && input$ambito != "")
    })
    
    output$mostrar_limpiar <- reactive({
      hay_filtros()
    })
    outputOptions(output, "mostrar_limpiar", suspendWhenHidden = FALSE)
    
    # Info de filtros activos
    output$info_filtro <- renderUI({
      if (hay_filtros()) {
        tagList(
          div(style = "background: #006D5B; color: white; padding: 10px; border-radius: 6px;",
              icon("info-circle"), strong(" Filtro Activo:"),
              br(),
              if (!is.null(input$ambito) && input$ambito != "") {
                tags$small(paste("Ámbito:", 
                                 if(input$ambito == "acr") "ACR" 
                                 else if(input$ambito == "zi") "Zona de Influencia" 
                                 else "ACR + ZI"))
              },
              if (!is.null(input$nombre_acr) && length(input$nombre_acr) > 0) {
                tagList(
                  br(), 
                  tags$small(paste("ACRs seleccionadas:", length(input$nombre_acr)))
                )
              }
          )
        )
      }
    })
    
    # Limpiar filtros
    observeEvent(input$limpiar, {
      updateSelectInput(session, "departamento", selected = "todos")
      updateSelectInput(session, "ambito", selected = "")
      updateSelectizeInput(session, "nombre_acr", selected = character(0))
    })
    
    # Retornar valores reactivos
    return(list(
      departamento = reactive(input$departamento),
      ambito = reactive(if(input$ambito == "") NULL else input$ambito),
      nombre_acr = reactive(input$nombre_acr)
    ))
  })
}