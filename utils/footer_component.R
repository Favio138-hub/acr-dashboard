# ========================================
# FOOTER_COMPONENT.R
# Componente reutilizable de footer para todas las pestañas
# ========================================

#' Footer simple con logo verde y texto
#' 
#' @return tagList con el footer
footer_simple <- function() {
  tagList(
    div(
      style = "
        width: 100%; 
        margin-top: 60px; 
        padding: 40px 0; 
        background: linear-gradient(to bottom, #ffffff 0%, #f8f9fa 100%);
        border-top: 1px solid #e0e0e0;
        text-align: center;
      ",
      
      # Logo circular verde
      div(
        style = "
          width: 80px; 
          height: 80px; 
          margin: 0 auto 20px auto;
          background: linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%);
          border-radius: 50%;
          display: flex;
          align-items: center;
          justify-content: center;
          box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3);
        ",
        icon("leaf", 
             style = "font-size: 40px; color: white;")
      ),
      
      # Texto principal
      p(
        style = "
          margin: 0;
          font-size: 18px;
          color: #1a4d2e;
          font-style: italic;
          font-weight: 500;
          letter-spacing: 0.5px;
        ",
        "Conservando nuestros bosques amazónicos"
      )
    )
  )
}


#' Footer completo con logos de instituciones
#' 
#' @return tagList con el footer completo
footer_completo <- function() {
  tagList(
    div(
      style = "
        width: 100%; 
        margin-top: 60px; 
        padding: 50px 20px 30px 20px; 
        background: linear-gradient(180deg, #ffffff 0%, #f5f5f5 100%);
        border-top: 3px solid #4CAF50;
      ",
      
      # Contenedor principal
      div(
        class = "container",
        
        # Logo y texto principal
        div(
          style = "text-align: center; margin-bottom: 40px;",
          
          # Logo circular verde
          div(
            style = "
              width: 100px; 
              height: 100px; 
              margin: 0 auto 25px auto;
              background: linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%);
              border-radius: 50%;
              display: flex;
              align-items: center;
              justify-content: center;
              box-shadow: 0 6px 20px rgba(76, 175, 80, 0.4);
              transition: all 0.3s;
            ",
            icon("leaf", 
                 style = "font-size: 50px; color: white;")
          ),
          
          # Texto principal
          h4(
            style = "
              margin: 0 0 10px 0;
              font-size: 24px;
              color: #1a4d2e;
              font-style: italic;
              font-weight: 600;
              letter-spacing: 0.5px;
            ",
            "Conservando nuestros bosques amazónicos"
          ),
          
          # Subtexto
          p(
            style = "
              margin: 0;
              font-size: 14px;
              color: #666;
            ",
            "Monitoreo satelital de deforestación en Áreas de Conservación Regional"
          )
        ),
        
        # Línea divisoria
        hr(style = "border-top: 1px solid #e0e0e0; margin: 40px 0;"),
        
        # Sección de instituciones
        div(
          style = "text-align: center;",
          
          p(
            style = "
              margin: 0 0 20px 0;
              font-size: 13px;
              color: #888;
              text-transform: uppercase;
              letter-spacing: 1px;
              font-weight: 600;
            ",
            "Con el apoyo de:"
          ),
          
          # Row de logos (puedes personalizarlo)
          div(
            style = "
              display: flex;
              justify-content: center;
              align-items: center;
              gap: 40px;
              flex-wrap: wrap;
              margin-bottom: 30px;
            ",
            
            # Logo SECO
            div(
              style = "
                padding: 15px 25px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
              ",
              tags$span(
                style = "
                  font-size: 14px;
                  font-weight: 700;
                  color: #2c5f7d;
                ",
                "SECO"
              )
            ),
            
            # Logo Basel Institute
            div(
              style = "
                padding: 15px 25px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
              ",
              tags$span(
                style = "
                  font-size: 14px;
                  font-weight: 700;
                  color: #2c5f7d;
                ",
                "Basel Institute on Governance"
              )
            ),
            
            # Gobiernos Regionales
            div(
              style = "
                padding: 15px 25px;
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 8px rgba(0,0,0,0.1);
              ",
              tags$span(
                style = "
                  font-size: 14px;
                  font-weight: 700;
                  color: #2c5f7d;
                ",
                "GR Loreto | San Martín | Cusco"
              )
            )
          )
        ),
        
        # Copyright y año
        div(
          style = "
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #e0e0e0;
          ",
          p(
            style = "
              margin: 0;
              font-size: 12px;
              color: #999;
            ",
            sprintf("© %s - Dashboard ACRs Amazonía Peruana | Todos los derechos reservados", 
                    format(Sys.Date(), "%Y"))
          )
        )
      )
    )
  )
}


#' Footer minimalista (versión ultra simple)
#' 
#' @return tagList con footer minimalista
footer_minimalista <- function() {
  tagList(
    div(
      style = "
        width: 100%; 
        margin-top: 50px; 
        padding: 30px 0; 
        background: #f8f9fa;
        border-top: 2px solid #4CAF50;
        text-align: center;
      ",
      
      div(
        style = "display: inline-flex; align-items: center; gap: 15px;",
        
        # Logo pequeño
        div(
          style = "
            width: 50px; 
            height: 50px; 
            background: linear-gradient(135deg, #4CAF50 0%, #2E7D32 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 3px 8px rgba(76, 175, 80, 0.3);
          ",
          icon("leaf", style = "font-size: 24px; color: white;")
        ),
        
        # Texto al lado
        tags$span(
          style = "
            font-size: 16px;
            color: #1a4d2e;
            font-style: italic;
            font-weight: 500;
          ",
          "Conservando nuestros bosques amazónicos"
        )
      )
    )
  )
}