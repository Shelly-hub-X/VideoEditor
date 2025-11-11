# 零安装编译方案 - GitHub Actions

## 🎯 最简单的方法 - 完全不用本地安装任何工具！

使用 GitHub Actions 在云端自动编译，您只需要：
1. 一个 GitHub 账号（免费）
2. 上传代码
3. 下载编译好的 exe

---

## 📋 详细步骤

### 第一步: 创建 GitHub 账号

如果还没有 GitHub 账号：
1. 访问 https://github.com
2. 点击 "Sign up"
3. 按提示创建免费账号

### 第二步: 创建新仓库

1. 登录 GitHub
2. 点击右上角 "+" → "New repository"
3. 填写信息：
   - Repository name: `video-editor`
   - Description: `视频剪辑助手`
   - Public 或 Private（都可以）
   - ✅ 勾选 "Add a README file"
4. 点击 "Create repository"

### 第三步: 上传项目代码

#### 方法 A: 使用 GitHub Desktop（推荐 - 简单）

1. 下载 GitHub Desktop: https://desktop.github.com/
2. 安装并登录
3. File → Clone repository → 选择刚创建的仓库
4. 把项目文件复制到克隆的文件夹中
5. 在 GitHub Desktop 中：
   - 输入提交消息: "Initial commit"
   - 点击 "Commit to main"
   - 点击 "Push origin"

#### 方法 B: 使用 Git 命令行

```powershell
# 在项目目录运行
cd "C:\Users\Administrator\Desktop\视频剪辑助手"

# 初始化 Git（如果还没安装 Git，先安装: winget install Git.Git）
git init
git add .
git commit -m "Initial commit"

# 连接到 GitHub（替换成您的用户名和仓库名）
git remote add origin https://github.com/YOUR_USERNAME/video-editor.git
git branch -M main
git push -u origin main
```

#### 方法 C: 直接上传文件（最简单但文件多时麻烦）

1. 在 GitHub 仓库页面点击 "Add file" → "Upload files"
2. 拖拽所有项目文件
3. 点击 "Commit changes"

### 第四步: 等待自动编译

上传完成后：
1. 点击仓库的 "Actions" 标签页
2. 您会看到编译任务正在运行（黄色圆圈）
3. 等待 20-40 分钟（首次编译较慢）
4. 编译完成后会显示绿色勾号 ✅

### 第五步: 下载编译好的程序

编译成功后：
1. 点击完成的工作流
2. 向下滚动到 "Artifacts" 部分
3. 点击 "VideoEditor-Windows-x64" 下载
4. 解压 ZIP 文件
5. 双击 `VideoEditor.exe` 运行！

---

## 🚀 每次修改代码后

以后如果修改了代码：
1. 把修改的文件推送到 GitHub
2. GitHub Actions 自动重新编译
3. 下载新的编译结果

使用 GitHub Desktop：
- 打开 GitHub Desktop
- 输入提交消息
- 点击 "Commit" → "Push"
- 等待编译完成

---

## 💡 优点

✅ **零安装** - 本地不需要安装任何编译工具  
✅ **零配置** - 不需要配置环境变量  
✅ **零污染** - 不占用本地磁盘空间  
✅ **可重复** - 每次都是干净的编译环境  
✅ **免费** - GitHub Actions 对公开仓库完全免费  
✅ **跨平台** - 可以在任何电脑上访问  

---

## 📊 限制

GitHub Actions 的限制：
- 公开仓库：无限制使用
- 私有仓库：每月 2000 分钟免费
- 单次编译时间：约 20-40 分钟
- 每个工作流最多运行 6 小时

对于这个项目来说，完全足够！

---

## 🔧 故障排除

### Q: 编译失败怎么办？

1. 点击失败的工作流查看日志
2. 查看具体错误信息
3. 根据错误修复代码
4. 重新推送

### Q: 找不到 Artifacts？

确保：
1. 工作流已完成（绿色勾号）
2. 向下滚动到页面底部的 "Artifacts" 部分
3. Artifacts 会在 90 天后自动删除

### Q: 可以本地测试吗？

可以！安装 [act](https://github.com/nektos/act) 工具在本地运行 GitHub Actions。

---

## 🎓 进阶用法

### 自动发布 Release

如果您想创建正式版本：

```powershell
# 打标签
git tag v1.0.0
git push origin v1.0.0
```

这会触发编译并自动创建 GitHub Release，用户可以直接下载。

### 定时编译

修改 `.github/workflows/build.yml`，添加定时触发：

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # 每周日午夜编译
```

---

## 📝 我已经为您创建的文件

✅ `.github/workflows/build.yml` - GitHub Actions 配置文件

您只需要把项目上传到 GitHub，其他都是自动的！

---

## 🆚 与其他方案对比

| 方案 | 本地安装 | 编译时间 | 复杂度 | 推荐度 |
|------|---------|---------|--------|--------|
| **GitHub Actions** | 0 | 20-40分钟 | ⭐ | ⭐⭐⭐⭐⭐ |
| Docker | 500 MB | 40-60分钟 | ⭐⭐⭐ | ⭐⭐⭐ |
| 完整安装 | 25 GB | 5-10分钟 | ⭐⭐⭐⭐ | ⭐⭐ |

---

## 🎉 开始使用

1. 创建 GitHub 账号（如果没有）
2. 上传项目代码
3. 等待自动编译
4. 下载并运行！

**完全不需要在本地安装 Visual Studio、CMake、vcpkg 等任何工具！** 🚀

---

需要帮助？告诉我您在哪一步遇到问题！
