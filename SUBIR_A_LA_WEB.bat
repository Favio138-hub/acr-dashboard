@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Subir Dashboard ACR a la web

echo.
echo  SUBIR DASHBOARD A LA WEB (GitHub + Render.com)
echo.
echo  Requisitos:
echo    - Git instalado
echo    - Haber ejecutado exportar_datos.bat antes
echo    - (Opcional) GitHub CLI: gh auth login
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\deploy_web.ps1"
