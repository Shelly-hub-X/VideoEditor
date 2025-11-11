# 使用 GitHub Actions 自动编译和打包

## ✅ 已完成配置

GitHub Actions 工作流已更新并修复,位于:
- .github/workflows/build.yml

## 📋 使用步骤

### 步骤 1: 初始化 Git 仓库

```powershell
cd C:\VideoEditor

# 初始化 Git (如果还未初始化)
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit with fixed GitHub Actions workflow"
```

### 步骤 2: 创建 GitHub 仓库并推送

1. **在 GitHub 创建新仓库**
   - 访问: https://github.com/new
   - 仓库名: ideo-editor (或您喜欢的名字)
   - 设为 Public 或 Private
   - 不要初始化 README (因为本地已有)

2. **关联并推送到 GitHub**

```powershell
# 添加远程仓库 (替换 YOUR_USERNAME 为您的 GitHub 用户名)
git remote add origin https://github.com/YOUR_USERNAME/video-editor.git

# 推送代码
git branch -M main
git push -u origin main
```

### 步骤 3: 触发自动编译

推送后,GitHub Actions 会自动开始编译。您可以:

1. 访问仓库的 **Actions** 标签页
2. 查看编译进度 (大约需要 30-60 分钟)
3. 编译完成后,在 **Artifacts** 区域下载 VideoEditor-Windows-x64.zip

### 🚀 手动触发编译

如果需要手动触发:

1. 进入仓库的 **Actions** 页面
2. 选择 **Build and Package Video Editor**
3. 点击 **Run workflow** 按钮
4. 选择分支 (main) 并点击 **Run workflow**

### 📦 下载编译好的 exe

编译完成后:

1. 进入 **Actions** → 选择最新的成功运行
2. 向下滚动到 **Artifacts** 区域
3. 下载 VideoEditor-Windows-x64.zip
4. 解压即可使用

## ⚙️ 工作流特点

- ✅ 自动安装所有依赖 (Qt, FFmpeg)
- ✅ 使用 vcpkg.json 管理依赖
- ✅ 自动打包 DLL 和资源文件
- ✅ 生成可直接运行的 exe
- ✅ 超时保护 (2小时)
- ✅ 支持标签发布 (打 tag 时自动创建 Release)

## 📊 预计时间

| 阶段 | 时间 |
|------|------|
| 安装依赖 | 20-40 分钟 |
| 编译项目 | 5-10 分钟 |
| 打包 | 2-5 分钟 |
| **总计** | **30-60 分钟** |

## 🔖 发布版本

如果需要创建正式发布版本:

```powershell
# 创建并推送标签
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

这会自动在 GitHub Releases 页面创建发布,并附带编译好的 exe。

## ❓ 常见问题

### Q: 编译失败怎么办?
A: 点击失败的工作流,查看日志找到错误原因。常见问题:
- CMakeLists.txt 配置错误
- vcpkg.json 依赖声明错误
- 源代码编译错误

### Q: 能否加速编译?
A: 可以通过缓存加速:
- vcpkg 会自动缓存已编译的包
- 第二次编译通常只需 10-15 分钟

### Q: 本地没有 Git 怎么办?
A: 运行: `winget install Git.Git`

## 📝 下一步

1. 按照上述步骤推送到 GitHub
2. 等待自动编译完成
3. 下载并测试编译好的 exe
4. 如有问题,查看 GitHub Actions 日志

---

**优势**: 无需本地安装 Qt,利用 GitHub 的免费云端资源完成编译!
