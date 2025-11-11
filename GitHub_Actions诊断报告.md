# GitHub Actions 全面诊断报告

## 🔍 潜在问题点分析

---

### ⚠️ 问题 1: CMakeLists.txt 中的 PkgConfig

**问题描述**:
```cmake
find_package(PkgConfig REQUIRED)
pkg_check_modules(FFMPEG REQUIRED ...)
```

**潜在风险**:
- Windows 上 PkgConfig 可能不存在
- vcpkg 提供的 FFmpeg 不一定有 .pc 文件
- 会导致 CMake 配置失败

**解决方案**:
改用 vcpkg 的 find_package 方式查找 FFmpeg

---

### ⚠️ 问题 2: vcpkg_installed 路径问题

**当前代码**:
```powershell
$windeployqt = Get-ChildItem -Path vcpkg_installed/x64-windows ...
Copy-Item vcpkg_installed/x64-windows/bin/*.dll ...
```

**潜在风险**:
- vcpkg 安装目录可能是 `vcpkg/installed/x64-windows`
- 不是 `vcpkg_installed/x64-windows`
- 导致找不到 DLL 和 windeployqt

**正确路径**:
```powershell
vcpkg/installed/x64-windows/bin
```

---

### ⚠️ 问题 3: 缺少 vcpkg manifest mode 的 vcpkg-configuration.json

**问题描述**:
- 使用 manifest mode 但没有配置文件
- 可能导致 vcpkg 使用默认配置
- 某些依赖可能安装失败

**建议**:
添加 vcpkg-configuration.json 指定 registry

---

### ⚠️ 问题 4: CMake 可能找不到 FFmpeg

**问题描述**:
使用 PkgConfig 在 Windows 上不可靠

**推荐方案**:
```cmake
# 不使用 PkgConfig
find_package(FFMPEG REQUIRED COMPONENTS 
    avcodec avformat avutil swscale swresample)
```

但 vcpkg 的 FFmpeg 可能不支持这种方式

**实际最佳方案**:
直接链接库文件,不使用 find_package

---

### ⚠️ 问题 5: 构建超时风险

**当前配置**:
- timeout: 60 分钟
- 并行编译: 2

**潜在问题**:
- FFmpeg 编译可能超过 30 分钟
- Qt 编译可能超过 40 分钟
- 总计可能超过 60 分钟

**建议**:
增加到 90 分钟

---

## ✅ 立即修复方案

### 修复 1: 更新 CMakeLists.txt

**移除 PkgConfig,直接使用 vcpkg 提供的库**

```cmake
# 查找 FFmpeg (vcpkg 方式)
find_path(AVCODEC_INCLUDE_DIR libavcodec/avcodec.h)
find_library(AVCODEC_LIBRARY avcodec)
find_library(AVFORMAT_LIBRARY avformat)
find_library(AVUTIL_LIBRARY avutil)
find_library(SWSCALE_LIBRARY swscale)
find_library(SWRESAMPLE_LIBRARY swresample)

# 链接
target_link_libraries(VideoEditor PRIVATE
    ${AVCODEC_LIBRARY}
    ${AVFORMAT_LIBRARY}
    ${AVUTIL_LIBRARY}
    ${SWSCALE_LIBRARY}
    ${SWRESAMPLE_LIBRARY}
)
```

### 修复 2: 修正 workflow 中的路径

**当前错误**:
```powershell
vcpkg_installed/x64-windows
```

**修复为**:
```powershell
vcpkg/installed/x64-windows
```

### 修复 3: 增加超时时间

```yaml
timeout-minutes: 90  # 从 60 改为 90
```

### 修复 4: 添加调试输出

在 workflow 中添加更多日志,便于诊断问题

---

## 🎯 推荐的完整修复

### 方案 A: 保守修复 (只改 workflow)

只修复明确的路径错误和超时问题,不动 CMakeLists.txt

**优点**:
- 风险小
- 快速

**缺点**:
- 如果 PkgConfig 确实有问题,仍会失败

### 方案 B: 完全修复 (改 CMakeLists.txt + workflow)

同时修复 CMake 配置和 workflow

**优点**:
- 彻底解决问题
- 更稳定

**缺点**:
- 需要测试 CMake 配置是否正确

---

## 💡 建议

### 立即执行:

1. **先修复 workflow 路径问题** (必须)
   - `vcpkg_installed` → `vcpkg/installed`

2. **增加超时时间** (预防性)
   - `60` → `90` 分钟

3. **添加调试输出** (便于排查)
   - 显示 vcpkg 安装目录结构
   - 显示找到的 DLL 列表

### 观察构建结果:

- 如果成功 → 问题解决 ✅
- 如果失败在 CMake 配置 → 修复 CMakeLists.txt
- 如果失败在打包 → 检查路径问题

---

## 📋 检查清单

当前状态:

- [x] vcpkg.json 配置正确
- [x] 基础文件都存在
- [x] workflow 语法正确
- [ ] **vcpkg_installed 路径错误** ← 需要修复
- [ ] **超时时间可能不够** ← 建议增加
- [ ] **PkgConfig 可能失败** ← 待观察
- [x] 缓存配置已添加
- [x] 并行编译已限制

---

## 🚨 最可能导致失败的 3 个问题

### 1. vcpkg_installed 路径错误 🔴 (最严重)

**影响**: 找不到 DLL,打包失败

**症状**:
```
Copy-Item: Cannot find path 'vcpkg_installed/x64-windows/bin'
```

**优先级**: **立即修复**

### 2. PkgConfig 在 Windows 上失败 🟡 (可能)

**影响**: CMake 配置失败

**症状**:
```
CMake Error: Could NOT find PkgConfig
```

**优先级**: 观察,如果失败再修复

### 3. 编译超时 🟡 (可能)

**影响**: 60 分钟不够

**症状**:
```
Error: The operation was canceled.
```

**优先级**: 预防性增加到 90 分钟

---

## ✅ 建议立即执行的修复

```yaml
# 1. 修复路径
vcpkg_installed/x64-windows → vcpkg/installed/x64-windows

# 2. 增加超时
timeout-minutes: 60 → timeout-minutes: 90

# 3. 添加调试输出
- name: Debug vcpkg structure
  run: |
    Get-ChildItem vcpkg/installed -Recurse | Select-Object FullName
```

---

生成时间: 2025年11月11日
