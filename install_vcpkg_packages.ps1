# Install vcpkg Packages (FFmpeg and Qt)
# Run this after vcpkg is successfully installed

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "===== Installing vcpkg Packages =====" -ForegroundColor Cyan
Write-Host ""

# Check VCPKG_ROOT
$vcpkgRoot = $env:VCPKG_ROOT
if (-not $vcpkgRoot) {
    $vcpkgRoot = "D:\videoeditor-env\vcpkg"
    if (-not (Test-Path "$vcpkgRoot\vcpkg.exe")) {
        Write-Host "[ERROR] vcpkg not found at $vcpkgRoot" -ForegroundColor Red
        Write-Host "Please set VCPKG_ROOT environment variable or run fix_installation.ps1 first" -ForegroundColor Yellow
        exit 1
    }
    $env:VCPKG_ROOT = $vcpkgRoot
}

Write-Host "Using vcpkg at: $vcpkgRoot" -ForegroundColor Green
Write-Host ""

if (-not (Test-Path "$vcpkgRoot\vcpkg.exe")) {
    Write-Host "[ERROR] vcpkg.exe not found at $vcpkgRoot" -ForegroundColor Red
    exit 1
}

Set-Location $vcpkgRoot

Write-Host "This will download and compile FFmpeg and Qt6." -ForegroundColor Yellow
Write-Host "It may take 30-90 minutes depending on your CPU and network." -ForegroundColor Yellow
Write-Host ""
Write-Host "Press Ctrl+C to cancel, or press Enter to continue..." -ForegroundColor Cyan
Read-Host

# Check what's already installed
Write-Host "Checking currently installed packages..." -ForegroundColor Cyan
$installed = & .\vcpkg.exe list 2>$null | Out-String

# Install packages
$packages = @(
    @{name="ffmpeg:x64-windows"; desc="FFmpeg video processing library"},
    @{name="qt6-base:x64-windows"; desc="Qt6 base framework"},
    @{name="qt6-multimedia:x64-windows"; desc="Qt6 multimedia module"}
)

foreach ($pkg in $packages) {
    Write-Host ""
    Write-Host "Installing $($pkg.name) ($($pkg.desc))..." -ForegroundColor Cyan
    
    if ($installed -match $pkg.name.Split(':')[0]) {
        Write-Host "[OK] $($pkg.name) already installed" -ForegroundColor Green
    } else {
        Write-Host "Running: vcpkg install $($pkg.name)" -ForegroundColor Yellow
        Write-Host "This may take a long time..." -ForegroundColor Yellow
        & .\vcpkg.exe install $pkg.name
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] $($pkg.name) installed successfully" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Failed to install $($pkg.name)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "===== Package Installation Complete =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed packages:" -ForegroundColor Green
& .\vcpkg.exe list

Write-Host ""
Write-Host "Next step: Run build_and_package.ps1 to build the project" -ForegroundColor Yellow
Write-Host ""
