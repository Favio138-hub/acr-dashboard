# Clic derecho -> Ejecutar con PowerShell (si .bat no funciona)
Set-Location $PSScriptRoot
Write-Host "Dashboard ACR - PowerShell" -ForegroundColor Green

$venv = Join-Path $PSScriptRoot ".venv\Scripts\python.exe"
if (-not (Test-Path $venv)) {
    if (Get-Command py -ErrorAction SilentlyContinue) { py -3 -m venv .venv }
    elseif (Get-Command python -ErrorAction SilentlyContinue) { python -m venv .venv }
    else {
        Write-Host "Instale Python 3.11+ desde python.org (Add to PATH)" -ForegroundColor Red
        Read-Host "Enter para salir"
        exit 1
    }
}

Write-Host "Arrancando servidor (navegador cuando este listo)..." -ForegroundColor Cyan
& $venv "$PSScriptRoot\run_server.py"
Read-Host "Enter para cerrar"
