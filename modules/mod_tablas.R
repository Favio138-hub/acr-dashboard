# ========================================
# MODULES/MOD_TABLAS.R
# BOTÓN "VER CAUSAS ANTRÓPICAS" ELIMINADO
# los gráficos de arriba se mantienen intactos
# ========================================

tablas_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    #  TODo EL CONTENIDO ELIMINADO - Ya no hay botón ni tabla
    # Los gráficos están en mod_graficos.R, no aquí
    NULL
  )
}

tablas_server <- function(id, filtros_reactive) {
  moduleServer(id, function(input, output, session) {
    
    # SERVIDOR VACÍO - Ya no se necesita nada aquí
    
  })
}