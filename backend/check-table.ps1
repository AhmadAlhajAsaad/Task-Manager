#!/usr/bin/env pwsh
<#
  Checks whether the `tasks` table exists in the database and optionally creates it.
  It will try docker compose service first then fallback to task_db container.
#>
Write-Host "Checking if 'tasks' table exists in the DB..." -ForegroundColor Cyan

$sql_check = "SELECT to_regclass('public.tasks') IS NOT NULL as exists;"

# Try docker compose service first
$composeContainer = docker compose ps -q postgres 2>$null
if ($composeContainer -ne $null -and $composeContainer.Trim() -ne "") {
    Write-Host "Using docker compose service 'postgres' to check the schema..." -ForegroundColor Green
    $exists = docker compose exec -T postgres psql -U task_user -d task_manager -t -c $sql_check
} else {
    $taskDbContainer = docker ps -q --filter "name=task_db"
    if ($taskDbContainer -ne $null -and $taskDbContainer.Trim() -ne "") {
        Write-Host "Using container 'task_db' to check the schema..." -ForegroundColor Green
        $exists = docker exec -i task_db psql -U task_user -d task_manager -t -c $sql_check
    } else {
        Write-Host "No DB container found to check." -ForegroundColor Yellow
        exit 1
    }
}

$exists = ($exists | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }) -join "";
if ($exists -like "t") {
    Write-Host "Table 'tasks' exists." -ForegroundColor Green
} else {
    Write-Host "Table 'tasks' does not exist. Initializing..." -ForegroundColor Yellow
    # Try init script
    .\init-db.ps1
}

Write-Host "Done." -ForegroundColor Cyan
