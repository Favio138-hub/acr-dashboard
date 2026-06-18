@echo off
title Instalar ping local - Dashboard ACR
cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar_ping_local.ps1"
echo.
pause
