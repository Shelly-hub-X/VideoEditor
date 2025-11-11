# 视频剪辑助手 打包和测试指南

## 快速打包 (3步)

### 方法 1: 使用 PowerShell 脚本 (推荐)

```powershell
# 打开 PowerShell 并执行
cd "C:\Users\Administrator\Desktop\视频剪辑助手"
.\package.ps1
```

**特点**:
- 速度快
- 显示进度
- 自动创建压缩包
- 颜色输出便于查看

### 方法 2: 使用 Batch 脚本

```batch
# 双击运行 package.bat
# 或在 cmd 中执行
cd "C:\Users\Administrator\Desktop\视频剪辑助手"
package.bat
```

---

## 打包步骤详解

### 第一步: 确保已编译

```powershell
# 如果还没有编译,先运行构建脚本
.\build.ps1
```

### 第二步: 设置环境变量 (可选但推荐)

```powershell
# 设置 VCPKG_ROOT (这样打包脚本才能找到 FFmpeg DLL)
[System.Environment]::SetEnvironmentVariable('VCPKG_ROOT', 'C:\vcpkg', 'User')

# 新开 PowerShell 窗口使环境变量生效
```

### 第三步: 运行打包脚本

```powershell
.\package.ps1
```

**打包脚本会自动完成以下操作**:

1. ✅ 检查可执行文件
2. ✅ 创建 `release\VideoEditor\` 文件夹
3. ✅ 复制 VideoEditor.exe
4. ✅ 运行 windeployqt 部署 Qt DLL
5. ✅ 复制 FFmpeg DLL
6. ✅ 复制文档文件
7. ✅ 创建压缩包

---

## 打包后的文件结构

```
release/
├── VideoEditor/                          # 可独立运行文件夹
│   ├── VideoEditor.exe                   # 主程序
│   ├── Qt6Core.dll                       # Qt 核心库
│   ├── Qt6Gui.dll                        # Qt GUI 库
│   ├── Qt6Widgets.dll                    # Qt 部件库
│   ├── Qt6Multimedia.dll                 # Qt 多媒体库
│   ├── plugins/                          # Qt 插件
│   │   ├── imageformats/
│   │   ├── platforms/
│   │   └── ...
│   ├── avcodec-61.dll                    # FFmpeg 编解码库
│   ├── avformat-61.dll                   # FFmpeg 格式库
│   ├── avutil-59.dll                     # FFmpeg 工具库
│   ├── swscale-8.dll                     # FFmpeg 图像处理库
│   ├── swresample-5.dll                  # FFmpeg 音频处理库
│   ├── README.md                         # 说明文档
│   ├── README_CN.txt                     # 中文说明
│   ├── QUICK_REFERENCE.md                # 快速参考
│   └── LICENSE                           # 许可证
│
└── VideoEditor-v1.0.0-Windows-x64.zip    # 压缩包 (可选)
    └── (包含上述所有文件的压缩版本)
```

---

## 测试方法

### 方法 A: 在原电脑上测试

1. 打开 `release\VideoEditor\` 文件夹
2. 双击 `VideoEditor.exe`
3. 程序应该直接启动

### 方法 B: 复制到其他位置测试

```powershell
# 测试程序是否真的独立
# 方法1: 复制到桌面
Copy-Item -Path "release\VideoEditor" -Destination "$env:USERPROFILE\Desktop\VideoEditor_Test" -Recurse

# 方法2: 复制到其他盘符
Copy-Item -Path "release\VideoEditor" -Destination "E:\VideoEditor_Test" -Recurse

# 然后双击运行
```

### 方法 C: 在其他电脑上测试

1. 将 `release\VideoEditor` 文件夹复制到其他 Windows 电脑
2. 双击 `VideoEditor.exe` 测试
3. 应该能直接运行,无需任何依赖安装

---

## 测试检查清单

### 启动测试

- [ ] 双击 exe 能否直接启动?
- [ ] 是否显示主窗口?
- [ ] 界面布局是否正确?
- [ ] 所有按钮是否可见?

### 功能测试

- [ ] 能否打开视频文件?
- [ ] 视频信息是否正确显示?
- [ ] 能否播放视频?
- [ ] 进度条是否可拖动?
- [ ] 能否拆分视频?
- [ ] 能否合成视频?
- [ ] 能否设置封面?

### 依赖测试

- [ ] 是否缺少任何 DLL?
- [ ] 是否有运行时错误?
- [ ] 程序是否能正常关闭?

---

## 常见问题

### Q1: 打包后程序无法启动

**症状**: 双击 exe 没反应

**解决**:
```powershell
# 确保 Qt DLL 已正确部署
# 检查是否有 Qt6Core.dll 等文件

