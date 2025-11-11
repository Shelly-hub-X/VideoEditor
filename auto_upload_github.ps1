# ========================================
# Auto Upload to GitHub and Trigger Actions
# ========================================

param(
    [string]$RepoName = "VideoEditor",
    [string]$GitHubUsername = "",
    [switch]$CreateNew = $false
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Auto Upload to GitHub Actions" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check prerequisites
Write-Host "[1/6] Checking prerequisites..." -ForegroundColor Yellow

if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..." -ForegroundColor Green
    git init
    git config user.name "VideoEditor User"
    git config user.email "user@videoeditor.local"
}

# Create .gitignore if not exists
if (-not (Test-Path ".gitignore")) {
    Write-Host "Creating .gitignore..." -ForegroundColor Green
    @"
# Build directories
build/
release/
vcpkg_installed/
*.exe
*.dll
*.pdb

# IDE
.vs/
.vscode/
*.user

# Temp files
*.log
*.tmp
*.cache
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8
}

# Stage all files
Write-Host ""
Write-Host "[2/6] Staging files..." -ForegroundColor Yellow
git add .
git add .github/workflows/build.yml -f

# Commit
Write-Host ""
Write-Host "[3/6] Creating commit..." -ForegroundColor Yellow
$commitMsg = "Add GitHub Actions workflow for automated build ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
git commit -m $commitMsg

# Get GitHub username
Write-Host ""
Write-Host "[4/6] GitHub Repository Configuration" -ForegroundColor Yellow

if ([string]::IsNullOrEmpty($GitHubUsername)) {
    $GitHubUsername = Read-Host "Enter your GitHub username"
}

$RepoUrl = "https://github.com/$GitHubUsername/$RepoName.git"

Write-Host ""
Write-Host "Repository URL: $RepoUrl" -ForegroundColor Cyan

# Check if remote exists
$remoteExists = git remote | Select-String -Pattern "^origin$"

if ($remoteExists) {
    Write-Host "Updating remote origin..." -ForegroundColor Green
    git remote set-url origin $RepoUrl
} else {
    Write-Host "Adding remote origin..." -ForegroundColor Green
    git remote add origin $RepoUrl
}

# Instructions
Write-Host ""
Write-Host "[5/6] Next Steps:" -ForegroundColor Yellow
Write-Host ""

if ($CreateNew) {
    Write-Host "Option A: Create repository via GitHub CLI (recommended)" -ForegroundColor Cyan
    Write-Host "  1. Install GitHub CLI: winget install GitHub.cli" -ForegroundColor White
    Write-Host "  2. Login: gh auth login" -ForegroundColor White
    Write-Host "  3. Create repo: gh repo create $RepoName --public --source=. --remote=origin --push" -ForegroundColor White
    Write-Host ""
}

Write-Host "Option B: Create repository manually on GitHub.com" -ForegroundColor Cyan
Write-Host "  1. Go to: https://github.com/new" -ForegroundColor White
Write-Host "  2. Repository name: $RepoName" -ForegroundColor White
Write-Host "  3. Visibility: Public (required for free Actions)" -ForegroundColor White
Write-Host "  4. DON'T initialize with README/license/gitignore" -ForegroundColor White
Write-Host "  5. Click 'Create repository'" -ForegroundColor White
Write-Host ""

Write-Host "[6/6] Push to GitHub:" -ForegroundColor Yellow
Write-Host ""
Write-Host "After creating the repository on GitHub, run:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  git branch -M main" -ForegroundColor Green
Write-Host "  git push -u origin main" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GitHub Actions will automatically:" -ForegroundColor Cyan
Write-Host "  - Install Qt 6.9.1 on Ubuntu" -ForegroundColor White
Write-Host "  - Build your project" -ForegroundColor White
Write-Host "  - Package as exe" -ForegroundColor White
Write-Host "  - Upload as artifact" -ForegroundColor White
Write-Host ""
Write-Host "  Check progress at:" -ForegroundColor Cyan
Write-Host "  https://github.com/$GitHubUsername/$RepoName/actions" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Offer to push now
Write-Host "Ready to push? (Repository must be created first)" -ForegroundColor Yellow
$pushNow = Read-Host "Push to GitHub now? (y/n)"

if ($pushNow -eq 'y' -or $pushNow -eq 'Y') {
    Write-Host ""
    Write-Host "Pushing to GitHub..." -ForegroundColor Green
    git branch -M main
    git push -u origin main
    
    if ($?) {
        Write-Host ""
        Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
        Write-Host ""
        Write-Host "View GitHub Actions at:" -ForegroundColor Cyan
        Write-Host "https://github.com/$GitHubUsername/$RepoName/actions" -ForegroundColor Green
        Write-Host ""
        Write-Host "Download built exe from:" -ForegroundColor Cyan
        Write-Host "https://github.com/$GitHubUsername/$RepoName/actions (click latest run -> Artifacts)" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "❌ Push failed. Make sure:" -ForegroundColor Red
        Write-Host "  1. Repository exists on GitHub" -ForegroundColor White
        Write-Host "  2. You have push permissions" -ForegroundColor White
        Write-Host "  3. You're logged in (run: git config --global credential.helper wincred)" -ForegroundColor White
    }
} else {
    Write-Host ""
    Write-Host "When ready to push, run:" -ForegroundColor Cyan
    Write-Host "  git branch -M main" -ForegroundColor Green
    Write-Host "  git push -u origin main" -ForegroundColor Green
}

Write-Host ""
