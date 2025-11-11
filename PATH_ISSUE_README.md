# 项目路径问题说明 (Project Path Issue)

## 问题 (Problem)

Qt 编译失败,错误原因:
**项目路径包含中文字符 "视频剪辑助手",导致 vcpkg 编译 Qt 时无法正确处理路径。**

链接器错误显示:
```
LINK : fatal error LNK1104: 无法打开文件"C:\Users\Administrator\Desktop\瑙嗛鍓緫鍔╂墜\vcpkg_installed\x64-windows\debug\lib\icuind.lib"
```

中文字符被编码为乱码:"瑙嗛鍓緫鍔╂墜" (应该是 "视频剪辑助手")

## 解决方案 (Solution)

**必须将项目移动到只包含英文字符的路径。**

### 方法 1: 使用迁移脚本 (推荐)

在当前目录运行:

```powershell
.\MOVE_PROJECT.ps1
```

脚本会:
1. 提示选择目标路径 (如 `C:\VideoEditor`)
2. 复制所有项目文件(除了 vcpkg_installed 文件夹)
3. 显示后续步骤

### 方法 2: 手动迁移

1. **创建新文件夹** (只用英文命名):
   ```powershell
   New-Item -ItemType Directory -Path "C:\VideoEditor" -Force
   ```

2. **复制项目文件** (排除 vcpkg_installed):
   ```powershell
   $source = "C:\Users\Administrator\Desktop\视频剪辑助手"
   $target = "C:\VideoEditor"
   
   Get-ChildItem -Path $source | Where-Object { $_.Name -ne "vcpkg_installed" } | 
       ForEach-Object { Copy-Item -Path $_.FullName -Destination $target -Recurse -Force }
   ```

3. **在新位置安装 Qt**:
   ```powershell
   cd C:\VideoEditor
   D:\videoeditor-env\vcpkg\vcpkg.exe install
   ```

4. **构建项目**:
   ```powershell
   .\build_and_package.ps1
   ```

## 为什么要这样做?

- vcpkg 的 CMake 构建系统在处理路径时使用 ASCII 编码
- 中文字符在编译过程中会被错误编码
- 导致链接器无法找到库文件
- 这是 vcpkg 的已知限制,无法通过其他方式解决

## 已安装的工具状态

✅ 以下工具已成功安装到 `D:\videoeditor-env`:
- CMake 4.1.2
- Git 2.51.2
- Visual Studio Build Tools 2022 (MSVC 14.44)
- PowerShell 7.5.4
- vcpkg
- FFmpeg 7.1.2

⏳ 需要重新安装 (在新路径):
- Qt 6.9.1 (qtbase 和 qtmultimedia)

## 预计时间

- 复制文件: 2-5 分钟
- Qt 编译: 30-60 分钟
- 项目构建: 5-10 分钟

## 注意事项

1. **不要**复制 `vcpkg_installed` 文件夹 - 它包含错误路径的引用
2. Qt 需要在新位置重新编译
3. 所有其他工具 (D:\videoeditor-env) 不需要重新安装
4. 迁移后可以删除桌面上的旧文件夹
