#!/usr/bin/env pwsh
<#
  Run DB initialization SQL into a running `task_db` container.
  Make sure container exists and is reachable at the name `task_db`.
  Usage:
    cd backend
    .\init-db.ps1
#>

Write-Host "Initializing database (running ./init_db.sql) into container 'task_db' or compose service 'postgres'..." -ForegroundColor Cyan

$sql = Get-Content .\init_db.sql -Raw
if (-not $sql) {
  Write-Host 'init_db.sql is empty or missing!' -ForegroundColor Red
  exit 1
}

# Prefer docker-compose service 'postgres' if present (avoids mixing with a separately-run 'task_db' container.)
$composeContainer = docker compose ps -q postgres 2>$null
if ($composeContainer -ne $null -and $composeContainer.Trim() -ne "") {
    Write-Host "Detected docker-compose service 'postgres' - using docker compose exec to run SQL." -ForegroundColor Green
    Get-Content .\init_db.sql -Raw | docker compose exec -T postgres psql -U task_user -d task_manager
} else {
    # If a standalone container named task_db exists, fallback to it
    $taskDbContainer = docker ps -q --filter "name=task_db"
    if ($taskDbContainer -ne $null -and $taskDbContainer.Trim() -ne "") {
        Write-Host "Detected container 'task_db' - using docker exec to run SQL." -ForegroundColor Green
        Get-Content .\init_db.sql -Raw | docker exec -i task_db psql -U task_user -d task_manager
    } else {
        Write-Host "No container named 'task_db' or compose service 'postgres' found. Please run 'docker compose up -d' or start a container named 'task_db'." -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "Initialization completed (if container and credentials are correct)." -ForegroundColor Green
