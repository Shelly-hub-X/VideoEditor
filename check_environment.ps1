# Check Development Environment
# This script checks if all required tools are installed

Write-Host ""
Write-Host "===== Checking Development Environment =====" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check CMake
Write-Host "Checking CMake..." -ForegroundColor Yellow
try {
    $cmake = Get-Command cmake -ErrorAction Stop
    Write-Host "[OK] CMake installed: $($cmake.Version)" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] CMake not found!" -ForegroundColor Red
    Write-Host "  Install: winget install Kitware.CMake" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check Git
Write-Host "Checking Git..." -ForegroundColor Yellow
try {
    $git = Get-Command git -ErrorAction Stop
    Write-Host "[OK] Git installed" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Git not found!" -ForegroundColor Red
    Write-Host "  Install: winget install Git.Git" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check Visual Studio
Write-Host "Checking Visual Studio..." -ForegroundColor Yellow
$vsPaths = @(
    "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat",
    "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat",
    "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat",
    "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"
)

$vsFound = $false
foreach ($path in $vsPaths) {
    if (Test-Path $path) {
        Write-Host "[OK] Visual Studio found: $path" -ForegroundColor Green
        $vsFound = $true
        break
    }
}

if (-not $vsFound) {
    Write-Host "[ERROR] Visual Studio not found!" -ForegroundColor Red
    Write-Host "  Download: https://visualstudio.microsoft.com/downloads/" -ForegroundColor Yellow
    Write-Host "  Select workload: Desktop development with C++" -ForegroundColor Yellow
    $allGood = $false
}
Write-Host ""

# Check vcpkg
Write-Host "Checking vcpkg..." -ForegroundColor Yellow
$vcpkgRoot = $env:VCPKG_ROOT
if ($vcpkgRoot -and (Test-Path "$vcpkgRoot\vcpkg.exe")) {
    Write-Host "[OK] vcpkg found: $vcpkgRoot" -ForegroundColor Green
    
    # Check installed packages
    Write-Host "  Checking installed packages..." -ForegroundColor Cyan
    $packages = & "$vcpkgRoot\vcpkg.exe" list 2>$null
    
    if ($packages -match "ffmpeg") {
        Write-Host "  [OK] ffmpeg installed" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] ffmpeg not installed" -ForegroundColor Yellow
        Write-Host "    Install: cd $vcpkgRoot; .\vcpkg install ffmpeg:x64-windows" -ForegroundColor Yellow
    }
    
    if ($packages -match "qt6-base") {
        Write-Host "  [OK] qt6-base installed" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] qt6-base not installed" -ForegroundColor Yellow
        Write-Host "    Install: cd $vcpkgRoot; .\vcpkg install qt6-base:x64-windows" -ForegroundColor Yellow
    }
    
    if ($packages -match "qt6-multimedia") {
        Write-Host "  [OK] qt6-multimedia installed" -ForegroundColor Green
    } else {
        Write-Host "  [WARNING] qt6-multimedia not installed" -ForegroundColor Yellow
        Write-Host "    Install: cd $vcpkgRoot; .\vcpkg install qt6-multimedia:x64-windows" -ForegroundColor Yellow
    }
} else {
    Write-Host "[ERROR] vcpkg not found!" -ForegroundColor Red
    Write-Host "  Install:" -ForegroundColor Yellow
    Write-Host "    cd C:\" -ForegroundColor White
    Write-Host "    git clone https://github.com/microsoft/vcpkg" -ForegroundColor White
    Write-Host "    cd vcpkg" -ForegroundColor White
    Write-Host "    .\bootstrap-vcpkg.bat" -ForegroundColor White
    Write-Host "    [System.Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'C:\vcpkg', 'User')" -ForegroundColor White
    $allGood = $false
}
Write-Host ""

# Summary
Write-Host "===== Summary =====" -ForegroundColor Cyan
Write-Host ""

if ($allGood) {
    Write-Host "[OK] All required tools are installed!" -ForegroundColor Green
    Write-Host ""
    Write-Host "You can now build the project:" -ForegroundColor Cyan
    Write-Host "  .\build_and_package.ps1" -ForegroundColor White
} else {
    Write-Host "[ERROR] Some required tools are missing!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install the missing tools and run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "For detailed installation instructions, see:" -ForegroundColor Cyan
    Write-Host "  INSTALL_DEPENDENCIES.md" -ForegroundColor White
}

Write-Host ""
