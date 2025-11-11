@echo off
REM Video Editor Build Script

setlocal enabledelayedexpansion

echo.
echo ===== Video Editor Build =====
echo.

REM Check CMake
echo Checking CMake...
where cmake >nul 2>&1
if errorlevel 1 (
    echo [ERROR] CMake not found! Please install CMake.
    exit /b 1
)
echo [OK] CMake found
echo.

REM Create build directory
echo Creating build directory...
if exist build (
    echo Removing old build...
    rmdir /s /q build
)
mkdir build
echo [OK] Build directory created
echo.

REM Configure project
echo Configuring CMake...
cd build
cmake ..
if errorlevel 1 (
    echo [ERROR] CMake configuration failed!
    cd ..
    exit /b 1
)
echo [OK] CMake configuration successful
echo.

REM Build project
echo Building project (Release)...
cmake --build . --config Release
if errorlevel 1 (
    echo [ERROR] Build failed!
    cd ..
    exit /b 1
)
echo [OK] Build successful
echo.

cd ..

echo.
echo ===== Build Complete! =====
echo.
echo Executable: build\bin\Release\VideoEditor.exe
echo.
echo To run: .\build\bin\Release\VideoEditor.exe
echo.

endlocal
exit /b 0
