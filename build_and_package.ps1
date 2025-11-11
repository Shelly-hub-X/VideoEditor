#!/usr/bin/env powershell
# Video Editor - Build and Package Script

param(
    [switch]$SkipBuild = $false
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "===== Video Editor Build and Package =====" -ForegroundColor Cyan
Write-Host ""

# Step 1: Build project
if (-not $SkipBuild) {
    Write-Host "[1/2] Building project..." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        & .\build.ps1
    } catch {
        Write-Host ""
        Write-Host "[ERROR] Build failed: $_" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "[OK] Build complete!" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host "[SKIP] Build step skipped" -ForegroundColor Yellow
}

# Step 2: Package program
Write-Host "[2/2] Packaging program..." -ForegroundColor Yellow
Write-Host ""

try {
    & .\package.ps1
} catch {
    Write-Host ""
    Write-Host "[ERROR] Packaging failed: $_" -ForegroundColor Red
    exit 1
}

# Done
Write-Host ""
Write-Host "===== All Complete! =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "SUCCESS - Program built and packaged!" -ForegroundColor Green
Write-Host ""
Write-Host "Output: release\VideoEditor\" -ForegroundColor White
Write-Host ""
