#!/usr/bin/env pwsh
<#
  Check prerequisites for building the Rust API on Windows (MSVC toolchain)
  - Checks for `link.exe` and rustup
  - Gives user instructions for missing items
#>

Write-Host "Checking prerequisites for backend/api..." -ForegroundColor Cyan

$link = Get-Command link.exe -ErrorAction SilentlyContinue
if (-not $link) {
    Write-Host "
WARNING: Visual C++ linker (link.exe) not found in PATH.
On Windows, you typically need 'Build Tools for Visual Studio' and the 'Desktop development with C++' workload installed.
To install, visit:
https://visualstudio.microsoft.com/visual-cpp-build-tools/" -ForegroundColor Yellow
} else {
    Write-Host "Found link.exe: $($link.Path)" -ForegroundColor Green
}

$rustup = Get-Command rustup -ErrorAction SilentlyContinue
if (-not $rustup) {
    Write-Host "rustup is not installed. Install from https://rustup.rs/" -ForegroundColor Yellow
} else {
    $toolchain = & rustup show active-toolchain 2>$null
    Write-Host "Active Rust toolchain: $toolchain" -ForegroundColor Green
}

Write-Host "\nRemember to set the DATABASE_URL environment variable before running the server, for example:\n" -ForegroundColor Cyan
Write-Host "PowerShell:  $env:DATABASE_URL = \"postgres://username:password@127.0.0.1:5432/task_manager\"" -ForegroundColor Magenta

Write-Host "\nIf you prefer to avoid the MSVC toolchain, consider using WSL or the GNU toolchain (MSYS2 + mingw)." -ForegroundColor Cyan
