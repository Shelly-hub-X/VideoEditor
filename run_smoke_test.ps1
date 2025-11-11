# ========================================
# VideoEditor Smoke Test Script
# ========================================
# 快速验证代码结构和配置,无需完整编译

param(
    [switch]$Verbose
)

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      🧪 VideoEditor 烟雾测试              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$testsPassed = 0
$testsFailed = 0

function Test-Item {
    param(
        [string]$Name,
        [scriptblock]$Test,
        [string]$ErrorMessage = "测试失败"
    )
    
    Write-Host "Testing: $Name" -NoNewline -ForegroundColor Yellow
    
    try {
        $result = & $Test
        if ($result) {
            Write-Host " ✅ PASS" -ForegroundColor Green
            $script:testsPassed++
            return $true
        } else {
            Write-Host " ❌ FAIL" -ForegroundColor Red
            Write-Host "  → $ErrorMessage" -ForegroundColor Gray
            $script:testsFailed++
            return $false
        }
    } catch {
        Write-Host " ❌ ERROR" -ForegroundColor Red
        Write-Host "  → $($_.Exception.Message)" -ForegroundColor Gray
        $script:testsFailed++
        return $false
    }
}

# Test 1: 项目结构
Write-Host ""
Write-Host "📁 检查项目结构..." -ForegroundColor Cyan
Write-Host ""

Test-Item "CMakeLists.txt 存在" {
    Test-Path "CMakeLists.txt"
}

Test-Item "vcpkg.json 存在" {
    Test-Path "vcpkg.json"
}

Test-Item "源代码目录存在" {
    Test-Path "src"
}

Test-Item "头文件目录存在" {
    Test-Path "include"
}

Test-Item "GitHub Actions 配置存在" {
    Test-Path ".github/workflows/build.yml"
}

# Test 2: 文件语法检查
Write-Host ""
Write-Host "📝 检查配置文件语法..." -ForegroundColor Cyan
Write-Host ""

Test-Item "vcpkg.json JSON 格式正确" {
    try {
        $null = Get-Content "vcpkg.json" -Raw | ConvertFrom-Json
        $true
    } catch {
        $false
    }
}

Test-Item "CMakeLists.txt 包含 project 声明" {
    $content = Get-Content "CMakeLists.txt" -Raw
    $content -match "project\s*\("
}

Test-Item "CMakeLists.txt 包含 Qt 依赖" {
    $content = Get-Content "CMakeLists.txt" -Raw
    $content -match "Qt6|Qt::|find_package.*Qt"
}

# Test 3: 源代码文件检查
Write-Host ""
Write-Host "🔍 检查源代码文件..." -ForegroundColor Cyan
Write-Host ""

Test-Item "main.cpp 存在" {
    Test-Path "src/main.cpp"
}

Test-Item "MainWindow.h 存在" {
    Test-Path "include/MainWindow.h"
}

Test-Item "MainWindow.cpp 存在" {
    Test-Path "src/MainWindow.cpp"
}

# Test 4: 头文件引用检查
Write-Host ""
Write-Host "📦 检查依赖引用..." -ForegroundColor Cyan
Write-Host ""

Test-Item "main.cpp 包含 QApplication" {
    $content = Get-Content "src/main.cpp" -Raw
    $content -match "#include.*QApplication"
}

Test-Item "MainWindow.h 包含 QMainWindow" {
    $content = Get-Content "include/MainWindow.h" -Raw
    $content -match "#include.*QMainWindow"
}

# Test 5: vcpkg 依赖检查
Write-Host ""
Write-Host "📚 检查 vcpkg 依赖配置..." -ForegroundColor Cyan
Write-Host ""

Test-Item "vcpkg.json 包含 qtbase" {
    $vcpkgJson = Get-Content "vcpkg.json" -Raw | ConvertFrom-Json
    $vcpkgJson.dependencies -contains "qtbase"
}

