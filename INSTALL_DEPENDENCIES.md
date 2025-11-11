# 视频剪辑助手 - 依赖安装指南

## 问题说明

脚本运行正常，但编译失败是因为 **缺少必要的开发工具**。

错误信息：
```
[ERROR] CMake not found! Please install CMake.
[ERROR] Build failed
```

---

## 必需的开发工具

要成功编译项目，您需要安装以下工具：

### 1. CMake (构建系统)

**用途**: 配置和生成项目文件

**安装方法**:

#### 方法 A: 使用 winget (推荐)
```powershell
winget install Kitware.CMake
```

#### 方法 B: 使用 Chocolatey
```powershell
choco install cmake
```

#### 方法 C: 手动安装
1. 访问 https://cmake.org/download/
2. 下载 "Windows x64 Installer"
3. 运行安装程序
4. **重要**: 安装时勾选 "Add CMake to system PATH"

#### 验证安装
```powershell
cmake --version
```
应该显示类似: `cmake version 3.27.x`

---

### 2. Visual Studio 2022 (C++ 编译器)

**用途**: 编译 C++ 代码

**安装方法**:

1. 下载 Visual Studio 2022 Community (免费)
   - 下载链接: https://visualstudio.microsoft.com/downloads/

2. 运行安装程序

3. 在"工作负载"选项卡中选择:
   - ✅ **使用 C++ 的桌面开发**

4. 在"单个组件"选项卡中确保包含:
   - ✅ MSVC v143 - VS 2022 C++ x64/x86 生成工具
   - ✅ Windows 10/11 SDK
   - ✅ CMake 工具

5. 点击安装 (需要约 10GB 空间)

#### 验证安装
```powershell
# 检查编译器
cl.exe
```

---

### 3. vcpkg (包管理器)

**用途**: 安装 FFmpeg 和 Qt 依赖库

**安装方法**:

#### 步骤 1: 克隆 vcpkg
```powershell
cd C:\
git clone https://github.com/microsoft/vcpkg
```

#### 步骤 2: 运行安装脚本
```powershell
cd C:\vcpkg
.\bootstrap-vcpkg.bat
```

#### 步骤 3: 设置环境变量
```powershell
# 临时设置 (当前会话)
$env:VCPKG_ROOT = "C:\vcpkg"

# 永久设置 (推荐)
[System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", "C:\vcpkg", "User")
```

#### 步骤 4: 安装项目依赖
```powershell
cd C:\vcpkg

# 安装 FFmpeg (视频处理库)
.\vcpkg install ffmpeg:x64-windows

# 安装 Qt 6 (GUI 框架)
.\vcpkg install qt6-base:x64-windows
.\vcpkg install qt6-multimedia:x64-windows
```

**注意**: vcpkg 安装过程可能需要 30-60 分钟，请耐心等待。

#### 验证安装
```powershell
.\vcpkg list
```
应该显示已安装的包列表。

---

## 完整安装流程 (推荐顺序)

### 第一步: 安装 Git (如果还没有)
```powershell
winget install Git.Git
```

### 第二步: 安装 CMake
```powershell
winget install Kitware.CMake
```

### 第三步: 安装 Visual Studio 2022
1. 下载: https://visualstudio.microsoft.com/downloads/
2. 选择工作负载: "使用 C++ 的桌面开发"
3. 等待安装完成 (约 10-30 分钟)

### 第四步: 安装 vcpkg 和依赖
```powershell
# 克隆 vcpkg
cd C:\
git clone https://github.com/microsoft/vcpkg
cd vcpkg
.\bootstrap-vcpkg.bat

# 设置环境变量
[System.Environment]::SetEnvironmentVariable("VCPKG_ROOT", "C:\vcpkg", "User")

# 安装依赖 (需要 30-60 分钟)
.\vcpkg install ffmpeg:x64-windows
.\vcpkg install qt6-base:x64-windows
.\vcpkg install qt6-multimedia:x64-windows
```

### 第五步: 重启 PowerShell
关闭并重新打开 PowerShell，使环境变量生效。

### 第六步: 编译和打包
```powershell
cd "C:\Users\Administrator\Desktop\视频剪辑助手"
.\build_and_package.ps1
```

---

## 快速检查清单

在运行编译脚本前，请确认以下工具已安装：

```powershell
# 检查 CMake
cmake --version

# 检查 Git
git --version

# 检查 vcpkg
if (Test-Path "C:\vcpkg\vcpkg.exe") {
    Write-Host "[OK] vcpkg installed" -ForegroundColor Green
} else {
    Write-Host "[ERROR] vcpkg not found" -ForegroundColor Red
}

# 检查 Visual Studio
if (Test-Path "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat") {
    Write-Host "[OK] Visual Studio 2022 installed" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Visual Studio 2022 not found" -ForegroundColor Red
}

# 检查环境变量
if ($env:VCPKG_ROOT) {
    Write-Host "[OK] VCPKG_ROOT = $env:VCPKG_ROOT" -ForegroundColor Green
} else {
    Write-Host "[ERROR] VCPKG_ROOT not set" -ForegroundColor Red
}
```

---

## 常见问题

### Q: 安装需要多长时间？
**A**: 
- CMake: 5 分钟
- Visual Studio: 20-40 分钟
- vcpkg + 依赖: 40-90 分钟
- **总计**: 约 1-2 小时

### Q: 需要多少磁盘空间？
**A**:
- Visual Studio: ~10 GB
- vcpkg 和依赖: ~15 GB
- **总计**: 约 25-30 GB

### Q: 可以使用其他版本的 Visual Studio 吗？
**A**: 可以使用 Visual Studio 2019 或 2022。不支持更早的版本。

### Q: 必须安装 Git 吗？
**A**: 是的，vcpkg 需要 Git 来下载依赖包。

### Q: 可以跳过 vcpkg 吗？
**A**: 不建议。vcpkg 是最简单的方式来安装 FFmpeg 和 Qt。手动安装更复杂。

---

## 安装完成后

安装完所有工具后：

1. **重启 PowerShell** (重要！)
2. 进入项目目录
3. 运行打包脚本

```powershell
cd "C:\Users\Administrator\Desktop\视频剪辑助手"
.\build_and_package.ps1
```

如果一切正常，您将看到：

```
===== Video Editor Build =====

Checking CMake...
[OK] CMake installed

Creating build directory...
[OK] Build directory created

Configuring CMake...
[OK] CMake configuration successful

Building project (Release)...
[OK] Build successful

===== Video Editor Package Script =====

[OK] Found executable
[OK] Qt dependencies deployed
[OK] FFmpeg DLLs copied
[OK] Documentation copied

===== All Complete! =====
SUCCESS - Program built and packaged!
```

---

## 需要帮助？

如果安装过程中遇到问题，请查看：

- **CMake 文档**: https://cmake.org/documentation/
- **Visual Studio 文档**: https://docs.microsoft.com/visualstudio/
- **vcpkg 文档**: https://vcpkg.io/
- **Qt 文档**: https://doc.qt.io/

---

**安装完成后，您就可以成功编译和打包程序了！** 🎉
