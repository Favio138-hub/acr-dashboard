@echo off
chcp 65001 >nul
title Exportar puntos del mapa (requiere R)
cd /d "%~dp0"

set RSCRIPT=
where Rscript >nul 2>&1 && set RSCRIPT=Rscript

if not defined RSCRIPT (
    for /d %%D in ("C:\Program Files\R\R-*") do (
        if exist "%%D\bin\Rscript.exe" set RSCRIPT=%%D\bin\Rscript.exe
    )
)

if not defined RSCRIPT (
    echo.
    echo No se encontro R en este equipo.
    echo.
    echo 1. Instale R: https://cran.r-project.org/bin/windows/base/
    echo 2. Durante la instalacion marque "Save version number in registry"
    echo 3. Abra R y ejecute: install.packages("sf")
    echo 4. Vuelva a ejecutar este archivo exportar_mapa.bat
    echo.
    pause
    exit /b 1
)

echo Usando: %RSCRIPT%
echo.
echo Generando cache del mapa (1-3 minutos)...
"%RSCRIPT%" scripts\export_centroides_cache.R
if %ERRORLEVEL% neq 0 (
    echo.
    echo ERROR en la exportacion. En R ejecute: install.packages("sf")
    pause
    exit /b 1
)

if exist "data\cache\centroides_deforestacion.csv" (
    echo.
    echo LISTO. Cache creado en data\cache\centroides_deforestacion.csv
    echo Ahora ejecute iniciar.bat y abra http://127.0.0.1:8000
) else (
    echo No se genero el archivo CSV.
)
echo.
pause
