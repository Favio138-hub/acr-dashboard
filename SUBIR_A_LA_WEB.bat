@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Subir Dashboard ACR a la web

set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"

echo.
echo  SUBIR DASHBOARD A LA WEB (GitHub + Render.com)
echo.

git --version >nul 2>&1
if errorlevel 1 (
    echo Instalando Git...
    winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
    set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"
)

git config --global user.name >nul 2>&1
if errorlevel 1 (
    echo.
    echo  Primera vez: ejecute CONFIGURAR_GIT.bat y vuelva aqui.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\deploy_web.ps1"
