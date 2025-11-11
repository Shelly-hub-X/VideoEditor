# 贡献指南

首先,感谢您考虑为视频剪辑助手做出贡献! 正是像您这样的人让这个项目变得更好。

## 行为准则

参与本项目即表示您同意遵守我们的行为准则:

- 尊重所有贡献者
- 接受建设性批评
- 专注于对社区最有利的事情
- 对其他社区成员表现出同理心

## 我能如何贡献?

### 报告 Bug

在提交 Bug 报告之前:

1. **检查文档** - 确保这不是预期行为
2. **搜索现有 Issues** - 避免重复报告
3. **尝试最新版本** - Bug 可能已被修复

提交 Bug 时,请包含:

- **清晰的标题和描述**
- **重现步骤** (越详细越好)
- **预期行为** vs **实际行为**
- **截图** (如果适用)
- **系统信息**:
  - 操作系统版本
  - Qt 版本
  - FFmpeg 版本
  - 编译器版本

**Bug 报告模板**:

```markdown
### 问题描述
简要描述遇到的问题

### 重现步骤
1. 打开软件
2. 点击 "拆分视频"
3. 选择文件 "test.mp4"
4. 观察错误

### 预期行为
应该显示拆分进度

### 实际行为
程序崩溃,显示错误消息 "..."

### 系统信息
- OS: Windows 11 22H2
- Qt: 6.5.0
- FFmpeg: 5.1.2
- Compiler: MSVC 2022

### 附加信息
添加任何其他相关信息或截图
```

---

### 建议新功能

我们欢迎新功能建议! 请:

1. **先搜索现有 Issues** - 可能已有类似建议
2. **清晰描述功能** - 包括使用场景
3. **解释为什么需要** - 帮助我们理解价值

**功能请求模板**:

```markdown
### 功能描述
清晰简洁地描述您想要的功能

### 问题场景
描述这个功能解决什么问题
例如: "我总是需要...,但是..."

### 建议的解决方案
描述您希望如何实现这个功能

### 替代方案
描述您考虑过的其他方案

### 附加信息
添加任何其他相关信息或截图
```

---

### 提交代码

#### 开发流程

1. **Fork 仓库**
   ```bash
   # 在 GitHub 上点击 Fork 按钮
   ```

2. **克隆您的 Fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/视频剪辑助手.git
   cd 视频剪辑助手
   ```

3. **添加上游仓库**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/视频剪辑助手.git
   ```

4. **创建特性分支**
   ```bash
   git checkout -b feature/amazing-feature
   ```

5. **进行更改**
   - 遵循代码风格指南
   - 添加必要的测试
   - 更新相关文档

6. **提交更改**
   ```bash
   git add .
   git commit -m "feat: 添加惊人的新功能"
   ```

7. **保持同步**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

8. **推送到您的 Fork**
   ```bash
   git push origin feature/amazing-feature
   ```

9. **创建 Pull Request**
   - 在 GitHub 上打开 PR
   - 填写 PR 模板
   - 等待代码审查

---

## 代码风格指南

### C++ 代码规范

#### 命名约定

```cpp
// 类名: 大驼峰 (PascalCase)
class VideoPlayer { };

// 成员变量: m_ 前缀 + 小驼峰
class MyClass {
private:
    int m_memberVariable;
    QString m_filePath;
};

// 函数/方法: 小驼峰 (camelCase)
void processVideo();
bool isPlaying() const;

// 常量: 全大写 + 下划线
const int MAX_BUFFER_SIZE = 1024;
constexpr double PI = 3.14159;

// 宏: 全大写 + 下划线 (尽量避免使用)
#define VIDEO_EDITOR_VERSION "1.0.0"
```

#### 格式化

```cpp
// 缩进: 4 个空格 (不使用 Tab)
if (condition) {
    doSomething();
}

// 大括号: K&R 风格
void function()
{
    // 函数体
}

// if/for 后总是使用大括号
if (condition) {
    statement;
}

// 不要这样:
if (condition) statement;

// 指针和引用: 类型靠左
int* ptr;
const QString& str;

// 每行一个声明
int x;
int y;

// 不要这样:
int x, y;
```

#### 注释

```cpp
/**
 * @brief 视频播放器类
 * 
 * 负责在后台线程中解码视频并发送帧到 UI 线程
 * 
 * @note 线程安全
 */
class VideoPlayer : public QObject
{
    // ...
};

// 公共 API 必须有文档注释
/**
 * @brief 打开视频文件
 * @param filePath 视频文件的完整路径
 * @return 成功返回 true,失败返回 false
 */
bool openFile(const QString &filePath);

// 复杂逻辑添加解释性注释
// 计算视频总帧数: 时长(秒) × 帧率
m_totalFrames = (m_duration / 1000.0) * m_frameRate;
```

#### 资源管理

