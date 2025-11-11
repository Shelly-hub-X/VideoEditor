# 📦 视频剪辑助手 打包使用指南

## ⚡ 快速打包 (一键完成)

### 最简单的方法 - 双击即可

在项目根目录找到这两个脚本之一,双击运行:

#### 方法 1️⃣: 使用 Batch 脚本 (适合初学者)
```
build_and_package.bat
```
双击运行 → 等待完成 → done!

#### 方法 2️⃣: 使用 PowerShell 脚本 (推荐)
```powershell
.\build_and_package.ps1
```

---

## 📋 打包流程 (自动完成)

脚本会自动执行以下步骤:

```
1️⃣  编译项目
    ├─ CMake 配置
    ├─ Visual Studio 编译
    └─ 生成 Release 版本 exe

2️⃣  打包程序
    ├─ 复制可执行文件
    ├─ 部署 Qt 依赖库
    ├─ 复制 FFmpeg 依赖库
    ├─ 复制文档文件
    ├─ 创建压缩包
    └─ 完成!

⏱️  总耗时: 10-15 分钟 (首次编译)
```

---

## 📁 打包结果

打包完成后,您会得到:

### 1. 可直接运行的文件夹

```
release/VideoEditor/
├── VideoEditor.exe              ← 双击运行这个!
├── Qt6Core.dll
├── Qt6Gui.dll
├── Qt6Widgets.dll
├── Qt6Multimedia.dll
├── plugins/                     (Qt 插件)
├── avcodec-61.dll
├── avformat-61.dll
├── avutil-59.dll
├── swscale-8.dll
├── swresample-5.dll
├── README_CN.txt                (中文说明)
├── README.md
├── QUICK_REFERENCE.md
└── LICENSE
```

### 2. 压缩包 (可选)

```
release/VideoEditor-v1.0.0-Windows-x64.zip
```

用于分发或备份

---

## 🚀 运行程序

### 方式 1: 直接运行 exe

```
1. 打开 release\VideoEditor\ 文件夹
2. 双击 VideoEditor.exe
3. 程序启动!
```

### 方式 2: 从命令行运行

```powershell
# 进入文件夹
cd release\VideoEditor

# 运行程序
.\VideoEditor.exe
```

### 方式 3: 复制到其他位置运行

```powershell
# 复制整个文件夹到其他位置
Copy-Item -Path "release\VideoEditor" -Destination "E:\VideoEditor" -Recurse

# 在新位置双击 exe 运行
# 程序仍然能正常工作 (因为包含了所有依赖)
```

---

## ✅ 验证打包成功

### 检查清单

- [ ] `release/VideoEditor/VideoEditor.exe` 存在?
- [ ] `release/VideoEditor/Qt6*.dll` 存在?
- [ ] `release/VideoEditor/av*.dll` 存在?
- [ ] 双击 exe 能否启动程序?
- [ ] 程序主窗口能否正常显示?

---

## 🎯 常见场景

### 场景 1: 在本电脑测试

```powershell
# 一键打包
.\build_and_package.ps1

# 打开文件夹
start release\VideoEditor

# 双击 VideoEditor.exe 测试
```

### 场景 2: 分发给朋友

```powershell
# 打包
.\build_and_package.ps1

# 发送压缩包给朋友
# release\VideoEditor-v1.0.0-Windows-x64.zip

# 朋友接收后:
# 1. 解压压缩包
# 2. 打开 VideoEditor 文件夹
# 3. 双击 VideoEditor.exe 运行
```

### 场景 3: 更新版本

```powershell
# 1. 修改代码
# 2. 一键打包 (会自动清理旧版本)
.\build_and_package.ps1

# 3. 新版本准备好
# release\VideoEditor-v1.0.0-Windows-x64.zip (new version)
```

---

## 🔧 进阶选项

### 只打包,不重新编译

如果您只想更新打包 (代码没有改变):

```powershell
# 使用 -SkipBuild 参数
.\build_and_package.ps1 -SkipBuild
```

### 只编译,不打包

```powershell
.\build.ps1
```

### 只打包,不创建 zip

```powershell
.\package.ps1 -CreateZip:$false
```

---

## 📊 文件大小参考

| 项目 | 大小 |
|------|------|
| VideoEditor.exe | ~100 KB |
| Qt 库 | ~100 MB |
| FFmpeg 库 | ~150 MB |
| **总计文件夹** | **~250 MB** |
| **压缩后 .zip** | **~80 MB** |

---

## 🐛 常见问题

### Q: 打包后无法运行?

