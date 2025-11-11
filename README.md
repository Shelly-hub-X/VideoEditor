# 视频剪辑助手

一款用户友好的桌面应用程序，允许用户高效地对视频进行拆分和合成。

## 核心功能

- ✅ **视频信息展示**: 显示视频的分辨率、帧率、码率、总帧数
- ✅ **视频预览播放**: 支持播放/暂停、进度条拖动、快速跳转
- ✅ **一键拆分视频**: 将视频拆分为图片序列 + 音频文件
- ✅ **一键合成视频**: 将图片序列 + 音频合成为视频
- ✅ **指定视频封面**: 从视频中选择任意帧作为封面

## 技术栈

- **编程语言**: C++ 17
- **图形界面**: Qt 6
- **多媒体处理**: FFmpeg
- **构建系统**: CMake + vcpkg

## 系统架构

本项目采用**多线程架构**，确保界面流畅不卡顿:

- **界面线程 (主线程)**: 负责UI渲染和用户交互
- **工作线程 (后台线程)**: 负责视频解码、编码、文件处理等耗时操作

## 开发环境配置

### 1. 安装依赖

#### Windows

```powershell
# 安装 vcpkg (如果尚未安装)
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
.\bootstrap-vcpkg.bat
.\vcpkg integrate install

# 安装项目依赖
.\vcpkg install ffmpeg:x64-windows qt6-base:x64-windows qt6-multimedia:x64-windows
```

### 2. 构建项目

```powershell
# 创建构建目录
mkdir build
cd build

# 配置CMake (使用vcpkg工具链)
cmake .. -DCMAKE_TOOLCHAIN_FILE=[vcpkg根目录]/scripts/buildsystems/vcpkg.cmake

# 编译
cmake --build . --config Release

# 运行
.\bin\Release\VideoEditor.exe
```

## 使用说明

### 视频拆分

1. 点击 **"打开文件"** 按钮，选择要处理的视频文件
2. 视频加载后，左侧会显示视频详细信息
3. 点击 **"拆分视频"** 按钮
4. 选择输出目录，软件会自动生成:
   - `frames/` 文件夹: 包含所有视频帧 (JPEG格式)
   - `audio.mp3`: 提取的音频文件

### 视频合成

1. 点击 **"合成视频"** 按钮
2. 选择包含图片序列的文件夹
3. 选择音频文件
4. 选择输出路径和文件名
5. 软件会自动合成为 MP4 视频文件

### 设置封面

1. 在视频预览时，拖动进度条到想要的位置
2. 点击 **"设为封面"** 按钮
3. 封面会保存为单独的图片文件

## 项目结构

```
视频剪辑助手/
├── CMakeLists.txt          # CMake 构建配置
├── vcpkg.json              # vcpkg 依赖配置
├── README.md               # 项目说明文档
├── INSTALL.md              # 安装与配置指南
├── CONTRIBUTING.md         # 贡献指南
├── QUICK_REFERENCE.md      # 快速参考卡片
├── PROJECT_SUMMARY.md      # 项目完成总结
├── LICENSE                 # MIT 许可证
├── .gitignore              # Git 忽略配置
├── build.ps1               # Windows 构建脚本
├── run.ps1                 # Windows 运行脚本
├── .vscode/                # VS Code 配置
│   ├── tasks.json          # 构建任务
│   ├── launch.json         # 调试配置
│   ├── c_cpp_properties.json  # IntelliSense
│   └── settings.json       # 工作区设置
├── docs/                   # 文档目录
│   ├── 用户手册.md         # 用户使用手册
│   └── 开发文档.md         # 开发者文档
├── include/                # 头文件
│   ├── MainWindow.h        # 主窗口
│   ├── VideoDecoder.h      # 视频解码器
│   ├── VideoEncoder.h      # 视频编码器
│   ├── VideoProcessor.h    # 视频处理器
│   └── VideoPlayer.h       # 视频播放器
└── src/                    # 源文件
    ├── main.cpp            # 程序入口
    ├── MainWindow.cpp      # 主窗口实现
    ├── VideoDecoder.cpp    # 解码器实现
    ├── VideoEncoder.cpp    # 编码器实现
    ├── VideoProcessor.cpp  # 处理器实现
    └── VideoPlayer.cpp     # 播放器实现
```

## 开发路线图

- [x] **第一阶段**: 项目搭建与界面呈现
- [ ] **第二阶段**: 实现核心播放器
- [ ] **第三阶段**: 实现拆分与合成功能
- [ ] **第四阶段**: 功能完善与优化

## 性能优化

- 利用 **硬件加速** (GPU) 进行视频编解码
- 采用 **多线程处理**，避免UI阻塞
- 支持 **批量处理**，提高效率

## 许可证

MIT License

## 作者

视频剪辑助手开发团队
