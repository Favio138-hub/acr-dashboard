@echo off
chcp 65001 >nul
title Dashboard ACR - Version R Shiny (original)
cd /d "%~dp0"

echo ========================================
echo   DASHBOARD R SHINY (version original)
echo   Puerto: http://127.0.0.1:8080
echo ========================================

set RSCRIPT=
where Rscript >nul 2>&1 && set RSCRIPT=Rscript
if not defined RSCRIPT (
    for /d %%D in ("C:\Program Files\R\R-*") do (
        if exist "%%D\bin\Rscript.exe" set "RSCRIPT=%%D\bin\Rscript.exe"
    )
)

if not defined RSCRIPT (
    echo [ERROR] Instale R desde https://cran.r-project.org/
    pause
    exit /b 1
)

echo Iniciando con R...
"%RSCRIPT%" -e "if (!require('shiny')) install.packages('shiny', repos='https://cloud.r-project.org'); source('run_app.R')"
pause
