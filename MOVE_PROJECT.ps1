# Move Project to English Path
# This script will move the project to a path without Chinese characters

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "CRITICAL: Project Path Contains Chinese Characters" -ForegroundColor Red
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "The current project path contains Chinese characters that are causing" -ForegroundColor Yellow
Write-Host "Qt compilation to fail. This is because vcpkg's build system cannot" -ForegroundColor Yellow
Write-Host "handle non-ASCII characters in paths properly." -ForegroundColor Yellow
Write-Host ""
Write-Host "Current path: C:\Users\Administrator\Desktop\视频剪辑助手" -ForegroundColor Yellow
Write-Host "The Chinese characters are being corrupted during Qt compilation." -ForegroundColor Yellow
Write-Host ""
Write-Host "SOLUTION: Move the project to a path with only English characters." -ForegroundColor Green
Write-Host ""

# Suggest target paths
$targetPaths = @(
    "C:\VideoEditor",
    "D:\VideoEditor",
    "C:\Projects\VideoEditor"
)

Write-Host "Suggested target paths:" -ForegroundColor Cyan
for ($i = 0; $i -lt $targetPaths.Length; $i++) {
    Write-Host "  [$($i + 1)] $($targetPaths[$i])" -ForegroundColor White
}
Write-Host "  [4] Custom path (enter manually)" -ForegroundColor White
Write-Host ""

# Get user choice
$choice = Read-Host "Select target path (1-4)"

$targetPath = ""
switch ($choice) {
    "1" { $targetPath = $targetPaths[0] }
    "2" { $targetPath = $targetPaths[1] }
    "3" { $targetPath = $targetPaths[2] }
    "4" {
        $targetPath = Read-Host "Enter custom path (English characters only)"
    }
    default {
        Write-Host "Invalid choice. Using default: $($targetPaths[0])" -ForegroundColor Yellow
        $targetPath = $targetPaths[0]
    }
}

# Validate target path
if ($targetPath -match '[^\x00-\x7F]') {
    Write-Host "ERROR: Target path contains non-ASCII characters!" -ForegroundColor Red
    Write-Host "Please use only English letters, numbers, and basic symbols." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Target path: $targetPath" -ForegroundColor Green
Write-Host ""

# Check if target exists
if (Test-Path $targetPath) {
    Write-Host "WARNING: Target path already exists!" -ForegroundColor Red
    $overwrite = Read-Host "Do you want to overwrite it? (y/n)"
    if ($overwrite -ne "y") {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
    Write-Host "Removing existing directory..." -ForegroundColor Yellow
    Remove-Item -Path $targetPath -Recurse -Force
}

# Create parent directory if needed
$parentPath = Split-Path -Parent $targetPath
if (-not (Test-Path $parentPath)) {
    Write-Host "Creating parent directory: $parentPath" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $parentPath -Force | Out-Null
}

# Copy project (excluding vcpkg_installed folder which will be rebuilt)
Write-Host ""
Write-Host "Copying project files..." -ForegroundColor Cyan
Write-Host "This will take a few minutes..." -ForegroundColor Yellow
Write-Host ""

$sourcePath = "C:\Users\Administrator\Desktop\视频剪辑助手"

try {
    # Create target directory
    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
    
    # Get all items except vcpkg_installed
    $items = Get-ChildItem -Path $sourcePath | Where-Object { $_.Name -ne "vcpkg_installed" }
    
    $totalItems = $items.Count
    $current = 0
    
    foreach ($item in $items) {
        $current++
        $percentComplete = [int](($current / $totalItems) * 100)
        Write-Progress -Activity "Copying files" -Status "$current of $totalItems" -PercentComplete $percentComplete
        
        $targetItem = Join-Path $targetPath $item.Name
        if ($item.PSIsContainer) {
            Copy-Item -Path $item.FullName -Destination $targetItem -Recurse -Force
        } else {
            Copy-Item -Path $item.FullName -Destination $targetItem -Force
        }
    }
    
    Write-Progress -Activity "Copying files" -Completed
    Write-Host "Files copied successfully!" -ForegroundColor Green
    
} catch {
    Write-Host "ERROR copying files: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "PROJECT MOVED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "New project location: $targetPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Close this VS Code window" -ForegroundColor White
Write-Host "2. Open the new project location: $targetPath" -ForegroundColor White
Write-Host "3. Run the following command to install Qt:" -ForegroundColor White
Write-Host ""
Write-Host "   cd $targetPath" -ForegroundColor Cyan
Write-Host "   D:\videoeditor-env\vcpkg\vcpkg.exe install" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. After Qt installation completes, build the project:" -ForegroundColor White
Write-Host ""
Write-Host "   .\build_and_package.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE: vcpkg_installed folder was NOT copied (it will be rebuilt)." -ForegroundColor Yellow
Write-Host "This is normal - Qt will be recompiled in the new location." -ForegroundColor Yellow
Write-Host ""

# Ask if user wants to open the new location
$openNew = Read-Host "Do you want to open the new location in File Explorer? (y/n)"
if ($openNew -eq "y") {
    explorer $targetPath
}
