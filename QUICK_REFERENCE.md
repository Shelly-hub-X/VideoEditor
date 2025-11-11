# 视频剪辑助手 - 快速参考

## 🚀 5分钟快速开始

### 第一次使用

```powershell
# 1. 安装 vcpkg
git clone https://github.com/Microsoft/vcpkg.git C:\vcpkg
C:\vcpkg\bootstrap-vcpkg.bat

# 2. 安装依赖
C:\vcpkg\vcpkg install ffmpeg:x64-windows qt6-base:x64-windows

# 3. 构建项目
cd "C:\Users\Administrator\Desktop\视频剪辑助手"
.\build.ps1

# 4. 运行
.\run.ps1
```

---

## 📁 关键文件速查

| 文件 | 用途 |
|------|------|
| `README.md` | 项目介绍 |
| `INSTALL.md` | 详细安装指南 |
| `docs/用户手册.md` | 使用说明 |
| `docs/开发文档.md` | 技术文档 |
| `CONTRIBUTING.md` | 贡献指南 |
| `build.ps1` | 一键构建 |
| `run.ps1` | 一键运行 |

---

## 🎯 核心功能使用

### 拆分视频

```
1. 打开文件 → 选择视频
2. 拆分视频 → 选择输出目录
3. 等待完成
```

**输出**: `frames/` (图片) + `audio.mp3` (音频)

### 合成视频

```
1. 合成视频 → 选择图片文件夹
2. 选择音频文件
3. 选择输出位置
4. 等待完成
```

**输入**: 图片序列 + 音频文件  
**输出**: `output.mp4`

### 设置封面

```
1. 打开视频
2. 拖动进度条到目标位置
3. 点击"设为封面"
4. 选择保存位置
```

---

## 💻 常用命令

### CMake 构建

```powershell
# 配置
cmake -B build -DCMAKE_TOOLCHAIN_FILE=C:\vcpkg\scripts\buildsystems\vcpkg.cmake

# 编译 (Debug)
cmake --build build --config Debug

# 编译 (Release)
cmake --build build --config Release

# 清理
Remove-Item build -Recurse -Force
```

### VS Code 任务

| 任务 | 快捷键 | 功能 |
|------|--------|------|
| 构建项目 (Release) | `Ctrl+Shift+B` | 编译发布版 |
| 运行程序 | - | 启动应用 |
| 完整构建并运行 | - | 一键构建运行 |

---

## 🔍 代码导航

### 主要类层次

```
QMainWindow
  └─ MainWindow              # 主窗口

QObject
  ├─ VideoPlayer             # 视频播放器
  └─ VideoProcessor          # 视频处理器

Plain C++ Classes
  ├─ VideoDecoder            # 解码器
  └─ VideoEncoder            # 编码器
```

### 关键信号与槽

```cpp
// VideoPlayer → MainWindow
frameReady(QImage)           → onFrameReady()
positionChanged(qint64)      → onPositionChanged()
videoInfoReady(QString)      → onVideoInfoReady()

// VideoProcessor → MainWindow
progressUpdated(int)         → onProcessProgress()
finished(bool, QString)      → onProcessFinished()

// UI → Logic
openButton.clicked()         → onOpenFile()
playButton.clicked()         → onPlayPause()
splitButton.clicked()        → onSplitVideo()
```

---

## 🐛 快速调试

### 常见问题

**Q: 找不到 Qt6Core.dll**
```powershell
# 解决: 运行 windeployqt
windeployqt build\bin\Release\VideoEditor.exe
```

**Q: CMake 找不到 FFmpeg**
```powershell
# 解决: 重新安装
C:\vcpkg\vcpkg remove ffmpeg:x64-windows
C:\vcpkg\vcpkg install ffmpeg:x64-windows
```

**Q: 编译错误: C2039**
```
# 解决: 检查 C++ 标准
CMakeLists.txt 中应有:
set(CMAKE_CXX_STANDARD 17)
```

### 调试输出

```cpp
// 启用 FFmpeg 日志
av_log_set_level(AV_LOG_DEBUG);

// Qt 消息格式
qSetMessagePattern("%{time yyyy-MM-dd hh:mm:ss} [%{type}] %{message}");

// 条件断点
if (frameCount == 100) {
    qDebug() << "到达第100帧";
}
```

---

## 📊 性能参考

### 典型处理速度

| 操作 | 1080p | 4K |
|------|-------|-----|
| 视频解码 | 60 fps | 30 fps |
| 图片提取 | 200 fps | 100 fps |
| 视频编码 | 40 fps | 15 fps |

*基于 i7-10700K + RTX 3060 测试*

### 内存使用

- 空载: ~50 MB
- 播放 1080p: ~200 MB
- 处理 4K: ~500 MB

---

## 🎨 UI 快捷键 (建议实现)

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+O` | 打开文件 |
| `Space` | 播放/暂停 |
| `←/→` | 快退/快进 5秒 |
| `Ctrl+S` | 保存封面 |
| `Ctrl+Q` | 退出程序 |

---

## 📦 依赖版本

| 库 | 最低版本 | 推荐版本 |
|----|----------|----------|
| Qt | 6.2 | 6.5+ |
| FFmpeg | 4.4 | 5.1+ |
| CMake | 3.20 | 3.26+ |
| MSVC | 2019 | 2022 |

---

## 🔗 快速链接

- **项目主页**: [GitHub Repository]
- **问题反馈**: [GitHub Issues]
- **用户文档**: `docs/用户手册.md`
- **开发文档**: `docs/开发文档.md`
- **Qt 文档**: https://doc.qt.io/
- **FFmpeg 文档**: https://ffmpeg.org/documentation.html

---

## 📝 提交规范速查

```bash
feat:     新功能
fix:      Bug修复
docs:     文档更新
style:    格式调整
refactor: 重构
perf:     性能优化
test:     测试
chore:    构建/工具
```

**示例**:
```bash
git commit -m "feat: 添加批量处理功能"
git commit -m "fix: 修复内存泄漏问题"
```

---

## 🛠️ 开发工具推荐

### VS Code 扩展

- `ms-vscode.cpptools` - C++ IntelliSense
- `ms-vscode.cmake-tools` - CMake 支持
- `twxs.cmake` - CMake 语法高亮
- `lever-studio.qt-tools` - Qt 工具

### 其他工具

- **Dependency Walker** - 检查 DLL 依赖
- **Qt Creator** - Qt 官方 IDE
- **Visual Studio** - 强大的 C++ IDE
- **Process Explorer** - 进程监控

---

## 📞 获取帮助

1. **查看文档** → `docs/` 目录
2. **搜索 Issues** → GitHub Issues
3. **提问** → GitHub Discussions
4. **邮件** → support@videoeditor.com

---

## ✅ 快速检查清单

### 开发前

- [ ] 安装了 Visual Studio 2019+
- [ ] 安装了 CMake 3.20+
- [ ] 安装了 vcpkg
- [ ] vcpkg 安装了 ffmpeg 和 qt6

### 提交前

- [ ] 代码编译无警告
- [ ] 运行测试全部通过
- [ ] 更新了相关文档
- [ ] 提交信息符合规范
- [ ] 无合并冲突

### 发布前

- [ ] 版本号已更新
- [ ] CHANGELOG 已更新
- [ ] 所有测试通过
- [ ] 文档已同步
- [ ] 创建了 Git 标签

---

**打印此页作为快速参考!** 📋
