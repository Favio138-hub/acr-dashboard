# ========================================
# SCRIPT DE VERIFICACIÓN DEL DASHBOARD
# Ejecuta este script para verificar que todo esté configurado correctamente
# ========================================

cat("\n========================================\n")
cat("🔍 VERIFICACIÓN DEL DASHBOARD ACR\n")
cat("========================================\n\n")

# ========================================
# 1. VERIFICAR ESTRUCTURA DE ARCHIVOS
# ========================================

cat("📁 1. Verificando estructura de archivos...\n")

archivos_necesarios <- c(
  "global.R",
  "server.R",
  "ui.R",
  "utils/cache_manager.R",
  "utils/helpers.R",
  "utils/cargar_datos.R",
  "utils/semaforo.R",
  "utils/KPI_Calculator.R"
)

archivos_faltantes <- c()

for (archivo in archivos_necesarios) {
  if (file.exists(archivo)) {
    cat(sprintf("   ✅ %s\n", archivo))
  } else {
    cat(sprintf("   ❌ %s - FALTANTE\n", archivo))
    archivos_faltantes <- c(archivos_faltantes, archivo)
  }
}

if (length(archivos_faltantes) > 0) {
  cat("\n⚠️  ADVERTENCIA: Archivos faltantes detectados\n")
  cat("   Por favor verifica la ubicación de estos archivos\n")
} else {
  cat("\n✅ Todos los archivos necesarios están presentes\n")
}

# ========================================
# 2. VERIFICAR PAQUETES
# ========================================

cat("\n📦 2. Verificando paquetes instalados...\n")

paquetes_necesarios <- c(
  "shiny",
  "leaflet",
  "sf",
  "dplyr",
  "plotly",
  "DT",
  "shinythemes",
  "tidyr",
  "shinyjs",
  "zip",
  "leaflet.extras",
  "digest"
)

paquetes_faltantes <- c()

for (paquete in paquetes_necesarios) {
  if (requireNamespace(paquete, quietly = TRUE)) {
    cat(sprintf("   ✅ %s\n", paquete))
  } else {
    cat(sprintf("   ❌ %s - NO INSTALADO\n", paquete))
    paquetes_faltantes <- c(paquetes_faltantes, paquete)
  }
}

if (length(paquetes_faltantes) > 0) {
  cat("\n⚠️  ADVERTENCIA: Paquetes faltantes\n")
  cat("   Instala con: install.packages(c(")
  cat(paste0('"', paquetes_faltantes, '"', collapse = ", "))
  cat("))\n")
} else {
  cat("\n✅ Todos los paquetes necesarios están instalados\n")
}

# ========================================
# 3. VERIFICAR GLOBAL.R
# ========================================

cat("\n📝 3. Verificando configuración de global.R...\n")

if (file.exists("global.R")) {
  contenido_global <- readLines("global.R", warn = FALSE)
  
  # Buscar la línea de cache_manager
  linea_cache <- grep("cache_manager", contenido_global, ignore.case = TRUE)
  
  if (length(linea_cache) > 0) {
    cat("   ✅ cache_manager.R está siendo cargado en global.R\n")
    cat(sprintf("      Línea %d: %s\n", linea_cache[1], 
                trimws(contenido_global[linea_cache[1]])))
  } else {
    cat("   ❌ cache_manager.R NO está siendo cargado en global.R\n")
    cat("      🔧 ACCIÓN REQUERIDA: Agregar esta línea después de helpers.R:\n")
    cat('         source("utils/cache_manager.R", encoding = "UTF-8")\n')
  }
  
  # Verificar que helpers.R está cargado
  linea_helpers <- grep("helpers\\.R", contenido_global)
  if (length(linea_helpers) > 0) {
    cat("   ✅ helpers.R está siendo cargado\n")
  } else {
    cat("   ❌ helpers.R no encontrado en global.R\n")
  }
  
} else {
  cat("   ❌ No se puede encontrar global.R\n")
}

# ========================================
# 4. VERIFICAR FUNCIONES CACHEADAS
# ========================================

