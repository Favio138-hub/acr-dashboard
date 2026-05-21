@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Configurar Git - Dashboard ACR

set "GIT=C:\Program Files\Git\cmd"
set "PATH=%GIT%;%GIT%\..\bin;%PATH%"

echo.
echo  CONFIGURAR GIT (primera vez)
echo  ===========================
echo.

git --version >nul 2>&1
if errorlevel 1 (
    echo Git no encontrado. Instalando...
    winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
    set "PATH=C:\Program Files\Git\cmd;C:\Program Files\Git\bin;%PATH%"
)

git --version
echo.

git config --global user.name >nul 2>&1
if errorlevel 1 (
    set /p GNOMBRE="Su nombre para Git (ej: Favio Campos): "
    git config --global user.name "%GNOMBRE%"
)

git config --global user.email >nul 2>&1
if errorlevel 1 (
    set /p GEMAIL="Su correo de GitHub: "
    git config --global user.email "%GEMAIL%"
)

echo.
echo  Configuracion actual:
git config --global user.name
git config --global user.email
echo.
echo  Listo. Ahora ejecute: SUBIR_A_LA_WEB.bat
echo.
pause
