# Video Editor - Complete Installation Guide

## Current Status (已完成的部分)

✅ CMake 4.1.2 - Installed  
✅ Git - Installed  
✅ vcpkg - Installed at D:\videoeditor-env\vcpkg  

## Step 1: Install Visual Studio Build Tools (约 5-10 分钟)

### 操作步骤：

1. **打开 Visual Studio Installer**
   - 按 Windows 键
   - 搜索 "Visual Studio Installer"
   - 点击运行

2. **配置 Build Tools**
   - 找到 "Visual Studio Build Tools 2022"
   - 点击 "修改" (Modify) 按钮
   - 在左侧工作负载列表中，勾选：
     ✅ **使用 C++ 的桌面开发** (Desktop development with C++)
   
3. **确认组件（右侧面板应包含）**
   - ✅ MSVC v143 - VS 2022 C++ x64/x86 生成工具
   - ✅ Windows 10 SDK 或 Windows 11 SDK
   - ✅ C++ CMake tools for Windows

4. **开始安装**
   - 点击右下角 "修改" 按钮
   - 等待下载和安装完成（约 3-8 GB）

5. **验证安装**
   打开一个新的 PowerShell 窗口，运行：
   ```powershell
   cd "c:\Users\Administrator\Desktop\视频剪辑助手"
   .\check_environment.ps1
   ```
   应该看到：`[OK] Visual Studio installed`

---

## Step 2: Install PowerShell 7 (约 2 分钟)

当前系统使用 PowerShell 5.1，但 vcpkg 需要 PowerShell 7.5+

### 操作步骤：

1. **运行安装命令**（在当前 PowerShell 中）：
   ```powershell
   winget install Microsoft.PowerShell
   ```

2. **等待安装完成**
   安装完成后，关闭当前的 PowerShell 窗口

3. **打开 PowerShell 7**
   - 按 Windows 键
   - 搜索 "PowerShell 7" 或 "pwsh"
   - 运行新版本（注意图标是蓝色/黑色的，不是蓝色的）

4. **验证版本**
   在新的 PowerShell 7 窗口中运行：
   ```powershell
   $PSVersionTable.PSVersion
   ```
   应该显示 7.x.x

---

## Step 3: Install FFmpeg and Qt6 (约 30-90 分钟)

这是最耗时的步骤，vcpkg 会下载并从源码编译这些库。

### 操作步骤（必须在 PowerShell 7 中运行）：

1. **切换到 vcpkg 目录**
   ```powershell
   cd D:\videoeditor-env\vcpkg
   ```

2. **设置环境变量**（如果还没设置）
   ```powershell
   $env:VCPKG_ROOT = "D:\videoeditor-env\vcpkg"
   [System.Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'D:\videoeditor-env\vcpkg', 'User')
   ```

3. **安装包（一条命令安装全部）**
   ```powershell
   .\vcpkg install ffmpeg:x64-windows qt6-base:x64-windows qt6-multimedia:x64-windows
   ```

   **预计时间**：
   - FFmpeg: 15-30 分钟
   - Qt6 Base: 15-40 分钟
   - Qt6 Multimedia: 5-15 分钟
   
   **注意事项**：
   - 过程中会显示大量编译信息，这是正常的
   - 不要关闭窗口
   - 如果中途失败，可以重新运行相同命令（vcpkg 会续传）

4. **验证安装**
   ```powershell
   .\vcpkg list
   ```
   应该看到：
   ```
   ffmpeg:x64-windows
   qt6-base:x64-windows
   qt6-multimedia:x64-windows
   ```

---

## Step 4: Build and Package (约 5-10 分钟)

所有依赖安装完成后，编译打包项目。

### 操作步骤（在 PowerShell 7 中）：

1. **切换到项目目录**
   ```powershell
   cd "c:\Users\Administrator\Desktop\视频剪辑助手"
   ```

2. **运行构建脚本**
   ```powershell
   .\build_and_package.ps1
   ```

3. **等待编译完成**
   会依次执行：
   - CMake 配置
   - MSVC 编译
   - Qt 部署（windeployqt）
   - 复制 FFmpeg DLL

4. **检查输出**
   成功后会在以下位置生成 exe：
   ```
   release\VideoEditor\VideoEditor.exe
   ```

---

## Step 5: Test the EXE (验证)

1. **找到生成的文件**
   ```powershell
   cd release\VideoEditor
   dir VideoEditor.exe
   ```

2. **运行测试**
   ```powershell
   .\VideoEditor.exe
   ```

3. **如果遇到缺少 DLL 的错误**
   记录缺少的 DLL 名称，然后：
   - 对于 Qt DLL：重新运行 `windeployqt VideoEditor.exe`
   - 对于 FFmpeg DLL：从 `D:\videoeditor-env\vcpkg\installed\x64-windows\bin` 复制

---

## Troubleshooting (常见问题)

### 问题 1: Visual Studio Installer 找不到
**解决方案**：
手动下载安装程序：
https://visualstudio.microsoft.com/downloads/
选择 "Build Tools for Visual Studio 2022"

### 问题 2: vcpkg 安装包失败（网络错误）
**解决方案**：
```powershell
# 设置代理（如果有）
$env:HTTP_PROXY = "http://127.0.0.1:7897"
$env:HTTPS_PROXY = "http://127.0.0.1:7897"

# 或使用清华镜像
$env:VCPKG_BINARY_SOURCES = "clear;x-azurl,https://mirrors.tuna.tsinghua.edu.cn/vcpkg-mirror/,readwrite"
```

### 问题 3: 编译时找不到 vcpkg 工具链
**解决方案**：
```powershell
# 确认 VCPKG_ROOT 设置正确
echo $env:VCPKG_ROOT
# 应该输出: D:\videoeditor-env\vcpkg

# 如果为空，重新设置
$env:VCPKG_ROOT = "D:\videoeditor-env\vcpkg"
```

### 问题 4: 运行 exe 时缺少 vcruntime140.dll
**解决方案**：
安装 Visual C++ Redistributable：
```powershell
winget install Microsoft.VCRedist.2015+.x64
```

---

## Quick Reference (快速参考命令)

### 检查环境
```powershell
cd "c:\Users\Administrator\Desktop\视频剪辑助手"
.\check_environment.ps1
```

### 仅编译（不打包）
```powershell
.\build.ps1
```

### 仅打包（已编译）
```powershell
.\package.ps1
```

### 完整流程
```powershell
.\build_and_package.ps1
```

---

## Estimated Total Time

- Step 1 (VS Build Tools): 5-10 分钟
- Step 2 (PowerShell 7): 2 分钟
- Step 3 (vcpkg packages): 30-90 分钟 ⏰
- Step 4 (Build): 5-10 分钟
- Step 5 (Test): 1 分钟

**总计**: 约 45-120 分钟（主要等待时间在 Step 3）

---

## Next Steps

现在请按照以下顺序执行：

1. ✅ 立即开始 **Step 1** - 安装 Visual Studio Build Tools
2. ✅ 同时可以进行 **Step 2** - 安装 PowerShell 7（不冲突）
3. ⏳ 等待前两步完成后，进行 **Step 3** - 安装 vcpkg 包（最耗时）
4. ⏳ 最后执行 **Step 4** 和 **Step 5** - 编译和测试

完成每一步后，请告诉我结果，我会帮您继续下一步！