# 查看详细错误
# 在 cmd 中运行
cd release\VideoEditor
VideoEditor.exe

# 会显示具体错误信息
```

### Q2: 缺少 FFmpeg DLL

**症状**: 程序启动但打开视频失败

**解决**:
```powershell
# 手动复制 FFmpeg DLL
$ffmpegPath = "C:\vcpkg\installed\x64-windows\bin"
Copy-Item "$ffmpegPath\av*.dll" "release\VideoEditor\" -Force
Copy-Item "$ffmpegPath\sw*.dll" "release\VideoEditor\" -Force
```

### Q3: 程序包太大

**症状**: 文件夹超过 500MB

**解决**:
```powershell
# 只保留必需的文件,删除以下可选文件:
# - plugins/ 中的 tls 文件夹
# - 不需要的平台插件
# - 调试符号 (.pdb 文件)
```

---

## 优化打包

### 减小文件大小

```powershell
# 删除不必要的文件
Remove-Item "release\VideoEditor\*.pdb" -Force
Remove-Item "release\VideoEditor\plugins\tls" -Recurse -Force

# 保留必需的平台插件
Get-ChildItem "release\VideoEditor\plugins\platforms\*" | 
    Where-Object {$_.Name -notmatch "qwindows"} | 
    Remove-Item -Force
```

### 创建专业的安装程序

推荐使用 NSIS (Nullsoft Scriptable Install System):

```nsis
; example-installer.nsi
!include "MUI2.nsh"

; 基本设置
Name "视频剪辑助手 v1.0"
OutFile "VideoEditor-Setup-v1.0.exe"
InstallDir "$PROGRAMFILES\VideoEditor"

; 页面
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "SimpChinese"

; 安装文件
Section "Install"
    SetOutPath "$INSTDIR"
    File /r "release\VideoEditor\*.*"
    
    ; 创建开始菜单快捷方式
    CreateDirectory "$SMPROGRAMS\VideoEditor"
    CreateShortCut "$SMPROGRAMS\VideoEditor\VideoEditor.lnk" "$INSTDIR\VideoEditor.exe"
    CreateShortCut "$DESKTOP\VideoEditor.lnk" "$INSTDIR\VideoEditor.exe"
SectionEnd

; 卸载
Section "Uninstall"
    RMDir /r "$INSTDIR"
    RMDir /r "$SMPROGRAMS\VideoEditor"
    Delete "$DESKTOP\VideoEditor.lnk"
SectionEnd
```

---

## 分发和部署

### 方式 1: 直接分发文件夹

```powershell
# 用户只需解压并运行
# 优点: 简单,无需安装
# 缺点: 需要手动管理,无卸载功能
```

### 方式 2: 分发压缩包

```powershell
# 上传 VideoEditor-v1.0.0-Windows-x64.zip
# 用户下载后解压运行
# 优点: 便于传输和备份
# 缺点: 解压后仍需手动管理
```

### 方式 3: 创建安装程序

```powershell
# 使用 NSIS 或 WiX 创建 .msi 或 .exe 安装程序
# 优点: 专业,支持卸载,可配置安装位置
# 缺点: 需要学习安装程序创建工具
```

---

## 版本更新

### 发布新版本

```powershell
# 1. 更新版本号
# - 修改 CMakeLists.txt 中的 VERSION
# - 更新 docs 中的版本号

# 2. 重新编译
.\build.ps1

# 3. 重新打包
.\package.ps1

# 4. 创建发布
# - 生成 release notes
# - 上传到 GitHub/网站
```

---

## 最佳实践

✅ **打包前**:
- 确保程序已在 Release 模式编译
- 进行完整的功能测试
- 检查所有依赖是否完整

✅ **打包中**:
- 使用自动化脚本 (package.ps1)
- 验证文件完整性
- 创建版本化的压缩包

✅ **打包后**:
- 在不同电脑上测试
- 检查缺失的 DLL
- 创建发布说明

---

## 命令快速参考

```powershell
# 一键构建和打包
.\build.ps1 ; .\package.ps1

# 只打包 (需要已编译)
.\package.ps1

# 打包并打开文件夹
.\package.ps1 -OpenFolder

# 打包不创建 zip
.\package.ps1 -CreateZip:$false
```

---

**现在您可以轻松打包和分发程序了!** 🎉

有任何问题,请参考 [INSTALL.md](INSTALL.md) 和 [docs/开发文档.md](docs/开发文档.md)。
