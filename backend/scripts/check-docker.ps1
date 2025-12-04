#!/usr/bin/env pwsh
<#
  Check Docker status on Windows and guide the developer to start Docker Desktop
  or ensure the daemon is reachable.
#>
Write-Host "Checking Docker daemon availability..." -ForegroundColor Cyan

try {
    $info = docker info 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Docker CLI returned non-zero exit code"
    }
    Write-Host "Docker CLI detected and the daemon appears available." -ForegroundColor Green
} catch {
    Write-Host "Docker CLI cannot reach the Docker daemon. Please ensure Docker Desktop is running." -ForegroundColor Red
    Write-Host "If you recently installed Docker Desktop, start the app and wait until it's fully started. If you're using WSL, ensure it's configured as the backend." -ForegroundColor Yellow
    Write-Host "Useful checks:" -ForegroundColor Cyan
    Write-Host "  - Start Docker Desktop from Start Menu" -ForegroundColor Magenta
    Write-Host "  - Run \`docker version\` to see client/server status" -ForegroundColor Magenta
    Write-Host "  - If using WSL, ensure the distro is running and Docker WSL 2 backend is enabled" -ForegroundColor Magenta
    exit 1
}
