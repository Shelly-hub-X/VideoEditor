# 视频剪辑助手 - 运行脚本

Write-Host "===== 启动视频剪辑助手 =====" -ForegroundColor Cyan
Write-Host ""

$exePath = "build\bin\Release\VideoEditor.exe"

if (-not (Test-Path $exePath)) {
    Write-Host "错误: 未找到可执行文件！" -ForegroundColor Red
    Write-Host "请先运行 build.ps1 编译项目" -ForegroundColor Yellow
    exit 1
}

Write-Host "启动程序..." -ForegroundColor Green
& $exePath
