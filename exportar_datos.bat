@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Exportar datos del mapa
cd /d "%~dp0"

echo Exportando datos para el dashboard web...
echo.

set "RSCRIPT="
where Rscript >nul 2>&1
if !ERRORLEVEL! EQU 0 set "RSCRIPT=Rscript"

if not defined RSCRIPT (
    for /d %%D in ("C:\Program Files\R\R-*") do (
        if exist "%%D\bin\Rscript.exe" set "RSCRIPT=%%D\bin\Rscript.exe"
    )
)

if not defined RSCRIPT (
    echo [ERROR] R no instalado. Necesita R para leer archivos .rds del mapa.
    echo https://cran.r-project.org/bin/windows/base/
    echo Luego en R: install.packages("sf")
    pause
    exit /b 1
)

if not exist "data" mkdir data
if not exist "data\cache" mkdir data\cache"
if not exist "data\cache\geojson" mkdir data\cache\geojson

echo [1/2] Centroides de deforestacion...
"%RSCRIPT%" scripts\export_centroides_cache.R
if !ERRORLEVEL! NEQ 0 goto :error

echo.
echo [2/2] Poligonos ACR y ZI (GeoJSON)...
"%RSCRIPT%" scripts\export_geometrias_geojson.R
if !ERRORLEVEL! NEQ 0 goto :error

echo.
echo [3/3] Miniaturas de mapas (galeria Reportes)...
python scripts\generate_map_thumbs.py
if !ERRORLEVEL! NEQ 0 (
    echo [AVISO] No se generaron thumbs. Instale Python + Pillow o ejecute: python scripts\generate_map_thumbs.py
)

echo.
echo ========================================
echo   EXPORTACION COMPLETADA
echo   Ahora ejecute: iniciar.bat
echo ========================================
pause
exit /b 0

:error
echo.
echo [ERROR] Fallo la exportacion. En R ejecute: install.packages("sf")
pause
exit /b 1
