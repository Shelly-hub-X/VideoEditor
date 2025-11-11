# Auto Install All Development Tools
# This script installs Git, CMake, vcpkg to D:\videoeditor-env
# and Visual Studio Build Tools to default location (C:)

$ErrorActionPreference = "Continue"
$envRoot = "D:\videoeditor-env"

Write-Host ""
Write-Host "===== Auto Install - Video Editor Development Environment =====" -ForegroundColor Cyan
Write-Host ""

# Check admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[WARNING] Not running as Administrator" -ForegroundColor Yellow
    Write-Host "Some installations may fail without admin rights." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to cancel and re-run as Administrator, or press Enter to continue anyway..." -ForegroundColor Yellow
    Read-Host
}

Write-Host "[Step 1/6] Creating environment folder: $envRoot" -ForegroundColor Cyan
if (-not (Test-Path "D:\")) {
    Write-Host "[ERROR] Drive D: not found! Cannot proceed." -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $envRoot)) {
    New-Item -ItemType Directory -Path $envRoot -Force | Out-Null
    Write-Host "[OK] Created: $envRoot" -ForegroundColor Green
} else {
    Write-Host "[OK] Folder exists: $envRoot" -ForegroundColor Green
}

Write-Host ""
Write-Host "[Step 2/6] Installing Git..." -ForegroundColor Cyan
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Git already installed" -ForegroundColor Green
} else {
    Write-Host "Installing Git via winget..." -ForegroundColor Yellow
    try {
        winget install --id Git.Git --silent --accept-source-agreements --accept-package-agreements
        Write-Host "[OK] Git installed" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] winget install failed, trying chocolatey..." -ForegroundColor Yellow
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install git -y
        } else {
            Write-Host "[ERROR] Neither winget nor choco available. Please install Git manually from https://git-scm.com/" -ForegroundColor Red
        }
    }
}

# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host ""
Write-Host "[Step 3/6] Installing CMake..." -ForegroundColor Cyan
if (Get-Command cmake -ErrorAction SilentlyContinue) {
    Write-Host "[OK] CMake already installed" -ForegroundColor Green
} else {
    Write-Host "Installing CMake via winget..." -ForegroundColor Yellow
    try {
        winget install --id Kitware.CMake --silent --accept-source-agreements --accept-package-agreements
        Write-Host "[OK] CMake installed" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] winget install failed, trying chocolatey..." -ForegroundColor Yellow
        if (Get-Command choco -ErrorAction SilentlyContinue) {
            choco install cmake -y
        } else {
            Write-Host "[ERROR] Neither winget nor choco available. Please install CMake manually from https://cmake.org/" -ForegroundColor Red
        }
    }
}

# Refresh PATH again
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host ""
Write-Host "[Step 4/6] Installing Visual Studio Build Tools..." -ForegroundColor Cyan
Write-Host "This will take 20-40 minutes. Please be patient..." -ForegroundColor Yellow

$vsInstalled = $false
$vsPaths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat",
    "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
)

foreach ($vsPath in $vsPaths) {
    if (Test-Path $vsPath) {
        Write-Host "[OK] Visual Studio Build Tools already installed at: $vsPath" -ForegroundColor Green
        $vsInstalled = $true
        break
    }
}

if (-not $vsInstalled) {
    Write-Host "Installing Visual Studio Build Tools 2022..." -ForegroundColor Yellow
    try {
        winget install --id Microsoft.VisualStudio.2022.BuildTools --silent --accept-source-agreements --accept-package-agreements --override "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
        Write-Host "[OK] Visual Studio Build Tools installed" -ForegroundColor Green
    } catch {
        Write-Host "[WARNING] Automatic installation may have failed." -ForegroundColor Yellow
        Write-Host "Please manually download and install from:" -ForegroundColor Yellow
        Write-Host "https://visualstudio.microsoft.com/downloads/" -ForegroundColor White
        Write-Host "Select 'Desktop development with C++' workload" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "[Step 5/6] Installing vcpkg to $envRoot\vcpkg..." -ForegroundColor Cyan
$vcpkgPath = "$envRoot\vcpkg"

if (Test-Path "$vcpkgPath\vcpkg.exe") {
    Write-Host "[OK] vcpkg already installed at: $vcpkgPath" -ForegroundColor Green
} else {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "[ERROR] Git not found. Cannot clone vcpkg. Please install Git first." -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Cloning vcpkg repository..." -ForegroundColor Yellow
    Set-Location $envRoot
    git clone https://github.com/microsoft/vcpkg.git
    
    if (Test-Path "$vcpkgPath\bootstrap-vcpkg.bat") {
        Write-Host "Bootstrapping vcpkg..." -ForegroundColor Yellow
        Set-Location $vcpkgPath
        .\bootstrap-vcpkg.bat
        Write-Host "[OK] vcpkg installed" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Failed to clone vcpkg" -ForegroundColor Red
        exit 1
    }
}

# Set VCPKG_ROOT environment variable
Write-Host "Setting VCPKG_ROOT environment variable..." -ForegroundColor Yellow
[System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", $vcpkgPath, "User")
$env:VCPKG_ROOT = $vcpkgPath
Write-Host "[OK] VCPKG_ROOT = $vcpkgPath" -ForegroundColor Green

Write-Host ""
Write-Host "[Step 6/6] Installing FFmpeg and Qt dependencies via vcpkg..." -ForegroundColor Cyan
Write-Host "This will take 30-90 minutes. Please be very patient..." -ForegroundColor Yellow

Set-Location $vcpkgPath

# Check if already installed
$installed = & .\vcpkg.exe list 2>$null

if ($installed -match "ffmpeg") {
    Write-Host "[OK] ffmpeg already installed" -ForegroundColor Green
} else {
    Write-Host "Installing ffmpeg:x64-windows..." -ForegroundColor Yellow
    & .\vcpkg.exe install ffmpeg:x64-windows
}

if ($installed -match "qt6-base") {
    Write-Host "[OK] qt6-base already installed" -ForegroundColor Green
} else {
    Write-Host "Installing qt6-base:x64-windows..." -ForegroundColor Yellow
    & .\vcpkg.exe install qt6-base:x64-windows
}

if ($installed -match "qt6-multimedia") {
    Write-Host "[OK] qt6-multimedia already installed" -ForegroundColor Green
} else {
    Write-Host "Installing qt6-multimedia:x64-windows..." -ForegroundColor Yellow
    & .\vcpkg.exe install qt6-multimedia:x64-windows
}

Write-Host ""
Write-Host "===== Installation Complete! =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "Environment folder: $envRoot" -ForegroundColor Green
Write-Host "vcpkg location: $vcpkgPath" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Close and reopen PowerShell/VS Code to refresh environment variables" -ForegroundColor White
Write-Host "2. Run check_environment.ps1 to verify installation" -ForegroundColor White
Write-Host "3. Run build_and_package.ps1 to build the project" -ForegroundColor White
Write-Host ""
