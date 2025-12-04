#!/usr/bin/env pwsh
<#
  Run the dev environment:
  - Check Docker daemon
  - Bring up Postgres via docker-compose
  - Initialize DB schema
  - Print next steps to start backend and frontend
  Usage: run this from the repo root in PowerShell
    cd <project-root> ; .\backend\run-dev.ps1
#>

Set-StrictMode -Version Latest
Write-Host "Starting development environment orchestration..." -ForegroundColor Cyan

# Ensure Docker daemon is running
try {
    Write-Host "Checking Docker daemon..." -ForegroundColor Cyan
    & .\backend\scripts\check-docker.ps1
} catch {
    Write-Host "Docker check failed. Please start Docker Desktop and retry." -ForegroundColor Red
    exit 1
}

Write-Host "Bringing up Docker Compose services (Postgres)..." -ForegroundColor Cyan
cd .\backend
docker compose up -d

# Wait for Postgres to be ready
Write-Host "Waiting for Postgres to be ready (will check for 30 seconds)..." -ForegroundColor Cyan
$tryFor = 30
for ($i=0; $i -lt $tryFor; $i++) {
  $composeContainer = (docker compose ps -q postgres 2>$null) -ne ''
  if ($composeContainer) {
    # Try a simple psql command to see if the DB is ready
    try {
      docker compose exec -T postgres psql -U task_user -d task_manager -c '\q' 2>$null
      if ($LASTEXITCODE -eq 0) {
        Write-Host "Postgres is ready." -ForegroundColor Green
        break
      }
    } catch {
      # not ready yet
    }
  }
  Start-Sleep -Seconds 1
  Write-Host -NoNewline "."
}

if ($composeContainer -eq $false) {
  Write-Host "Failed to detect 'postgres' service in docker-compose. Ensure Docker Compose started correctly." -ForegroundColor Yellow
}

Write-Host "Initializing DB schema (if missing)..." -ForegroundColor Cyan
cd ..
.
\init-db.ps1

Write-Host "\nDone. Next steps:\n" -ForegroundColor Cyan
Write-Host "1) In one PowerShell window, start the backend api: (same session must have DATABASE_URL set)" -ForegroundColor Green
Write-Host "   cd backend\api" -ForegroundColor Magenta
Write-Host "   $env:DATABASE_URL = \"postgres://task_user:task_pass@127.0.0.1:5433/task_manager\"" -ForegroundColor Magenta
Write-Host "   cargo run" -ForegroundColor Magenta

Write-Host "2) In a separate PowerShell window, start the frontend dev server" -ForegroundColor Green
Write-Host "   cd frontend/web" -ForegroundColor Magenta
Write-Host "   npm start" -ForegroundColor Magenta

Write-Host "3) Open http://localhost:3000" -ForegroundColor Cyan