```cpp
// 优先使用智能指针
std::unique_ptr<VideoPlayer> player;
std::shared_ptr<AVFrame> frame;

// RAII 原则
class ResourceManager {
public:
    ResourceManager() {
        // 获取资源
        m_resource = allocateResource();
    }
    
    ~ResourceManager() {
        // 释放资源
        freeResource(m_resource);
    }
    
    // 禁止复制
    ResourceManager(const ResourceManager&) = delete;
    ResourceManager& operator=(const ResourceManager&) = delete;
};

// FFmpeg 资源管理示例
AVPacket* packet = av_packet_alloc();
// ... 使用 packet ...
av_packet_free(&packet);  // 总是配对释放
```

---

### Git 提交规范

使用 [Conventional Commits](https://www.conventionalcommits.org/) 格式:

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Type (必需)

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档更新
- `style`: 代码格式调整 (不影响功能)
- `refactor`: 代码重构
- `perf`: 性能优化
- `test`: 添加测试
- `chore`: 构建/工具链更新

#### 示例

```bash
# 简单提交
git commit -m "feat: 添加批量处理功能"
git commit -m "fix: 修复进度条不更新的问题"

# 详细提交
git commit -m "feat(encoder): 添加硬件加速支持

- 支持 NVIDIA NVENC
- 支持 Intel Quick Sync
- 自动回退到软件编码

Closes #123"
```

---

## Pull Request 流程

### PR 检查清单

提交 PR 前,请确保:

- [ ] 代码符合项目风格指南
- [ ] 所有测试通过
- [ ] 添加了必要的文档
- [ ] 更新了 CHANGELOG (如果适用)
- [ ] PR 描述清晰,引用相关 Issue
- [ ] 没有合并冲突

### PR 模板

```markdown
## 变更类型
- [ ] Bug 修复
- [ ] 新功能
- [ ] 重大变更
- [ ] 文档更新

## 描述
清晰简洁地描述这个 PR 做了什么

## 相关 Issue
修复 #(issue编号)

## 测试
描述如何测试您的更改

## 截图 (如果适用)
添加相关截图

## 检查清单
- [ ] 代码符合项目风格
- [ ] 自测通过
- [ ] 更新了文档
- [ ] 没有引入新警告
```

---

## 开发环境设置

### 必需工具

1. **C++ 编译器**
   - Windows: Visual Studio 2019/2022
   - Linux: GCC 9+ 或 Clang 10+
   - macOS: Xcode 12+

2. **CMake** (>= 3.20)
3. **Qt 6** (>= 6.2)
4. **vcpkg** (包管理器)

### 快速开始

```bash
# 1. 安装依赖
cd vcpkg
./vcpkg install ffmpeg qt6-base qt6-multimedia

# 2. 克隆仓库
git clone <repo_url>
cd 视频剪辑助手

# 3. 构建
mkdir build && cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=[vcpkg_root]/scripts/buildsystems/vcpkg.cmake
cmake --build .

# 4. 运行测试
ctest

# 5. 运行程序
./bin/VideoEditor
```

详细说明见 [INSTALL.md](INSTALL.md)

---

## 文档贡献

文档改进同样重要! 您可以:

- 修正拼写/语法错误
- 改进解释说明
- 添加示例代码
- 翻译文档

文档位置:
- `README.md` - 项目介绍
- `docs/用户手册.md` - 用户文档
- `docs/开发文档.md` - 开发者文档
- 代码中的注释

---

## 测试

### 运行测试

```bash
# 构建测试
cmake --build build --target tests

# 运行所有测试
cd build
ctest

# 运行特定测试
ctest -R VideoPlayerTest
```

### 编写测试

我们使用 Qt Test 框架:

```cpp
#include <QtTest/QtTest>
#include "VideoPlayer.h"

class VideoPlayerTest : public QObject
{
    Q_OBJECT

private slots:
    void testOpenFile();
    void testPlayPause();
};

void VideoPlayerTest::testOpenFile()
{
    VideoPlayer player;
    QVERIFY(player.openFile("test.mp4"));
    QCOMPARE(player.isPlaying(), false);
}

QTEST_MAIN(VideoPlayerTest)
#include "VideoPlayerTest.moc"
```

---

## 版本发布

维护者使用语义化版本 (SemVer):

- `MAJOR.MINOR.PATCH`
- `MAJOR`: 不兼容的 API 变更
- `MINOR`: 向后兼容的功能添加
- `PATCH`: 向后兼容的 Bug 修复

---

## 获得帮助

如果您有疑问:

1. **查看文档** - 大多数问题都有文档
2. **搜索 Issues** - 可能已有答案
3. **提问** - 在 Discussions 中提问
4. **联系维护者** - 发送邮件

---

## 致谢

所有贡献者都会在 [CONTRIBUTORS.md](CONTRIBUTORS.md) 中列出。

感谢您让这个项目变得更好! ❤️

---

## 许可证

贡献的代码将采用与项目相同的 MIT 许可证。

提交 PR 即表示您同意在 MIT 许可下发布您的贡献。
