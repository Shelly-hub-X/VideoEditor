# ========================================
# Quick Push to GitHub (One Command)
# ========================================
# Usage: .\quick_push_github.ps1 YourGitHubUsername

param(
    [Parameter(Mandatory=$false)]
    [string]$Username
)

if ([string]::IsNullOrEmpty($Username)) {
    Write-Host "Usage: .\quick_push_github.ps1 YourGitHubUsername" -ForegroundColor Yellow
    Write-Host ""
    $Username = Read-Host "Enter your GitHub username"
}

$RepoName = "VideoEditor"
$RepoUrl = "https://github.com/$Username/$RepoName.git"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Quick Push to GitHub" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Repository: $RepoUrl" -ForegroundColor Green
Write-Host ""

# Initialize if needed
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git..." -ForegroundColor Yellow
    git init
    git config user.name "VideoEditor"
    git config user.email "$Username@users.noreply.github.com"
}

# Create .gitignore
if (-not (Test-Path ".gitignore")) {
    Write-Host "Creating .gitignore..." -ForegroundColor Yellow
    @"
build/
release/
vcpkg_installed/
*.exe
*.dll
*.pdb
.vs/
.vscode/
*.user
*.log
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
}

# Stage and commit
Write-Host "Staging files..." -ForegroundColor Yellow
git add .
git add .github/workflows/build.yml -f

Write-Host "Committing..." -ForegroundColor Yellow
git commit -m "Add project with GitHub Actions workflow" -m "Automated build using Qt 6.9.1 and vcpkg"

# Set remote
$remoteExists = git remote | Select-String -Pattern "^origin$"
if ($remoteExists) {
    git remote set-url origin $RepoUrl
} else {
    git remote add origin $RepoUrl
}

# Push
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Green
Write-Host ""

git branch -M main
git push -u origin main

if ($?) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "GitHub Actions will now build your project!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📊 View build progress:" -ForegroundColor Yellow
    Write-Host "   https://github.com/$Username/$RepoName/actions" -ForegroundColor White
    Write-Host ""
    Write-Host "📦 Download exe (after build completes ~10 min):" -ForegroundColor Yellow
    Write-Host "   1. Go to Actions tab" -ForegroundColor White
    Write-Host "   2. Click the latest workflow run" -ForegroundColor White
    Write-Host "   3. Scroll to 'Artifacts' section" -ForegroundColor White
    Write-Host "   4. Download 'video-editor-windows'" -ForegroundColor White
    Write-Host ""
    
    # Try to open in browser
    $openBrowser = Read-Host "Open GitHub Actions in browser? (y/n)"
    if ($openBrowser -eq 'y' -or $openBrowser -eq 'Y') {
        Start-Process "https://github.com/$Username/$RepoName/actions"
    }
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  ❌ PUSH FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible reasons:" -ForegroundColor Yellow
    Write-Host "  1. Repository doesn't exist yet" -ForegroundColor White
    Write-Host "     → Create it at: https://github.com/new" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Authentication failed" -ForegroundColor White
    Write-Host "     → Configure credentials:" -ForegroundColor Cyan
    Write-Host "       git config --global credential.helper wincred" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  3. No push permission" -ForegroundColor White
    Write-Host "     → Make sure you own the repository" -ForegroundColor Cyan
    Write-Host ""
}