Test-Item "vcpkg.json 包含 qtmultimedia" {
    $vcpkgJson = Get-Content "vcpkg.json" -Raw | ConvertFrom-Json
    $deps = $vcpkgJson.dependencies
    ($deps -contains "qtmultimedia") -or ($deps | Where-Object { $_.name -eq "qtmultimedia" })
}

Test-Item "vcpkg.json 包含 baseline" {
    $vcpkgJson = Get-Content "vcpkg.json" -Raw | ConvertFrom-Json
    $vcpkgJson.'builtin-baseline' -ne $null
}

# Test 6: Git 配置检查
Write-Host ""
Write-Host "🔧 检查 Git 配置..." -ForegroundColor Cyan
Write-Host ""

Test-Item "Git 仓库已初始化" {
    Test-Path ".git"
}

Test-Item "Git remote 已配置" {
    $remote = git remote 2>$null
    $remote -contains "origin"
}

Test-Item ".gitignore 存在" {
    Test-Path ".gitignore"
}

# Test 7: 构建脚本检查
Write-Host ""
Write-Host "🛠️  检查构建脚本..." -ForegroundColor Cyan
Write-Host ""

Test-Item "build.ps1 存在" {
    Test-Path "build.ps1"
}

Test-Item "package.ps1 存在" {
    Test-Path "package.ps1"
}

Test-Item "build_and_package.ps1 存在" {
    Test-Path "build_and_package.ps1"
}

# Test 8: 代码基本语法检查
Write-Host ""
Write-Host "🔎 检查代码基本语法..." -ForegroundColor Cyan
Write-Host ""

Test-Item "main.cpp 包含 main 函数" {
    $content = Get-Content "src/main.cpp" -Raw
    $content -match "int\s+main\s*\("
}

Test-Item "main.cpp 返回 app.exec()" {
    $content = Get-Content "src/main.cpp" -Raw
    $content -match "return\s+app\.exec\(\)"
}

Test-Item "没有明显的语法错误 (括号匹配)" {
    $srcFiles = Get-ChildItem -Path "src" -Filter "*.cpp" -Recurse
    $allMatch = $true
    
    foreach ($file in $srcFiles) {
        $content = Get-Content $file.FullName -Raw
        $openBraces = ($content.ToCharArray() | Where-Object { $_ -eq '{' }).Count
        $closeBraces = ($content.ToCharArray() | Where-Object { $_ -eq '}' }).Count
        
        if ($openBraces -ne $closeBraces) {
            if ($Verbose) {
                Write-Host "  ⚠️  $($file.Name): 括号不匹配 ({$openBraces vs }$closeBraces)" -ForegroundColor Yellow
            }
            $allMatch = $false
        }
    }
    
    $allMatch
}

# 总结
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              测试结果摘要                    ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "通过: " -NoNewline -ForegroundColor Green
Write-Host "$testsPassed" -ForegroundColor White

Write-Host "失败: " -NoNewline -ForegroundColor Red
Write-Host "$testsFailed" -ForegroundColor White

$total = $testsPassed + $testsFailed
$passRate = [math]::Round(($testsPassed / $total) * 100, 1)

Write-Host "通过率: " -NoNewline -ForegroundColor Yellow
Write-Host "$passRate%" -ForegroundColor White

Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "✅ 所有烟雾测试通过!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📊 下一步建议:" -ForegroundColor Cyan
    Write-Host "  1. 推送到 GitHub 进行完整编译测试" -ForegroundColor White
    Write-Host "  2. 等待 GitHub Actions 构建完成 (~10 分钟)" -ForegroundColor White
    Write-Host "  3. 下载并测试编译好的 exe" -ForegroundColor White
    Write-Host ""
    exit 0
} else {
    Write-Host "❌ 有 $testsFailed 个测试失败" -ForegroundColor Red
    Write-Host ""
    Write-Host "⚠️  建议修复上述问题后再进行构建" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
