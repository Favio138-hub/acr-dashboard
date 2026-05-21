@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Dashboard ACR
color 0A

echo.
echo  DASHBOARD ACR - INICIANDO...
echo  Carpeta: %CD%
echo.

set VENV=%CD%\.venv\Scripts\python.exe

if not exist "%VENV%" (
    echo Creando entorno Python...
    py -3 -m venv .venv 2>nul
    if errorlevel 1 python -m venv .venv 2>nul
)

if not exist "%VENV%" (
    echo.
    echo ERROR: No hay Python. Instale desde https://www.python.org/downloads/
    echo Marque "Add python.exe to PATH" y reinicie el PC.
    echo.
    pause
    exit /b 1
)

echo Instalando paquetes y arrancando servidor...
echo El navegador se abrira cuando el servidor este listo.
echo NO CIERRE ESTA VENTANA.
echo Si hay error, revise: server_log.txt
echo.

"%VENV%" "%CD%\run_server.py"

echo.
echo Servidor detenido.
pause