**检查步骤**:
```powershell
# 1. 进入打包目录
cd release\VideoEditor

# 2. 尝试运行,查看错误
.\VideoEditor.exe

# 3. 检查是否缺少 DLL
# 打开 cmd
dumpbin /imports VideoEditor.exe | grep "dll"
```

### Q: 缺少 FFmpeg DLL?

**解决**:
```powershell
# 确保设置了 VCPKG_ROOT 环境变量
$env:VCPKG_ROOT = "C:\vcpkg"

# 重新打包
.\package.ps1
```

### Q: 在其他电脑运行出错?

**可能原因**:
- 缺少 Visual C++ Runtime
- 缺少 FFmpeg DLL

**解决**:
```powershell
# 重新打包时确保包含了所有依赖
# 可以运行
.\build_and_package.ps1

# 然后检查 release\VideoEditor\ 中的 dll 数量
ls release\VideoEditor\*.dll | measure
```

---

## 🎁 额外信息

### 打包后的程序可以做什么?

✅ 在 Windows 10/11 上直接运行  
✅ 复制到 U 盘或移动硬盘  
✅ 发送给其他人使用  
✅ 上传到网站分发  
✅ 创建安装程序 (使用 NSIS)  
✅ 用于企业部署  

### 系统要求

运行打包后的程序需要:
- Windows 10/11 64位
- 4GB 内存
- 250MB 磁盘空间 (文件夹)

---

## 📝 脚本说明

### build_and_package.bat

- **用途**: 一键编译和打包 (Batch 脚本)
- **双击运行**: 即可
- **适合**: 不熟悉命令行的用户

### build_and_package.ps1

- **用途**: 一键编译和打包 (PowerShell 脚本)
- **运行**: `.\build_and_package.ps1`
- **优点**: 更好的输出格式,支持高级选项

### package.ps1

- **用途**: 仅打包 (PowerShell 脚本)
- **用法**: `.\package.ps1`
- **何时使用**: 代码没改,只想重新打包

### package.bat

- **用途**: 仅打包 (Batch 脚本)
- **双击运行**: 即可
- **何时使用**: 代码没改,只想重新打包

---

## 🎓 工作原理

### 打包脚本做了什么?

```powershell
# 1. 检查编译产物
if (Test-Path "build\bin\Release\VideoEditor.exe") {
    # 2. 创建文件夹
    mkdir release\VideoEditor
    
    # 3. 复制 exe
    Copy-Item "build\bin\Release\VideoEditor.exe" ...
    
    # 4. 部署 Qt DLL
    windeployqt.exe VideoEditor.exe --release
    
    # 5. 复制 FFmpeg DLL
    Copy-Item "$VCPKG_ROOT\installed\x64-windows\bin\*.dll" ...
    
    # 6. 复制文档
    Copy-Item "README.md", "LICENSE", ... ...
    
    # 7. 创建压缩包
    Compress-Archive -Path VideoEditor ...
}
```

---

## 💡 最佳实践

### ✅ 打包前

- [ ] 测试程序功能是否正常
- [ ] 确保没有编译错误
- [ ] 更新版本号

### ✅ 打包中

- [ ] 使用自动化脚本
- [ ] 监看输出是否有错误
- [ ] 不要中断脚本

### ✅ 打包后

- [ ] 在本电脑测试
- [ ] 复制到其他位置再测试
- [ ] 创建备份

---

## 🚀 下一步

### 如果想分发程序:

1. 📦 使用 `release\VideoEditor-v1.0.0-Windows-x64.zip` 分发
2. 📝 创建使用说明 (README_CN.txt 已包含)
3. 🌐 上传到网站或分享给用户

### 如果想继续开发:

1. 💻 修改源代码
2. 🔨 重新运行 `.\build_and_package.ps1`
3. ✅ 新版本准备好

### 如果遇到问题:

1. 📖 查看 [PACKAGING_GUIDE.md](PACKAGING_GUIDE.md) 详细文档
2. 🔍 检查 [INSTALL.md](INSTALL.md) 安装指南
3. 💬 参考 [docs/开发文档.md](docs/开发文档.md)

---

## 📞 支持

有问题? 检查以下文件:

- **[PACKAGING_GUIDE.md](PACKAGING_GUIDE.md)** - 详细打包指南
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - 快速参考
- **[INSTALL.md](INSTALL.md)** - 安装问题
- **[docs/开发文档.md](docs/开发文档.md)** - 技术问题

---

**现在您已经可以打包和分发程序了!** 🎉

**祝您使用愉快！** 🚀
