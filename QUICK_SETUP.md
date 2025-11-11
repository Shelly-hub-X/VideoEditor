# 快速开始 - 安装开发工具

## 问题原因

您看到的错误 **"封包exe失败"** 是因为缺少编译工具，不是脚本的问题。

检查结果显示缺少以下工具：
- ❌ CMake
- ❌ Git  
- ❌ Visual Studio
- ❌ vcpkg

---

## 快速安装（推荐方式）

### 方式 1: 使用 winget（最简单）

如果您的 Windows 10/11 有 winget，直接运行：

```powershell
# 安装 Git
winget install Git.Git

# 安装 CMake
winget install Kitware.CMake

# 重启 PowerShell
exit
```

重新打开 PowerShell 后继续：

```powershell
# 克隆 vcpkg
cd C:\
git clone https://github.com/microsoft/vcpkg
cd vcpkg
.\bootstrap-vcpkg.bat

# 设置环境变量
[System.Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'C:\vcpkg', 'User')
```

### 方式 2: 手动下载安装

#### 1. 安装 Git
- 下载: https://git-scm.com/download/win
- 运行安装程序，全部使用默认选项

#### 2. 安装 CMake  
- 下载: https://cmake.org/download/
- 选择 "Windows x64 Installer"
- **重要**: 安装时勾选 "Add CMake to system PATH"

#### 3. 重启 PowerShell

#### 4. 安装 vcpkg
```powershell
cd C:\
git clone https://github.com/microsoft/vcpkg
cd vcpkg
.\bootstrap-vcpkg.bat
[System.Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'C:\vcpkg', 'User')
```

---

## Visual Studio 安装（需要时间）

Visual Studio 是最大的下载，需要单独安装：

### 下载
https://visualstudio.microsoft.com/downloads/

### 选择版本
下载 **Visual Studio 2022 Community** (免费版)

### 安装步骤
1. 运行安装程序
2. 在"工作负载"选项卡中选择:
   - ✅ **使用 C++ 的桌面开发**
3. 点击"安装"
4. 等待安装完成（约 20-40 分钟）

---

## 安装项目依赖（耗时较长）

安装完 vcpkg 后，需要安装 FFmpeg 和 Qt：

```powershell
cd C:\vcpkg

# 安装 FFmpeg (约 15-30 分钟)
.\vcpkg install ffmpeg:x64-windows

# 安装 Qt (约 20-40 分钟)  
.\vcpkg install qt6-base:x64-windows
.\vcpkg install qt6-multimedia:x64-windows
```

**注意**: 这个过程会下载并编译大量代码，需要 30-90 分钟，请耐心等待。

---

## 验证安装

安装完成后，运行检查脚本：

```powershell
cd "C:\Users\Administrator\Desktop\视频剪辑助手"
.\check_environment.ps1
```

如果看到全部 `[OK]`，就可以开始编译了：

```powershell
.\build_and_package.ps1
```

---

## 时间和空间需求

| 项目 | 时间 | 磁盘空间 |
|------|------|---------|
| Git + CMake | 5-10 分钟 | ~500 MB |
| Visual Studio | 20-40 分钟 | ~10 GB |
| vcpkg + 依赖 | 30-90 分钟 | ~15 GB |
| **总计** | **1-2 小时** | **~25 GB** |

---

## 简化方案（如果时间紧张）

如果您只是想测试程序功能，有两个选择：

### 选项 1: 使用预编译版本
如果有其他已经配置好环境的电脑，可以在那里编译，然后把 `release\VideoEditor` 文件夹复制过来直接使用。

### 选项 2: 云编译
使用 GitHub Actions 或其他 CI/CD 服务进行云端编译（需要配置）。

---

## 常见问题

### Q: 可以跳过某些工具吗？
**A**: 不行。所有工具都是必需的：
- Git: vcpkg 需要
- CMake: 构建系统
- Visual Studio: C++ 编译器
- vcpkg: 管理依赖库

### Q: 可以使用其他编译器吗？
**A**: 理论上可以用 MinGW 或 Clang，但配置更复杂。推荐使用 Visual Studio。

### Q: 必须安装到 C:\ 吗？
**A**: vcpkg 可以安装到其他位置，但需要相应修改 VCPKG_ROOT 环境变量。

---

## 下一步

1. ✅ 安装所有必需工具（按上述步骤）
2. ✅ 运行 `check_environment.ps1` 验证
3. ✅ 运行 `build_and_package.ps1` 编译
4. ✅ 测试 `release\VideoEditor\VideoEditor.exe`

---

**需要详细安装说明，请查看: INSTALL_DEPENDENCIES.md** 📚
