# Start Kubernetes Dashboard Port Forward
# Usage: .\start-dashboard-portforward.ps1

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Kubernetes Dashboard Port Forward Setup                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Dashboard will be available at: " -NoNewline -ForegroundColor White
Write-Host "https://localhost:8443" -ForegroundColor Green
Write-Host ""

# Kill any existing port-forward on 8443
Write-Host "Checking for existing port-forward processes..." -ForegroundColor Yellow
$existingProcess = Get-NetTCPConnection -LocalPort 8443 -ErrorAction SilentlyContinue
if ($existingProcess) {
    Write-Host "Stopping existing process on port 8443..." -ForegroundColor Yellow
    Stop-Process -Id $existingProcess.OwningProcess -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

Write-Host "Starting port-forward to kubernetes-dashboard service..." -ForegroundColor Yellow
Write-Host ""

# Start port-forward
kubectl port-forward -n kubernetes-dashboard svc/kubernetes-dashboard 8443:443 --address=127.0.0.1

Write-Host ""
Write-Host "✓ Port-forward established!" -ForegroundColor Green
Write-Host "Dashboard URL: https://localhost:8443" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop port-forward" -ForegroundColor Yellow
