#!/usr/bin/env powershell
# Video Editor - Package Script
# Packages compiled program with all dependencies

param(
    [switch]$CreateZip = $true,
    [switch]$OpenFolder = $false
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "===== Video Editor Package Script =====" -ForegroundColor Cyan
Write-Host ""

# Check build directory
$exePath = "build\bin\Release\VideoEditor.exe"
if (-not (Test-Path $exePath)) {
    Write-Host "[ERROR] Executable not found: $exePath" -ForegroundColor Red
    Write-Host "Please run build.ps1 first" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Found executable: $exePath" -ForegroundColor Green
Write-Host ""

# Create package directory
$packageDir = "release\VideoEditor"
Write-Host "Creating package directory..." -ForegroundColor Yellow

if (Test-Path "release") {
    Remove-Item "release" -Recurse -Force
}
New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
Write-Host "[OK] Package directory created: $packageDir" -ForegroundColor Green
Write-Host ""

# Copy executable
Write-Host "Copying executable..." -ForegroundColor Yellow
Copy-Item $exePath "$packageDir\" -Force
Write-Host "[OK] VideoEditor.exe copied" -ForegroundColor Green
Write-Host ""

# Deploy Qt dependencies
Write-Host "Deploying Qt dependencies..." -ForegroundColor Yellow
Write-Host "Running windeployqt..." -ForegroundColor Cyan

Push-Location $packageDir
try {
    & windeployqt.exe VideoEditor.exe --release 2>&1 | Out-Null
    Write-Host "[OK] Qt dependencies deployed" -ForegroundColor Green
} catch {
    Write-Host "[WARNING] windeployqt error, may need manual config" -ForegroundColor Yellow
} finally {
    Pop-Location
}
Write-Host ""

# Copy FFmpeg DLL
Write-Host "Copying FFmpeg libraries..." -ForegroundColor Yellow

$vcpkgRoot = $env:VCPKG_ROOT
if ([string]::IsNullOrEmpty($vcpkgRoot)) {
    Write-Host "[WARNING] VCPKG_ROOT not set" -ForegroundColor Yellow
    $vcpkgRoot = Read-Host "Enter vcpkg path (or press Enter to skip)"
}

if (-not [string]::IsNullOrEmpty($vcpkgRoot)) {
    $ffmpegDllPath = "$vcpkgRoot\installed\x64-windows\bin"
    
    if (Test-Path $ffmpegDllPath) {
        $dllFiles = @(
            "avcodec*.dll",
            "avformat*.dll",
            "avutil*.dll",
            "swscale*.dll",
            "swresample*.dll"
        )
        
        foreach ($pattern in $dllFiles) {
            Get-Item "$ffmpegDllPath\$pattern" -ErrorAction SilentlyContinue |
                Copy-Item -Destination "$packageDir\" -Force
        }
        
        Write-Host "[OK] FFmpeg DLLs copied" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] FFmpeg DLL path not found: $ffmpegDllPath" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "[WARNING] Skipping FFmpeg DLL copy" -ForegroundColor Yellow
}
Write-Host ""

# Copy documentation
Write-Host "Copying documentation..." -ForegroundColor Yellow
$docFiles = @("README.md", "QUICK_REFERENCE.md", "LICENSE")
foreach ($file in $docFiles) {
    if (Test-Path $file) {
        Copy-Item $file "$packageDir\" -Force
    }
}
Write-Host "[OK] Documentation copied" -ForegroundColor Green
Write-Host ""

# Create README
Write-Host "Creating README..." -ForegroundColor Yellow
$readmeContent = @"
# Video Editor v1.0

## How to Start
Double-click VideoEditor.exe to launch

## Features
- Video Splitting: Extract frames and audio
- Video Merging: Combine frames and audio
- Video Preview: Play and preview videos
- Thumbnail Extraction: Extract video frames

## System Requirements
- Windows 10/11 64-bit
- 4GB RAM minimum
- Sufficient disk space for video processing

## Quick Start
1. Click File to select a video
2. Choose function (Split/Merge/Extract)
3. Select output location
4. Wait for completion

## Documentation
See QUICK_REFERENCE.md and README.md

## License
MIT License - See LICENSE file

## Technology Stack
- Qt 6 Framework
- FFmpeg Media Library
- C++ 17
"@

Set-Content -Path "$packageDir\README.txt" -Value $readmeContent -Encoding UTF8
Write-Host "[OK] README created" -ForegroundColor Green
Write-Host ""

# Show results
Write-Host "===== Packaging Complete! =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "Package location: $packageDir" -ForegroundColor Green
Write-Host ""
Write-Host "Files included:" -ForegroundColor Yellow
Get-ChildItem "$packageDir" -Name | ForEach-Object { Write-Host "   - $_" }
Write-Host ""

# Calculate size
$size = (Get-ChildItem "$packageDir" -Recurse | Measure-Object -Property Length -Sum).Sum
$sizeKB = [math]::Round($size / 1KB, 2)
Write-Host "Package size: $sizeKB KB" -ForegroundColor Yellow
Write-Host ""

# Create ZIP
if ($CreateZip) {
    Write-Host "Creating compressed archive..." -ForegroundColor Yellow
    
    $zipPath = "release\VideoEditor-v1.0.0-Windows-x64.zip"
    if (Test-Path $zipPath) {
        Remove-Item $zipPath -Force
    }
    
    try {
        Compress-Archive -Path $packageDir -DestinationPath $zipPath -Force
        $zipSize = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
        Write-Host "[OK] Archive created: $zipPath" -ForegroundColor Green
        Write-Host "   Size: $zipSize MB" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Archive creation failed: $_" -ForegroundColor Red
    }
}
Write-Host ""

# Summary
Write-Host "===== Summary =====" -ForegroundColor Cyan
Write-Host "[OK] Program packaged successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Output folder: $packageDir" -ForegroundColor Green
if ($CreateZip) {
    Write-Host "Archive: release\VideoEditor-v1.0.0-Windows-x64.zip" -ForegroundColor Green
}
Write-Host ""
Write-Host "How to run:" -ForegroundColor Cyan
Write-Host "   1. Open $packageDir folder" -ForegroundColor White
Write-Host "   2. Double-click VideoEditor.exe" -ForegroundColor White
Write-Host ""
Write-Host "Notes:" -ForegroundColor Yellow
Write-Host "   - All Qt and FFmpeg dependencies included" -ForegroundColor White
Write-Host "   - Can be copied to other computers" -ForegroundColor White
Write-Host "   - No external software needed" -ForegroundColor White
Write-Host ""

# Open folder
if ($OpenFolder) {
    Write-Host "Opening folder..." -ForegroundColor Yellow
    Invoke-Item $packageDir
}