cat("\n🔧 4. Verificando disponibilidad de funciones cacheadas...\n")

# Intentar cargar helpers.R primero
if (file.exists("utils/helpers.R")) {
  tryCatch({
    source("utils/helpers.R", encoding = "UTF-8")
    cat("   ✅ helpers.R cargado exitosamente\n")
  }, error = function(e) {
    cat(sprintf("   ❌ Error cargando helpers.R: %s\n", e$message))
  })
}

# Intentar cargar cache_manager.R
if (file.exists("utils/cache_manager.R")) {
  tryCatch({
    source("utils/cache_manager.R", encoding = "UTF-8")
    cat("   ✅ cache_manager.R cargado exitosamente\n")
    
    # Verificar funciones
    if (exists("obtener_datos_filtrados_cached")) {
      cat("   ✅ obtener_datos_filtrados_cached() está disponible\n")
    } else {
      cat("   ❌ obtener_datos_filtrados_cached() NO está disponible\n")
    }
    
    if (exists("obtener_causas_filtradas_cached")) {
      cat("   ✅ obtener_causas_filtradas_cached() está disponible\n")
    } else {
      cat("   ❌ obtener_causas_filtradas_cached() NO está disponible\n")
    }
    
  }, error = function(e) {
    cat(sprintf("   ❌ Error cargando cache_manager.R: %s\n", e$message))
  })
} else {
  cat("   ❌ No se puede encontrar utils/cache_manager.R\n")
}

# ========================================
# 5. RESUMEN FINAL
# ========================================

cat("\n========================================\n")
cat("📊 RESUMEN DE VERIFICACIÓN\n")
cat("========================================\n")

errores_criticos <- 0

if (length(archivos_faltantes) > 0) {
  cat(sprintf("❌ %d archivo(s) faltante(s)\n", length(archivos_faltantes)))
  errores_criticos <- errores_criticos + 1
}

if (length(paquetes_faltantes) > 0) {
  cat(sprintf("❌ %d paquete(s) faltante(s)\n", length(paquetes_faltantes)))
  errores_criticos <- errores_criticos + 1
}

if (file.exists("global.R")) {
  contenido_global <- readLines("global.R", warn = FALSE)
  linea_cache <- grep("cache_manager", contenido_global, ignore.case = TRUE)
  if (length(linea_cache) == 0) {
    cat("❌ cache_manager.R no está siendo cargado\n")
    errores_criticos <- errores_criticos + 1
  }
}

if (errores_criticos == 0) {
  cat("\n✅ ¡TODO ESTÁ CONFIGURADO CORRECTAMENTE!\n")
  cat("   Tu dashboard debería funcionar sin problemas.\n")
} else {
  cat(sprintf("\n⚠️  SE DETECTARON %d PROBLEMA(S) CRÍTICO(S)\n", errores_criticos))
  cat("   Por favor revisa los mensajes anteriores y corrige los errores.\n")
}

cat("\n========================================\n\n")

# ========================================
# 6. INSTRUCCIONES DE CORRECCIÓN
# ========================================

if (errores_criticos > 0) {
  cat("🔧 PASOS PARA CORREGIR:\n\n")
  
  if (!file.exists("utils/cache_manager.R")) {
    cat("1. Asegúrate de que utils/cache_manager.R existe\n")
  }
  
  if (length(paquetes_faltantes) > 0) {
    cat("2. Instala los paquetes faltantes:\n")
    cat("   install.packages(c(")
    cat(paste0('"', paquetes_faltantes, '"', collapse = ", "))
    cat("))\n")
  }
  
  if (file.exists("global.R")) {
    contenido_global <- readLines("global.R", warn = FALSE)
    linea_cache <- grep("cache_manager", contenido_global, ignore.case = TRUE)
    if (length(linea_cache) == 0) {
      cat("3. Edita global.R y agrega esta línea después de helpers.R:\n")
      cat('   source("utils/cache_manager.R", encoding = "UTF-8")\n')
    }
  }
  
  cat("\n")
}

