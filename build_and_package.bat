@echo off
REM Video Editor - Build and Package Script

setlocal enabledelayedexpansion

echo.
echo ===== Video Editor Build and Package =====
echo.

REM Check if build.bat and package.bat exist
if not exist "build.bat" (
    echo [ERROR] build.bat not found
    pause
    exit /b 1
)

if not exist "package.bat" (
    echo [ERROR] package.bat not found
    pause
    exit /b 1
)

REM Step 1: Build project
echo [1/2] Building project...
echo.
call build.bat

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo [OK] Build complete!
echo.

REM Step 2: Package program
echo [2/2] Packaging program...
echo.
call package.bat

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Packaging failed!
    pause
    exit /b 1
)
echo.
echo ===== All Complete! =====
echo.
echo [OK] Program built and packaged successfully!
echo.
echo Output: release\VideoEditor\
echo.
pause
endlocal
exit /b 0
echo 📦 位置: release\VideoEditor\
echo.
echo 🚀 快速开始:
echo    打开 release\VideoEditor 文件夹，双击 VideoEditor.exe 运行
echo.
pause
