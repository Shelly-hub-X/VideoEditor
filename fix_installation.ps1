# Fix Installation Issues
# This script fixes vcpkg clone failure and verifies VS Build Tools

$ErrorActionPreference = "Continue"
$envRoot = "D:\videoeditor-env"

Write-Host ""
Write-Host "===== Fixing Installation Issues =====" -ForegroundColor Cyan
Write-Host ""

# Fix 1: Install vcpkg with retry and mirror options
Write-Host "[Fix 1] Installing vcpkg to $envRoot\vcpkg..." -ForegroundColor Cyan
$vcpkgPath = "$envRoot\vcpkg"

if (Test-Path "$vcpkgPath\vcpkg.exe") {
    Write-Host "[OK] vcpkg already installed" -ForegroundColor Green
} else {
    Write-Host "Attempting to clone vcpkg (with retry)..." -ForegroundColor Yellow
    
    Set-Location $envRoot
    
    # Try official GitHub first
    Write-Host "Try 1: Cloning from GitHub..." -ForegroundColor Cyan
    git clone https://github.com/microsoft/vcpkg.git 2>&1 | Out-Null
    
    if (-not (Test-Path "$vcpkgPath\.git")) {
        Write-Host "GitHub clone failed, trying with --depth 1..." -ForegroundColor Yellow
        Remove-Item $vcpkgPath -Recurse -Force -ErrorAction SilentlyContinue
        git clone --depth 1 https://github.com/microsoft/vcpkg.git 2>&1 | Out-Null
    }
    
    if (-not (Test-Path "$vcpkgPath\.git")) {
        Write-Host "Shallow clone failed, trying Gitee mirror (China)..." -ForegroundColor Yellow
        Remove-Item $vcpkgPath -Recurse -Force -ErrorAction SilentlyContinue
        git clone https://gitee.com/mirrors/vcpkg.git 2>&1 | Out-Null
    }
    
    if (Test-Path "$vcpkgPath\bootstrap-vcpkg.bat") {
        Write-Host "[OK] vcpkg cloned successfully" -ForegroundColor Green
        Write-Host "Bootstrapping vcpkg..." -ForegroundColor Yellow
        Set-Location $vcpkgPath
        .\bootstrap-vcpkg.bat
        
        if (Test-Path "$vcpkgPath\vcpkg.exe") {
            Write-Host "[OK] vcpkg bootstrapped successfully" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] vcpkg bootstrap failed" -ForegroundColor Red
        }
    } else {
        Write-Host "[ERROR] All clone attempts failed" -ForegroundColor Red
        Write-Host "Please check your network connection or proxy settings" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Manual workaround:" -ForegroundColor Cyan
        Write-Host "1. Download vcpkg from: https://github.com/microsoft/vcpkg/archive/refs/heads/master.zip" -ForegroundColor White
        Write-Host "2. Extract to: $vcpkgPath" -ForegroundColor White
        Write-Host "3. Run: $vcpkgPath\bootstrap-vcpkg.bat" -ForegroundColor White
    }
}

# Set VCPKG_ROOT
if (Test-Path "$vcpkgPath\vcpkg.exe") {
    Write-Host "Setting VCPKG_ROOT environment variable..." -ForegroundColor Yellow
    [System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", $vcpkgPath, "User")
    $env:VCPKG_ROOT = $vcpkgPath
    Write-Host "[OK] VCPKG_ROOT = $vcpkgPath" -ForegroundColor Green
}

Write-Host ""
Write-Host "[Fix 2] Checking Visual Studio Build Tools installation..." -ForegroundColor Cyan

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    $vsInstances = & $vswhere -all -prerelease -format json | ConvertFrom-Json
    
    if ($vsInstances.Count -eq 0) {
        Write-Host "[WARNING] VS Build Tools installer exists but no instances found" -ForegroundColor Yellow
        Write-Host "The installer may still be running or needs manual configuration" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Please do one of the following:" -ForegroundColor Cyan
        Write-Host "1. Wait a few minutes and run this script again" -ForegroundColor White
        Write-Host "2. Or manually run Visual Studio Installer and select:" -ForegroundColor White
        Write-Host "   - 'Desktop development with C++' workload" -ForegroundColor White
        Write-Host "   - MSVC v143 build tools" -ForegroundColor White
        Write-Host "   - Windows 10/11 SDK" -ForegroundColor White
    } else {
        Write-Host "[OK] Found Visual Studio installations:" -ForegroundColor Green
        foreach ($instance in $vsInstances) {
            Write-Host "  - $($instance.displayName) at $($instance.installationPath)" -ForegroundColor White
        }
    }
} else {
    Write-Host "[ERROR] Visual Studio Installer not found" -ForegroundColor Red
    Write-Host "Please manually install from: https://visualstudio.microsoft.com/downloads/" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===== Fix Attempt Complete =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "Running environment check..." -ForegroundColor Yellow
Set-Location "C:\Users\Administrator\Desktop\视频剪辑助手"
& .\check_environment.ps1

Write-Host ""
Write-Host "If vcpkg is now installed, next step:" -ForegroundColor Cyan
Write-Host "  Run install_vcpkg_packages.ps1 to install FFmpeg and Qt" -ForegroundColor White
Write-Host ""
