# Instala ping local en segundo plano (al iniciar sesion en Windows).
$ErrorActionPreference = "Stop"
$TaskName = "ACR-Dashboard-KeepAlive"
$Root = Split-Path $PSScriptRoot -Parent
$LoopScript = Join-Path $PSScriptRoot "keep_render_awake_loop.py"
$LogDir = Join-Path $Root "logs"
$LogFile = Join-Path $LogDir "keep-alive.log"

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null

$Python = (Get-Command python -ErrorAction SilentlyContinue).Source
$Pythonw = (Get-Command pythonw -ErrorAction SilentlyContinue).Source
if (-not $Pythonw) {
    $Pythonw = $Python -replace "python.exe", "pythonw.exe"
    if (-not (Test-Path $Pythonw)) { $Pythonw = $Python }
}

# Inyectar ruta de log en el script via variable de entorno
$env:ACR_KEEPALIVE_LOG = $LogFile

$LauncherPath = Join-Path $PSScriptRoot "keep_render_awake_launcher.bat"
@"
@echo off
set ACR_KEEPALIVE_LOG=$LogFile
"$Pythonw" "$LoopScript"
"@ | Set-Content -Path $LauncherPath -Encoding ASCII

Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue

$Action = New-ScheduledTaskAction -Execute $LauncherPath -WorkingDirectory $PSScriptRoot
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings `
    -Description "Ping cada 5 min al dashboard ACR en Render (horario laboral)" | Out-Null

# Arrancar ahora
Start-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "Probando ping directo..." -ForegroundColor Yellow
& $Python (Join-Path $PSScriptRoot "keep_render_awake_once.py")

Write-Host ""
Write-Host "Listo." -ForegroundColor Green
Write-Host "  Tarea: $TaskName (al iniciar sesion)"
Write-Host "  Ping cada 5 min, lun-vie 07:00-20:00"
Write-Host "  Log: $LogFile"
Write-Host "  PC debe estar encendido y con sesion iniciada"
Write-Host ""
