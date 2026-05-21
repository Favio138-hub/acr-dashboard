#Requires -Version 5.1
<#
.SYNOPSIS
  Prepara y sube el Dashboard ACR (Python) a GitHub + Render.com
.USAGE
  Doble clic: SUBIR_A_LA_WEB.bat
  O: powershell -ExecutionPolicy Bypass -File scripts\deploy_web.ps1
#>
param(
    [string]$RepoName = "acr-dashboard",
    [string]$GitHubUser = "",
    [switch]$SkipPush
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "    OK: $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "    AVISO: $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "    ERROR: $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Green
Write-Host "   SUBIR DASHBOARD ACR A LA WEB (Render.com)" -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Green
Write-Host ""

# --- 1. Verificar cache (mapa en la nube) ---
Write-Step "Comprobando datos para el mapa..."
$csv = Join-Path $Root "data\cache\centroides_deforestacion.csv"
$geo = Join-Path $Root "data\cache\geojson\acr_all.geojson"
if (-not (Test-Path $csv)) {
    Write-Err "Falta data\cache\centroides_deforestacion.csv"
    Write-Host "    Ejecute primero: exportar_datos.bat" -ForegroundColor Yellow
    Read-Host "Enter para salir"
    exit 1
}
if (-not (Test-Path $geo)) {
    Write-Warn "Falta GeoJSON. Ejecute exportar_datos.bat (paso 2) para poligonos."
} else {
    Write-Ok "Cache listo (CSV + GeoJSON)"
}

# --- 2. Git ---
Write-Step "Comprobando Git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Err "Git no instalado. Descargue: https://git-scm.com/download/win"
    Read-Host "Enter para salir"
    exit 1
}

if (-not (Test-Path (Join-Path $Root ".git"))) {
    git init
    git branch -M main
    Write-Ok "Repositorio git inicializado"
}

# Git LFS para mapas grandes (~100 MB en www/mapas)
$mapasDir = Join-Path $Root "www\mapas"
if (Test-Path $mapasDir) {
    if (Get-Command git-lfs -ErrorAction SilentlyContinue) {
        git lfs install 2>$null | Out-Null
        git lfs track "www/mapas/*.jpg" 2>$null | Out-Null
        git lfs track "www/mapas/*.pdf" 2>$null | Out-Null
        if (Test-Path ".gitattributes") { Write-Ok "Git LFS configurado para mapas" }
    } else {
        Write-Warn "Instale Git LFS si el push falla por tamano: https://git-lfs.com"
    }
}

# No subir deploy.R si contiene token (opcional)
if (Test-Path "deploy.R") {
    $deployContent = Get-Content "deploy.R" -Raw -ErrorAction SilentlyContinue
    if ($deployContent -match 'setAccountInfo|token') {
        Write-Warn "deploy.R contiene credenciales Shiny - no se incluira en el commit."
        if (-not (Test-Path ".git\info\exclude")) { New-Item -ItemType Directory -Force -Path ".git\info" | Out-Null }
        "deploy.R" | Add-Content ".git\info\exclude" -ErrorAction SilentlyContinue
    }
}

Write-Step "Preparando commit..."
git add -A
$status = git status --porcelain
if (-not $status) {
    Write-Ok "No hay cambios nuevos; el repo ya esta actualizado."
} else {
    git commit -m "Deploy: Dashboard ACR web (Python + cache mapa)"
    Write-Ok "Commit creado"
}

if ($SkipPush) {
    Write-Warn "Omitiendo push (-SkipPush). Suba manualmente a GitHub."
    exit 0
}

# --- 3. GitHub ---
Write-Step "Subiendo a GitHub..."
$hasGh = Get-Command gh -ErrorAction SilentlyContinue
$remoteUrl = ""

if ($hasGh) {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Warn "GitHub CLI no autenticado. Ejecute: gh auth login"
        $hasGh = $false
    }
}

if ($hasGh) {
    if (-not $GitHubUser) {
        $GitHubUser = (gh api user -q .login 2>$null)
    }
    $existing = git remote get-url origin 2>$null
    if (-not $existing) {
        Write-Host "    Creando repositorio: $RepoName" -ForegroundColor Gray
        gh repo create $RepoName --public --source=. --remote=origin --push 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Repositorio creado y codigo subido"
            $remoteUrl = gh repo view --json url -q .url 2>$null
        } else {
            Write-Warn "gh repo create fallo; configure remote manualmente."
        }
    } else {
        git push -u origin main 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Push a origin/main completado"
            $remoteUrl = $existing -replace "\.git$","" -replace "git@github.com:","https://github.com/"
        } else {
            Write-Err "git push fallo. Verifique credenciales o tamano de archivos."
        }
    }
} else {
    Write-Warn "Instale GitHub CLI (gh) para automatizar, o suba manualmente:"
    Write-Host "    1. Cree repo en https://github.com/new  (nombre: $RepoName)" -ForegroundColor White
    Write-Host "    2. git remote add origin https://github.com/SU_USUARIO/$RepoName.git" -ForegroundColor White
    Write-Host "    3. git push -u origin main" -ForegroundColor White
}

# --- 4. Render ---
Write-Step "Despliegue en Render.com"
Write-Host "  PASOS EN RENDER (solo la primera vez):" -ForegroundColor White
Write-Host "  1. Entre en https://dashboard.render.com/" -ForegroundColor White
Write-Host "  2. New - Blueprint" -ForegroundColor White
Write-Host "  3. Conecte GitHub y elija el repo: $RepoName" -ForegroundColor White
Write-Host "  4. Render usara render.yaml automaticamente" -ForegroundColor White
Write-Host "  5. Espere unos minutos. URL: https://acr-dashboard.onrender.com" -ForegroundColor White
Write-Host "  Build: pip install -r backend_python/requirements.txt" -ForegroundColor Gray
Write-Host "  Start: cd backend_python; uvicorn main:app --host 0.0.0.0 --port PORT" -ForegroundColor Gray

if ($remoteUrl) {
    Write-Host "  Repo GitHub: $remoteUrl" -ForegroundColor Green
}

Write-Host "`n  IMPORTANTE: En la nube NO corre R. Debe estar en el repo:" -ForegroundColor Yellow
Write-Host "    - data/cache/centroides_deforestacion.csv" -ForegroundColor Yellow
Write-Host "    - data/cache/geojson/*.geojson" -ForegroundColor Yellow
Write-Host "    - www/mapas/ (reportes PDF/imagenes)`n" -ForegroundColor Yellow

$open = Read-Host "Abrir Render en el navegador? (S/N)"
if ($open -match "^[sS]") {
    Start-Process "https://dashboard.render.com/blueprints"
}

Read-Host "Enter para cerrar"
