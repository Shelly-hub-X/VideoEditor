# 安装与配置指南

## Windows 安装指南

### 方法一: 从源代码构建 (推荐开发者)

#### 1. 安装必需软件

##### 1.1 安装 Visual Studio 2022

1. 下载 [Visual Studio 2022 Community](https://visualstudio.microsoft.com/zh-hans/downloads/)
2. 安装时选择 **"使用C++的桌面开发"** 工作负载
3. 确保包含以下组件:
   - MSVC v143
   - Windows 10/11 SDK
   - CMake工具

##### 1.2 安装 CMake

```powershell
# 使用 winget
winget install Kitware.CMake

# 或从官网下载
# https://cmake.org/download/
```

##### 1.3 安装 Git

```powershell
winget install Git.Git
```

#### 2. 安装 vcpkg (包管理器)

```powershell
# 克隆 vcpkg
cd C:\
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg

# 引导安装
.\bootstrap-vcpkg.bat

# 集成到 Visual Studio
.\vcpkg integrate install

# 设置环境变量
[System.Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'C:\vcpkg', 'User')
```

#### 3. 安装依赖库

```powershell
# 进入 vcpkg 目录
cd C:\vcpkg

# 安装 FFmpeg
.\vcpkg install ffmpeg:x64-windows

# 安装 Qt6
.\vcpkg install qt6-base:x64-windows
.\vcpkg install qt6-multimedia:x64-windows

# 等待安装完成 (可能需要30-60分钟)
```

#### 4. 获取源代码

```powershell
# 克隆项目 (如果从Git仓库)
git clone <repository_url>
cd 视频剪辑助手

# 或直接使用已有的项目目录
cd C:\Users\Administrator\Desktop\视频剪辑助手
```

#### 5. 构建项目

```powershell
# 方法A: 使用提供的脚本
.\build.ps1

# 方法B: 手动构建
mkdir build
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake
cmake --build . --config Release
```

#### 6. 运行程序

```powershell
# 方法A: 使用脚本
.\run.ps1

# 方法B: 直接运行
.\build\bin\Release\VideoEditor.exe
```

---

### 方法二: 使用预编译版本 (推荐普通用户)

1. **下载发行版**
   - 访问 [Releases](https://github.com/your-repo/releases) 页面
   - 下载最新的 `VideoEditor-v1.0.0-Windows-x64.zip`

2. **解压文件**
   - 解压到任意目录 (如 `C:\Program Files\VideoEditor`)

3. **运行程序**
   - 双击 `VideoEditor.exe`

4. **创建桌面快捷方式** (可选)
   - 右键 → 发送到 → 桌面快捷方式

---

## 常见安装问题

### 问题 1: vcpkg 安装 FFmpeg 失败

**症状**: 
```
error: FFmpeg installation failed
```

**解决方案**:
1. 检查网络连接
2. 使用代理 (如果在国内):
   ```powershell
   $env:HTTP_PROXY="http://proxy:port"
   $env:HTTPS_PROXY="http://proxy:port"
   ```
3. 重试安装:
   ```powershell
   .\vcpkg remove ffmpeg:x64-windows
   .\vcpkg install ffmpeg:x64-windows
   ```

---

### 问题 2: CMake 找不到 Qt

**症状**:
```
CMake Error: Could not find Qt6
```

**解决方案**:

方法A - 设置 Qt 路径:
```powershell
$env:CMAKE_PREFIX_PATH="C:\Qt\6.x.x\msvc2019_64"
```

方法B - 通过 vcpkg 安装:
```powershell
.\vcpkg install qt6-base:x64-windows
```

---

### 问题 3: 运行时找不到 DLL

**症状**:
```
无法启动程序,因为计算机中丢失 Qt6Core.dll
```

**解决方案**:

方法A - 使用 windeployqt:
```powershell
cd build\bin\Release
windeployqt VideoEditor.exe
```

方法B - 手动复制 DLL:
```powershell
# 复制 Qt DLL
copy C:\Qt\6.x.x\msvc2019_64\bin\*.dll build\bin\Release\

# 复制 FFmpeg DLL
copy C:\vcpkg\installed\x64-windows\bin\*.dll build\bin\Release\
```

---

### 问题 4: 编译错误 - C++17 特性

**症状**:
```
error C2039: 'filesystem': is not a member of 'std'
```

**解决方案**:
1. 确保使用 Visual Studio 2019 或更高版本
2. 检查 CMake 配置:
   ```cmake
   set(CMAKE_CXX_STANDARD 17)
   set(CMAKE_CXX_STANDARD_REQUIRED ON)
   ```

---

## 开发环境配置 (VS Code)

### 1. 安装 VS Code 扩展

打开 VS Code,安装以下扩展:

```
- C/C++ (ms-vscode.cpptools)
- CMake Tools (ms-vscode.cmake-tools)
- CMake (twxs.cmake)
```

### 2. 配置工作区

项目已包含 `.vscode` 配置文件:
- `tasks.json` - 构建任务
- `launch.json` - 调试配置
- `c_cpp_properties.json` - IntelliSense 配置
- `settings.json` - 工作区设置

### 3. 使用 VS Code 构建

1. 打开命令面板: `Ctrl+Shift+P`
2. 选择: `Tasks: Run Task`
3. 选择: `完整构建并运行`

### 4. 调试程序

1. 按 `F5` 开始调试
2. 或点击左侧 **运行和调试** 图标
3. 选择 `(Windows) 启动` 配置

---

## 打包发布

### 创建独立可执行程序

```powershell
# 1. 构建 Release 版本
cmake --build build --config Release

# 2. 创建发布目录
mkdir release
cd release

# 3. 复制可执行文件
copy ..\build\bin\Release\VideoEditor.exe .

# 4. 使用 windeployqt 收集依赖
windeployqt VideoEditor.exe

# 5. 复制 FFmpeg DLL
copy C:\vcpkg\installed\x64-windows\bin\avcodec*.dll .
copy C:\vcpkg\installed\x64-windows\bin\avformat*.dll .
copy C:\vcpkg\installed\x64-windows\bin\avutil*.dll .
copy C:\vcpkg\installed\x64-windows\bin\swscale*.dll .
copy C:\vcpkg\installed\x64-windows\bin\swresample*.dll .

# 6. 创建压缩包
Compress-Archive -Path * -DestinationPath VideoEditor-v1.0.0-Windows-x64.zip
```

### 使用 NSIS 创建安装程序 (可选)

1. 安装 [NSIS](https://nsis.sourceforge.io/)
2. 创建 `installer.nsi` 脚本
3. 使用 NSIS 编译安装程序

---

## 性能优化建议

### 编译优化

在 `CMakeLists.txt` 中添加:

```cmake
if(MSVC)
    add_compile_options(/O2 /GL)  # 最大优化
    add_link_options(/LTCG)       # 链接时代码生成
endif()
```

### 启用硬件加速

确保安装了显卡驱动:
- **NVIDIA**: [下载 CUDA](https://developer.nvidia.com/cuda-downloads)
- **Intel**: 更新集显驱动
- **AMD**: 更新显卡驱动

---

## 卸载

### 卸载程序

```powershell
# 删除程序目录
Remove-Item -Recurse -Force "C:\Program Files\VideoEditor"

# 删除用户数据 (如果有)
Remove-Item -Recurse -Force "$env:APPDATA\VideoEditor"
```

### 卸载开发环境

```powershell
# 删除 vcpkg (如果不再需要)
Remove-Item -Recurse -Force C:\vcpkg

# 删除构建目录
Remove-Item -Recurse -Force build
```

---

## 系统要求

### 最低要求
- Windows 10 64位 或更高
- 4GB RAM
- 100MB 可用磁盘空间
- 支持 OpenGL 2.0 的显卡

### 推荐配置
- Windows 11 64位
- 8GB+ RAM
- SSD 固态硬盘
- NVIDIA/Intel/AMD 独立显卡

---

## 获取帮助

如果安装过程遇到问题:

1. **查看文档**: `docs/` 目录下的详细文档
2. **搜索 Issues**: 在 GitHub Issues 中搜索类似问题
3. **提交 Issue**: 描述详细的错误信息和系统环境
4. **联系支持**: support@videoeditor.com

---

## 下一步

安装完成后,请查看:
- [用户手册](docs/用户手册.md) - 了解如何使用软件
- [开发文档](docs/开发文档.md) - 深入了解技术细节

祝您使用愉快! 🎉
