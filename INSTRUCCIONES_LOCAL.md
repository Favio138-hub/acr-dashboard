# Cómo ejecutar el Dashboard ACR en tu PC (VS Code o terminal)

Esta versión **reemplaza R Shiny** por una web moderna:

- **Backend:** Python + FastAPI + Pandas (misma lógica que `global.R` y `utils/`)
- **Frontend:** HTML + JavaScript + Plotly + Leaflet (misma UI que `ui.R`)

## Requisitos (solo una vez)

1. **Python 3.11 o superior**  
   Descarga: https://www.python.org/downloads/  
   Durante la instalación activa: **“Add python.exe to PATH”**.

2. **(Opcional)** VS Code con extensión **Python** — no es obligatorio; puedes usar solo la terminal.

## Opción A — La más fácil (doble clic)

1. En la carpeta del proyecto (`ACR_dashboard`), haz doble clic en **`iniciar.bat`**.
2. Espera a que termine de instalar dependencias (la primera vez tarda unos minutos).
3. Abre el navegador en: **http://127.0.0.1:8000**

Para cerrar el servidor: ventana negra → `Ctrl + C`.

## Opción B — VS Code (recomendado si ya lo usas)

1. Abre VS Code → **File → Open Folder** → carpeta `ACR_dashboard`.
2. Terminal integrada: `` Ctrl + ` `` y ejecuta:

```powershell
py -3 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r backend_python\requirements.txt
cd backend_python
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```

Si PowerShell bloquea scripts:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

3. Espere en la terminal el mensaje **`Uvicorn running on http://127.0.0.1:8000`**
4. Abra el navegador y escriba exactamente: **`127.0.0.1:8000`** (o doble clic en `abrir_dashboard.bat`)

**No abra el enlace antes** de ver "Uvicorn running" — si copia el link muy pronto, el navegador dirá que no puede conectar.

## Opción C — Entorno virtual manual (sin VS Code)

```cmd
cd C:\Users\TU_USUARIO\Desktop\ACR_dashboard
py -3 -m venv .venv
.venv\Scripts\activate
pip install -r backend_python\requirements.txt
cd backend_python
uvicorn main:app --reload --port 8000
```

## Qué verás (igual que la app R)

| Pestaña | Contenido |
|---------|-----------|
| **Dashboard** | Filtros, 4 KPIs, mapa con puntos de deforestación, gráficos Plotly |
| **Metodología** | Texto metodológico |
| **Reportes y Descargas** | Galería de mapas JPG (carpeta `www/mapas` del proyecto R) |
| **Tendencias** | Serie temporal 2001-2024 por ACR seleccionada |

## Datos que usa el backend

- Estadísticas y causas: mismos números que `utils/cargar_datos.R`
- Variación anual KPI: `utils/datos_temporales_acr.R` (2024 vs 2023)
- Puntos del mapa: archivos `data/deforestacion_*.rds` (si existen en el proyecto)
- Mapas en Reportes: `www/mapas/*.jpg` (los del Shiny original)

## Paridad con el dashboard Shiny (shinyapps.io)

Para que el mapa muestre **polígonos reales** ACR/ZI (no solo puntos) y las **tendencias dinámicas** funcionen igual que el original:

```cmd
exportar_datos.bat
```

Esto genera:
- `data/cache/centroides_deforestacion.csv` — puntos rojos con clustering
- `data/cache/geojson/acr_all.geojson` — polígonos ACR con popup de estadísticas y decreto
- `data/cache/geojson/zi_all.geojson` — zonas de influencia
- `data/cache/geojson/limites.geojson` — límites departamentales

Luego `iniciar.bat` y abra **http://127.0.0.1:8000**

## Mapa: archivos .rds de deforestación

Los archivos `data/deforestacion_*.rds` son objetos espaciales de **R (paquete sf)**. Python no puede leerlos directamente; se genera un cache CSV una sola vez:

```cmd
Rscript scripts\export_centroides_cache.R
```

Esto crea `data/cache/centroides_deforestacion.csv` (puntos rojos del mapa).  
`iniciar.bat` ejecuta este paso automáticamente si tienes **R** instalado.

En R, instala sf si falta: `install.packages("sf")`

## Solución de problemas

| Problema | Solución |
|----------|----------|
| `python no se reconoce` | Reinstala Python marcando PATH, o usa `py -3` en lugar de `python` |
| Errores `Invalid file` en .rds al iniciar | Normal con pyreadr; reinicia con `iniciar.bat` tras instalar R y exportar cache |
| Página en blanco / error API | Asegúrate de abrir **http://127.0.0.1:8000** (no abras `index.html` directo) |
| Mapa sin puntos rojos | Ejecuta `Rscript scripts\export_centroides_cache.R` y reinicia el servidor |
| `deforestacion_ACR_CE.rds no existe` | Es esperado si ese archivo no está en tu carpeta `data/` (igual que en Shiny) |
| Galería sin imágenes | Copia la carpeta `www/mapas` del proyecto Shiny al mismo nivel que `frontend/` |

## API de documentación

Con el servidor encendido: **http://127.0.0.1:8000/docs**

## Comparación con R Shiny

| R Shiny | Esta versión |
|---------|----------------|
| `runApp()` | `iniciar.bat` o `uvicorn` |
| `global.R` carga al inicio | FastAPI `lifespan` |
| `reactive()` | Llamadas `fetch` a `/api/*` |
| `plotlyOutput` | Plotly.js |
| `leafletOutput` | Leaflet + clustering |

Ya **no necesitas R instalado** para usar el dashboard web.
