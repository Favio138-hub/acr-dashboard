# ========================================
# SCRIPT DE EJECUCIÓN LOCAL
# Dashboard ACRs Loreto
# ========================================

# Limpiar consola
cat("\014")

# Verificar librerías requeridas
required_packages <- c("shiny", "leaflet", "sf", "dplyr", "plotly", 
                       "DT", "shinythemes", "tidyr", "RColorBrewer", "shinyjs", "zip", "leaflet.extras", "digest")

cat("Verificando librerías necesarias...\n\n")

# REEMPLAZAR ESTA SECCIÓN en run_app.R

for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cat(sprintf("❌ Falta instalar: %s\n", pkg))
    cat(sprintf("   Instalando %s...\n", pkg))
    install.packages(pkg)
  } else {
    cat(sprintf("✅ %s\n", pkg))  
  }
}

cat("\n========================================\n")
cat(" INICIANDO DASHBOARD ACRs LORETO\n")
cat("========================================\n\n")

# Configurar opciones
options(shiny.maxRequestSize = 50*1024^2)  # 50 MB max
options(shiny.port = 8080)  # Puerto personalizado

# Verificar estructura de carpetas
carpetas_requeridas <- c("modules", "utils", "data", "www")
for (carpeta in carpetas_requeridas) {
  if (!dir.exists(carpeta)) {
    cat(sprintf(" ADVERTENCIA: Falta carpeta '%s'\n", carpeta))
  }
}

cat("\n")

# Verificar archivos principales
archivos_principales <- c("global.R", "ui.R", "server.R")
for (archivo in archivos_principales) {
  if (!file.exists(archivo)) {
    stop(sprintf("ERROR: Falta archivo '%s'", archivo))
  }
}

# Verificar CSS
if (!file.exists("www/estilos.css")) {
  cat("ADVERTENCIA: Falta archivo 'www/estilos.css'\n")
  cat("   La aplicación funcionará pero sin estilos personalizados\n\n")
}

# Ejecutar aplicación
cat("Todo listo!\n")
cat("Abriendo aplicación en el navegador...\n")
cat("   (Presiona Ctrl+C en la consola para detener)\n\n")
cat("========================================\n\n")

# Ejecutar
shiny::runApp(launch.browser = TRUE, port = 8080)


