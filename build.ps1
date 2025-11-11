# Video Editor Build Script

Write-Host "===== Video Editor Build =====" -ForegroundColor Cyan
Write-Host ""

# Check CMake
Write-Host "Checking CMake..." -ForegroundColor Yellow
$cmake = Get-Command cmake -ErrorAction SilentlyContinue
if (-not $cmake) {
    Write-Host "Error: CMake not found! Please install CMake." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] CMake installed" -ForegroundColor Green

# Check vcpkg
Write-Host ""
Write-Host "Checking vcpkg..." -ForegroundColor Yellow
$vcpkgPath = $env:VCPKG_ROOT
if (-not $vcpkgPath) {
    Write-Host "Warning: VCPKG_ROOT environment variable not set" -ForegroundColor Yellow
    Write-Host "Enter vcpkg path (or press Enter to skip):"
    $vcpkgPath = Read-Host
}

if ($vcpkgPath -and (Test-Path $vcpkgPath)) {
    Write-Host "[OK] vcpkg path: $vcpkgPath" -ForegroundColor Green
    $vcpkgToolchain = "$vcpkgPath\scripts\buildsystems\vcpkg.cmake"
} else {
    Write-Host "Warning: vcpkg not found" -ForegroundColor Yellow
    $vcpkgToolchain = ""
}

# Create build directory
Write-Host ""
Write-Host "Creating build directory..." -ForegroundColor Yellow
$buildDir = "build"
if (Test-Path $buildDir) {
    Write-Host "Cleaning old build..." -ForegroundColor Yellow
    Remove-Item $buildDir -Recurse -Force
}
New-Item -ItemType Directory -Path $buildDir | Out-Null
Write-Host "[OK] Build directory created" -ForegroundColor Green

# Configure project
Write-Host ""
Write-Host "Configuring CMake..." -ForegroundColor Yellow
Set-Location $buildDir

$cmakeArgs = @("..")
if ($vcpkgToolchain) {
    $cmakeArgs += "-DCMAKE_TOOLCHAIN_FILE=$vcpkgToolchain"
}

& cmake @cmakeArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: CMake configuration failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host "[OK] CMake configuration successful" -ForegroundColor Green

# Build project
Write-Host ""
Write-Host "Building project (Release)..." -ForegroundColor Yellow
& cmake --build . --config Release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Build failed!" -ForegroundColor Red
    Set-Location ..
    exit 1
}

Write-Host "[OK] Build successful" -ForegroundColor Green

# Return to project root
Set-Location ..

Write-Host ""
Write-Host "===== Build Complete! =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "Executable: build\bin\Release\VideoEditor.exe" -ForegroundColor Green
Write-Host ""
Write-Host "To run: .\build\bin\Release\VideoEditor.exe" -ForegroundColor Yellow
Write-Host ""
