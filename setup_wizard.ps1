# Video Editor - Setup Wizard
# Choose your preferred build method

Write-Host ""
Write-Host "===== Video Editor Setup Wizard =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "Choose how you want to build the project:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. GitHub Actions (Recommended)" -ForegroundColor Green
Write-Host "   - NO local installation needed" -ForegroundColor White
Write-Host "   - Build in the cloud" -ForegroundColor White
Write-Host "   - Download ready-to-use exe" -ForegroundColor White
Write-Host "   - Requires: GitHub account (free)" -ForegroundColor White
Write-Host ""
Write-Host "2. Docker" -ForegroundColor Cyan
Write-Host "   - Isolated container build" -ForegroundColor White
Write-Host "   - Clean system, can delete after build" -ForegroundColor White
Write-Host "   - Requires: Docker Desktop (~500MB)" -ForegroundColor White
Write-Host ""
Write-Host "3. Full Local Installation" -ForegroundColor Yellow
Write-Host "   - Fastest build time" -ForegroundColor White
Write-Host "   - Complete development environment" -ForegroundColor White
Write-Host "   - Requires: Visual Studio, CMake, vcpkg (~25GB)" -ForegroundColor White
Write-Host ""
Write-Host "4. Check Current Environment" -ForegroundColor Magenta
Write-Host "   - See what's already installed" -ForegroundColor White
Write-Host ""
Write-Host "0. Exit" -ForegroundColor Red
Write-Host ""

$choice = Read-Host "Enter your choice (0-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "===== GitHub Actions Setup =====" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "This is the EASIEST method - NO local installation!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Steps to follow:" -ForegroundColor Yellow
        Write-Host "1. Create a GitHub account at https://github.com" -ForegroundColor White
        Write-Host "2. Create a new repository" -ForegroundColor White
        Write-Host "3. Upload this project to GitHub" -ForegroundColor White
        Write-Host "4. GitHub will automatically build your project" -ForegroundColor White
        Write-Host "5. Download the compiled exe from 'Artifacts'" -ForegroundColor White
        Write-Host ""
        Write-Host "Detailed guide: GITHUB_ACTIONS_GUIDE.md" -ForegroundColor Cyan
        Write-Host ""
        
        $open = Read-Host "Open the guide now? (y/n)"
        if ($open -eq "y") {
            notepad GITHUB_ACTIONS_GUIDE.md
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "===== Docker Setup =====" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Docker provides isolated build environment." -ForegroundColor Green
        Write-Host ""
        Write-Host "Steps:" -ForegroundColor Yellow
        Write-Host "1. Install Docker Desktop from:" -ForegroundColor White
        Write-Host "   https://www.docker.com/products/docker-desktop/" -ForegroundColor White
        Write-Host ""
        Write-Host "2. After installation, run:" -ForegroundColor White
        Write-Host "   docker build -t videoeditor ." -ForegroundColor Cyan
        Write-Host "   docker run --rm -v ${PWD}:/project videoeditor" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "The compiled program will be in the 'release' folder." -ForegroundColor Green
        Write-Host ""
        Write-Host "Dockerfile is already created in this project." -ForegroundColor Cyan
        Write-Host ""
    }
    
    "3" {
        Write-Host ""
        Write-Host "===== Full Local Installation =====" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "This will install all tools on your computer." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Required:" -ForegroundColor Yellow
        Write-Host "- Git" -ForegroundColor White
        Write-Host "- CMake" -ForegroundColor White
        Write-Host "- Visual Studio 2022" -ForegroundColor White
        Write-Host "- vcpkg" -ForegroundColor White
        Write-Host ""
        Write-Host "Space required: ~25GB" -ForegroundColor Red
        Write-Host "Time required: 1-2 hours" -ForegroundColor Red
        Write-Host ""
        
        $confirm = Read-Host "Continue with full installation? (y/n)"
        if ($confirm -eq "y") {
            Write-Host ""
            Write-Host "Opening detailed installation guide..." -ForegroundColor Green
            notepad INSTALL_DEPENDENCIES.md
            
            Write-Host ""
            Write-Host "Quick install commands:" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "# Install Git and CMake" -ForegroundColor White
            Write-Host "winget install Git.Git" -ForegroundColor Cyan
            Write-Host "winget install Kitware.CMake" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "After that, follow the guide for Visual Studio and vcpkg." -ForegroundColor Yellow
            Write-Host ""
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "Checking your environment..." -ForegroundColor Cyan
        Write-Host ""
        & .\check_environment.ps1
    }
    
    "0" {
        Write-Host ""
        Write-Host "Goodbye!" -ForegroundColor Green
        Write-Host ""
        exit
    }
    
    default {
        Write-Host ""
        Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host ""
Write-Host "===== Summary of Available Guides =====" -ForegroundColor Cyan
Write-Host ""
Write-Host "GITHUB_ACTIONS_GUIDE.md" -ForegroundColor Green
Write-Host "  -> Zero installation, cloud-based build (RECOMMENDED)" -ForegroundColor White
Write-Host ""
Write-Host "ALTERNATIVE_SOLUTIONS.md" -ForegroundColor Cyan
Write-Host "  -> Overview of all available methods" -ForegroundColor White
Write-Host ""
Write-Host "INSTALL_DEPENDENCIES.md" -ForegroundColor Yellow
Write-Host "  -> Full local installation guide" -ForegroundColor White
Write-Host ""
Write-Host "QUICK_SETUP.md" -ForegroundColor Magenta
Write-Host "  -> Quick start guide" -ForegroundColor White
Write-Host ""
Write-Host "check_environment.ps1" -ForegroundColor Blue
Write-Host "  -> Check what's installed on your system" -ForegroundColor White
Write-Host ""
