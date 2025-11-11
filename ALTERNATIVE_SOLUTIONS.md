# 无需完整安装 - 替代方案

## 问题说明

C++ 项目不支持像 Python 那样的虚拟环境，因为需要真实的编译器和工具链。

但我们有以下几种**更简单的替代方案**：

---

## 方案 1: 使用 Docker（推荐 - 最干净）

### 优点
- ✅ 不污染系统环境
- ✅ 所有依赖都在容器内
- ✅ 可重复构建
- ✅ 编译完成后可删除容器

### 步骤

#### 1. 安装 Docker Desktop
下载: https://www.docker.com/products/docker-desktop/

#### 2. 创建 Dockerfile
我已经为您准备好了（见项目中的 Dockerfile）

#### 3. 使用 Docker 编译
```powershell
# 在项目目录运行
docker build -t videoeditor-build .
docker run --rm -v ${PWD}:/project videoeditor-build
```

编译完成后，release 文件夹会包含可执行文件。

**空间需求**: Docker Desktop ~500MB + 容器 ~3GB
**时间**: 首次构建 30-60 分钟

---

## 方案 2: 使用 Portable 工具链（快速但不完整）

### 使用 MSYS2 Portable

#### 1. 下载 MSYS2 Portable
```powershell
# 下载压缩包到临时目录
$url = "https://github.com/msys2/msys2-installer/releases/download/2023-10-26/msys2-base-x86_64-20231026.tar.xz"
# 解压到任意位置，如 D:\msys2
```

#### 2. 在 MSYS2 中安装工具
```bash
pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-cmake mingw-w64-x86_64-qt6 mingw-w64-x86_64-ffmpeg
```

#### 3. 编译项目
```bash
mkdir build && cd build
cmake .. -G "MinGW Makefiles"
cmake --build . --config Release
```

**优点**: 可以完全删除 msys2 文件夹
**缺点**: 可能与系统环境冲突

---

## 方案 3: GitHub Actions 云编译（零安装）

### 完全不用在本地安装任何工具！

我可以为您配置 GitHub Actions，在云端自动编译，然后下载编译好的 exe。

#### 工作流程
1. 您把代码推送到 GitHub
2. GitHub Actions 自动编译
3. 编译完成后下载 Release 包
4. 无需本地安装任何工具！

#### 需要
- GitHub 账号（免费）
- 把项目上传到 GitHub

我可以帮您创建 `.github/workflows/build.yml` 配置文件。

---

## 方案 4: 使用预编译的便携版工具（最快）

### 使用 winlibs (MinGW-w64 Portable)

#### 1. 下载便携版编译器
```powershell
# 下载 winlibs (包含 GCC 和 CMake)
# https://winlibs.com/
# 选择 "UCRT runtime" 版本
```

#### 2. 解压到临时目录
```powershell
# 例如解压到 D:\winlibs
```

#### 3. 临时添加到 PATH
```powershell
$env:PATH = "D:\winlibs\mingw64\bin;$env:PATH"
```

#### 4. 安装依赖到便携目录
使用 vcpkg 的便携模式，所有内容安装到项目目录而非系统。

---

## 方案 5: 使用虚拟机（隔离最彻底）

### 在虚拟机中编译

#### 1. 安装 VirtualBox 或 Hyper-V
#### 2. 创建 Windows 虚拟机
#### 3. 在虚拟机中安装所有工具
#### 4. 编译完成后，复制 exe 出来
#### 5. 删除虚拟机

**优点**: 完全隔离，不影响主系统
**缺点**: 需要虚拟机软件和额外的 Windows 许可证

---

## 我的推荐排序

### 🥇 第一推荐: GitHub Actions（零安装）
- **优点**: 完全不用本地安装
- **缺点**: 需要 GitHub 账号
- **适合**: 不想本地安装任何东西

### 🥈 第二推荐: Docker（干净）
- **优点**: 容器隔离，编译后可删除
- **缺点**: 需要安装 Docker Desktop
- **适合**: 希望保持系统干净

### 🥉 第三推荐: MSYS2 Portable（平衡）
- **优点**: 相对轻量，可以删除
- **缺点**: 还是需要下载几 GB
- **适合**: 想本地编译但不想污染系统

---

## 现在选择一个方案

告诉我您想用哪个方案，我帮您配置：

1️⃣ **GitHub Actions** - 我帮您创建配置文件  
2️⃣ **Docker** - 我帮您创建 Dockerfile  
3️⃣ **MSYS2 Portable** - 我提供详细步骤  
4️⃣ **其他方案** - 告诉我您的需求  

---

## 快速对比

| 方案 | 本地安装 | 编译速度 | 系统污染 | 难度 |
|------|---------|---------|---------|------|
| GitHub Actions | 0 MB | 慢（云端） | 无 | ⭐ |
| Docker | 500 MB | 中等 | 低 | ⭐⭐ |
| MSYS2 Portable | 2-3 GB | 快 | 低 | ⭐⭐⭐ |
| 完整安装 | 25 GB | 最快 | 高 | ⭐⭐⭐⭐ |

---

**您想用哪个方案？我立即帮您配置！** 🚀
