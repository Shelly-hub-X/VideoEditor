# 🧪 VideoEditor 烟雾测试方案

## 方案对比

| 方案 | 时间 | 优点 | 缺点 |
|------|------|------|------|
| **1. GitHub Actions 测试** | 5 分钟 | ✅ 云端执行,无需本地 Qt<br>✅ 真实编译环境 | ❌ 需要等待 |
| **2. Docker 容器测试** | 10 分钟 | ✅ 隔离环境<br>✅ 可重复 | ❌ 需要 Docker |
| **3. 代码静态分析** | 1 分钟 | ✅ 最快<br>✅ 发现语法错误 | ❌ 不能测试运行 |
| **4. 简化版本测试** | 2 分钟 | ✅ 快速验证逻辑 | ❌ 不测试 Qt 部分 |

---

## ✅ 推荐方案 1: GitHub Actions 烟雾测试

**创建轻量级测试工作流,只编译不打包**

### 优势
- ✅ 5 分钟内完成 (比完整构建快)
- ✅ 验证代码可以编译
- ✅ 不需要本地 Qt
- ✅ 可以并行测试多个平台

### 实施步骤

已创建测试工作流: `.github/workflows/smoke-test.yml`

触发方式:
```bash
# 推送任何分支都会触发
git push

# 或手动触发
# GitHub → Actions → Smoke Test → Run workflow
```

### 测试内容
- ✅ 代码编译测试
- ✅ Qt 链接测试
- ✅ 依赖检查
- ✅ 基础功能验证

---

## 🚀 方案 2: 本地静态分析 (最快)

**不需要编译,直接检查代码质量**

### 工具选择

1. **cppcheck** - C++ 静态分析
2. **clang-tidy** - 代码检查
3. **CMake 配置测试** - 验证构建脚本

### 快速使用

```powershell
# 运行静态分析
.\run_smoke_test.ps1
```

会检查:
- ✅ 语法错误
- ✅ 内存泄漏风险
- ✅ 未使用的变量
- ✅ CMakeLists.txt 正确性

---

## 🐳 方案 3: Docker 烟雾测试

**在容器中快速编译测试**

### 前提条件
- Docker Desktop 已安装

### 使用方法

```powershell
# 构建测试镜像
docker build -f Dockerfile.test -t videoeditor-test .

# 运行烟雾测试
docker run --rm videoeditor-test
```

### 测试时间
- 首次: ~10 分钟 (下载依赖)
- 后续: ~2 分钟 (使用缓存)

---

## 📝 方案 4: 单元测试 (推荐用于持续开发)

**测试核心逻辑,不依赖 Qt GUI**

### 创建测试文件

```cpp
// tests/VideoProcessor_test.cpp
#include "VideoProcessor.h"
#include <cassert>

void test_basic_functionality() {
    // 测试核心逻辑
    VideoProcessor processor;
    // ... 测试代码
}

int main() {
    test_basic_functionality();
    return 0;
}
```

### 编译测试

```powershell
# 只编译测试,不需要 Qt
g++ tests/VideoProcessor_test.cpp src/VideoProcessor.cpp -o test.exe
./test.exe
```

---

## 🎯 当前推荐

### 立即可用 (1 分钟内)

```powershell
# 运行本地静态分析
.\run_smoke_test.ps1
```

检查:
- ✅ CMakeLists.txt 语法
- ✅ vcpkg.json 格式
- ✅ 源代码基本语法
- ✅ 头文件引用

### 准确测试 (5-10 分钟)

```bash
# 推送到 GitHub 触发测试工作流
git add .
git commit -m "test: smoke test"
git push

# 查看结果
# https://github.com/Shelly-hub-X/VideoEditor/actions
```

---

## 📊 测试报告示例

### GitHub Actions 烟雾测试

```
✅ CMake 配置成功
✅ 依赖安装成功 (Qt 6.9.1, FFmpeg)
✅ 编译成功 (0 错误, 2 警告)
✅ 链接成功
⏱️  总时间: 4m 32s
```

### 本地静态分析

```
✅ CMakeLists.txt - OK
✅ vcpkg.json - OK
✅ 源文件语法 - OK
⚠️  MainWindow.cpp:45 - 未使用的变量 'temp'
⚠️  VideoDecoder.cpp:102 - 潜在的空指针
```

---

## 💡 最佳实践

### 开发流程

1. **本地开发** → 运行静态分析 (`run_smoke_test.ps1`)
2. **提交前** → 推送到测试分支,触发 GitHub Actions
3. **合并前** → 完整构建测试通过
4. **发布前** → 端到端测试 + 用户验收

### 持续集成

```yaml
# 每次提交自动测试
on: [push, pull_request]

# 快速失败,节省时间
fail-fast: true

# 并行测试多个场景
matrix:
  os: [ubuntu-latest, windows-latest]
  qt: [6.9.1, 6.8.0]
```

---

## 🔧 工具安装

### 静态分析工具 (可选)

```powershell
# cppcheck
winget install Cppcheck.Cppcheck

# clang-tidy (随 LLVM 安装)
winget install LLVM.LLVM
```

---

## 📞 快速开始

**选择最适合您的方式:**

```powershell
# 方式 1: 最快 - 本地静态检查 (1 分钟)
.\run_smoke_test.ps1

# 方式 2: 最准确 - GitHub Actions (5 分钟)
git push  # 自动触发测试

# 方式 3: 最完整 - 等待完整构建 (15 分钟)
# 查看 https://github.com/Shelly-hub-X/VideoEditor/actions
```
