# Configura ping externo fiable para evitar "Welcome to Render" (plan free).
# Ejecutar: powershell -ExecutionPolicy Bypass -File scripts/configurar_ping_render.ps1

$HealthUrl = "https://acr-dashboard-5iqz.onrender.com/api/health"
$DashboardUrl = "https://acr-dashboard-5iqz.onrender.com/"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  MANTENER DASHBOARD DESPIERTO (GRATIS)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Probando servidor..." -ForegroundColor Yellow
try {
    $r = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 120
    Write-Host "   OK — HTTP $($r.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   El servidor tardo o esta dormido (normal en plan free)." -ForegroundColor DarkYellow
    Write-Host "   Tras configurar el ping, la primera visita sera mas rapida." -ForegroundColor DarkYellow
}

Write-Host ""
Write-Host "2. URL para el monitor (copiada al portapapeles):" -ForegroundColor Yellow
Write-Host "   $HealthUrl" -ForegroundColor White
Set-Clipboard -Value $HealthUrl

Write-Host ""
Write-Host "3. OPCION A — cron-job.org (RECOMENDADA, ~2 min)" -ForegroundColor Green
Write-Host "   a) Crear cuenta: https://console.cron-job.org/signup"
Write-Host "   b) Cronjobs -> Create cronjob"
Write-Host "   c) Title: ACR Dashboard"
Write-Host "   d) URL: pegar la URL del portapapeles"
Write-Host "   e) Schedule: Every 5 minutes (o Every 1 minute si esta disponible)"
Write-Host "   f) Guardar y activar (Enabled)"
Write-Host ""

Write-Host "4. OPCION B — UptimeRobot (alternativa)" -ForegroundColor Green
Write-Host "   a) https://uptimerobot.com -> Add monitor -> HTTP(s)"
Write-Host "   b) URL: misma del portapapeles"
Write-Host "   c) Interval: 5 minutes"
Write-Host ""

Write-Host "5. Habilitar GitHub Actions (refuerzo, no suficiente solo):" -ForegroundColor Yellow
Write-Host "   https://github.com/Favio138-hub/acr-dashboard/actions"
Write-Host "   Debe estar ON y verde 'Keep Render awake'"
Write-Host ""

$open = Read-Host "Abrir cron-job.org ahora? (S/N)"
if ($open -match "^[Ss]") {
    Start-Process "https://console.cron-job.org/members/jobs/create"
}

Write-Host ""
Write-Host "Listo. Con cron-job.org cada 5 min NO deberia salir la pantalla Render en horario laboral." -ForegroundColor Green
Write-Host ""
