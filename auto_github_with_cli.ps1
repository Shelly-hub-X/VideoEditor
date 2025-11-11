# ========================================
# Fully Automated GitHub Upload (with gh CLI)
# ========================================
# Requires: GitHub CLI (gh)
# Install: winget install GitHub.cli

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fully Automated GitHub Upload" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check for gh CLI
Write-Host "Checking GitHub CLI..." -ForegroundColor Yellow
$ghInstalled = Get-Command gh -ErrorAction SilentlyContinue

if (-not $ghInstalled) {
    Write-Host "❌ GitHub CLI not found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Installing GitHub CLI..." -ForegroundColor Yellow
    
    $installChoice = Read-Host "Install GitHub CLI now? (y/n)"
    
    if ($installChoice -eq 'y' -or $installChoice -eq 'Y') {
        Write-Host "Installing via winget..." -ForegroundColor Green
        winget install GitHub.cli
        
        Write-Host ""
        Write-Host "✅ GitHub CLI installed!" -ForegroundColor Green
        Write-Host "Please restart this script." -ForegroundColor Yellow
        exit
    } else {
        Write-Host ""
        Write-Host "Use manual upload script instead:" -ForegroundColor Yellow
        Write-Host "  .\quick_push_github.ps1 YourUsername" -ForegroundColor Cyan
        exit
    }
}

Write-Host "✅ GitHub CLI found" -ForegroundColor Green

# Check authentication
Write-Host ""
Write-Host "Checking GitHub authentication..." -ForegroundColor Yellow
$authStatus = gh auth status 2>&1

if ($authStatus -match "not logged") {
    Write-Host "Please login to GitHub..." -ForegroundColor Yellow
    gh auth login
} else {
    Write-Host "✅ Already logged in" -ForegroundColor Green
}

# Initialize Git if needed
if (-not (Test-Path ".git")) {
    Write-Host ""
    Write-Host "Initializing Git repository..." -ForegroundColor Yellow
    git init
    git config user.name "VideoEditor"
    git config user.email "noreply@github.com"
}

# Create .gitignore
if (-not (Test-Path ".gitignore")) {
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

# Stage files
Write-Host ""
Write-Host "Staging files..." -ForegroundColor Yellow
git add .
git add .github/workflows/build.yml -f

# Commit
Write-Host "Creating commit..." -ForegroundColor Yellow
git commit -m "Add GitHub Actions automated build" -m "Build Qt project with vcpkg on Ubuntu"

# Create repository and push
Write-Host ""
Write-Host "Creating GitHub repository and pushing..." -ForegroundColor Yellow
Write-Host ""

gh repo create VideoEditor --public --source=. --remote=origin --push

if ($?) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅✅✅ SUCCESS! ✅✅✅" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 Repository created and code pushed!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📊 GitHub Actions is now building your exe..." -ForegroundColor Yellow
    Write-Host ""
    
    # Get username
    $username = gh api user --jq .login
    
    Write-Host "Repository: https://github.com/$username/VideoEditor" -ForegroundColor White
    Write-Host "Actions:    https://github.com/$username/VideoEditor/actions" -ForegroundColor White
    Write-Host ""
    Write-Host "⏱️  Build time: ~10-15 minutes" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "After build completes:" -ForegroundColor Yellow
    Write-Host "  1. Go to Actions tab" -ForegroundColor White
    Write-Host "  2. Click the workflow run" -ForegroundColor White
    Write-Host "  3. Download 'video-editor-windows' artifact" -ForegroundColor White
    Write-Host ""
    
    # Offer to open browser
    $openNow = Read-Host "Open GitHub Actions in browser? (y/n)"
    if ($openNow -eq 'y' -or $openNow -eq 'Y') {
        gh repo view --web
        Start-Sleep -Seconds 2
        Start-Process "https://github.com/$username/VideoEditor/actions"
    }
    
    Write-Host ""
    Write-Host "🎯 You can also watch build progress in terminal:" -ForegroundColor Cyan
    Write-Host "   gh run watch" -ForegroundColor Green
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "❌ Failed to create repository" -ForegroundColor Red
    Write-Host ""
    Write-Host "Try manual method:" -ForegroundColor Yellow
    Write-Host "  .\quick_push_github.ps1 YourUsername" -ForegroundColor Cyan
}
