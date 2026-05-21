# Cómo subir el Dashboard ACR a la web

Tiene **dos versiones** en este proyecto:

| Versión | Archivo para abrir en su PC | Subir a internet |
|---------|----------------------------|------------------|
| **Web moderna** (Python) | `iniciar.bat` | Render, Railway o VPS |
| **R Shiny** (original) | `iniciar_shiny.R.bat` o `deploy.R` | shinyapps.io (como el link actual) |

---

## A) Versión web (Python) — la que creamos con `iniciar.bat`

### En su computadora (orden correcto)

1. Instalar **Python 3.11+** con “Add to PATH”: https://www.python.org/downloads/
2. Instalar **R + sf** (solo para generar datos del mapa la primera vez): https://cran.r-project.org/
3. Doble clic en **`exportar_datos.bat`** (esperar a que termine)
4. Doble clic en **`iniciar.bat`**
5. Esperar el mensaje **`Uvicorn running on http://127.0.0.1:8000`**
6. Navegador: **http://127.0.0.1:8000**

### Subir a internet (automático — recomendado)

1. Doble clic en **`SUBIR_A_LA_WEB.bat`** (o `scripts\deploy_web.ps1`).
2. El script comprueba el cache, crea git, hace commit y (si tiene `gh`) sube a GitHub.
3. En https://render.com → **New** → **Blueprint** → conecte el repo → despliegue automático con `render.yaml`.
4. URL pública: `https://acr-dashboard.onrender.com` (o el nombre que elija).

Requisitos: [Git](https://git-scm.com), [Git LFS](https://git-lfs.com) (mapas ~110 MB), opcional [GitHub CLI](https://cli.github.com) (`gh auth login`).

Guía rápida: **`LEEME_DESPLIEGUE.txt`**

### Subir a internet (manual: Render.com)

1. Suba el proyecto a **GitHub** (sin la carpeta `.venv`, sin archivos `.rds` muy pesados si superan el límite de GitHub).

2. En https://render.com cree un **Web Service**:
   - **Build command:**
     ```bash
     pip install -r backend_python/requirements.txt
     ```
   - **Start command:**
     ```bash
     cd backend_python && uvicorn main:app --host 0.0.0.0 --port $PORT
     ```

3. Suba también en el repo (o por script en build):
   - `data/cache/centroides_deforestacion.csv`
   - `data/cache/geojson/*.geojson`  
   (generados con `exportar_datos.bat` en su PC)

4. La URL pública será algo como: `https://acr-dashboard.onrender.com`

**Nota:** En la nube no puede ejecutar R en cada arranque; debe **commitear el cache** generado localmente.

### Alternativa: Railway / VPS

Mismo comando de inicio. En un VPS Windows o Linux instale Python, copie el proyecto con `data/cache/` y ejecute uvicorn con un servicio systemd o IIS.

---

## B) Versión R Shiny (igual que shinyapps.io)

Si quiere el mismo despliegue que  
https://gfp-subnacional.shinyapps.io/acr-dashboard-loreto/

1. Instale R y RStudio.
2. Instale paquetes: `shiny`, `leaflet`, `sf`, `plotly`, etc. (o ejecute `run_app.R` que los instala).
3. Pruebe local: doble clic **`iniciar_shiny.R.bat`** → abre en puerto **8080**.
4. Para publicar en **shinyapps.io**:
   - Cuenta en https://www.shinyapps.io/
   - En RStudio: instale `rsconnect`
   - Configure token de shinyapps.io
   - Ejecute el script **`deploy.R`** del proyecto (o publique desde RStudio el botón Publish)

```r
# Ejemplo típico en R después de rsconnect::setAccountInfo(...)
rsconnect::deployApp(
  appDir = ".",
  appFiles = c("global.R", "ui.R", "server.R", "modules", "utils", "data", "www"),
  appName = "acr-dashboard-loreto"
)
```

---

## Resumen rápido

| Quiero… | Haga esto |
|---------|-----------|
| Abrir en mi PC la versión nueva | `exportar_datos.bat` → `iniciar.bat` → http://127.0.0.1:8000 |
| Abrir la versión R como antes | `iniciar_shiny.R.bat` → http://127.0.0.1:8080 |
| Publicar versión Python | **`SUBIR_A_LA_WEB.bat`** → Render Blueprint |
| Publicar versión Shiny | `deploy.R` → shinyapps.io |

Si `iniciar.bat` falla, lea el mensaje en la ventana negra (ahora **no se cierra sola**) y compruebe que Python esté instalado con PATH.
