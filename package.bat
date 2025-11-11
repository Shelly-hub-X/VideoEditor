@echo off
REM Video Editor - Package Script

setlocal enabledelayedexpansion

echo.
echo ===== Video Editor Package Script =====
echo.

REM Check executable
if not exist "build\bin\Release\VideoEditor.exe" (
    echo [ERROR] Executable not found!
    echo Please run build.bat first
    pause
    exit /b 1
)

echo [OK] Found executable: build\bin\Release\VideoEditor.exe
echo.

REM Create package directory
echo Creating package directory...
set PACKAGE_DIR=release\VideoEditor
if exist "release" rmdir /s /q "release" >nul 2>&1
mkdir "%PACKAGE_DIR%"
echo [OK] Package directory created: %PACKAGE_DIR%
echo.

REM Copy executable
echo Copying executable...
copy "build\bin\Release\VideoEditor.exe" "%PACKAGE_DIR%\" >nul
echo [OK] VideoEditor.exe copied
echo.

REM Deploy Qt dependencies
echo Deploying Qt dependencies...
echo Running windeployqt...
cd "%PACKAGE_DIR%"
call windeployqt.exe VideoEditor.exe --release
cd ..\..
echo [OK] Qt dependencies deployed
echo.

REM Copy FFmpeg DLL
echo Copying FFmpeg libraries...

REM Find FFmpeg location
if defined VCPKG_ROOT (
    set FFMPEG_DLL_PATH=%VCPKG_ROOT%\installed\x64-windows\bin
) else (
    echo [WARNING] VCPKG_ROOT not set
    echo Enter vcpkg root path (or press Enter to skip):
    set /p VCPKG_ROOT="VCPKG_ROOT: "
    if not "!VCPKG_ROOT!"=="" (
        set FFMPEG_DLL_PATH=!VCPKG_ROOT!\installed\x64-windows\bin
    ) else (
        echo [WARNING] Skipping FFmpeg DLL copy
        goto skip_ffmpeg
    )
)

if exist "!FFMPEG_DLL_PATH!" (
    copy "!FFMPEG_DLL_PATH!\avcodec*.dll" "%PACKAGE_DIR%\" >nul 2>&1
    copy "!FFMPEG_DLL_PATH!\avformat*.dll" "%PACKAGE_DIR%\" >nul 2>&1
    copy "!FFMPEG_DLL_PATH!\avutil*.dll" "%PACKAGE_DIR%\" >nul 2>&1
    copy "!FFMPEG_DLL_PATH!\swscale*.dll" "%PACKAGE_DIR%\" >nul 2>&1
    copy "!FFMPEG_DLL_PATH!\swresample*.dll" "%PACKAGE_DIR%\" >nul 2>&1
    echo [OK] FFmpeg DLL copied
) else (
    echo [ERROR] FFmpeg DLL path not found: !FFMPEG_DLL_PATH!
    echo Make sure VCPKG_ROOT is set correctly
    pause
    exit /b 1
)

:skip_ffmpeg
echo.

REM Copy documentation
echo Copying documentation...
if exist "README.md" copy "README.md" "%PACKAGE_DIR%\" >nul
if exist "QUICK_REFERENCE.md" copy "QUICK_REFERENCE.md" "%PACKAGE_DIR%\" >nul
if exist "LICENSE" copy "LICENSE" "%PACKAGE_DIR%\" >nul
echo [OK] Documentation copied
echo.

REM Show results
echo ===== Packaging Complete! =====
echo.
echo Package location: %PACKAGE_DIR%
echo.
echo Files included:
dir /b "%PACKAGE_DIR%\"
echo.

REM Create ZIP
echo Creating compressed archive...
cd release
if exist "VideoEditor-v1.0.0-Windows-x64.zip" del "VideoEditor-v1.0.0-Windows-x64.zip"
powershell -NoProfile -Command "Compress-Archive -Path 'VideoEditor' -DestinationPath 'VideoEditor-v1.0.0-Windows-x64.zip' -Force"
if exist "VideoEditor-v1.0.0-Windows-x64.zip" (
    echo [OK] Archive created: VideoEditor-v1.0.0-Windows-x64.zip
) else (
    echo [WARNING] Archive creation may have failed
)
cd ..
echo.

REM Summary
echo ===== Summary =====
echo [OK] Program packaged successfully!
echo.
echo Output folder: release\VideoEditor\
echo Archive: release\VideoEditor-v1.0.0-Windows-x64.zip
echo.
echo How to run:
echo   1. Open release\VideoEditor\ folder
echo   2. Double-click VideoEditor.exe
echo.
echo Notes:
echo - All Qt and FFmpeg dependencies included
echo - Can be copied to other computers
echo - No external software needed
echo.
pause
