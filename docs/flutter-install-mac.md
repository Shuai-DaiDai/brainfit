# Flutter 安装指南 (Mac)

## 步骤 1：下载 Flutter SDK

```bash
# 下载 Flutter（稳定版）
cd ~/Downloads
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip

# 解压
unzip flutter_macos_3.16.0-stable.zip

# 移动到合适位置
mv flutter ~/development/
```

## 步骤 2：添加到 PATH

```bash
# 编辑 zsh 配置文件
nano ~/.zshrc

# 添加这行到文件末尾
export PATH="$PATH:$HOME/development/flutter/bin"

# 保存（按 Ctrl+X，然后 Y，然后回车）
```

## 步骤 3：刷新配置

```bash
source ~/.zshrc
```

## 步骤 4：验证安装

```bash
flutter --version
```

应该显示类似：
```
Flutter 3.16.0 • channel stable • https://github.com/flutter/flutter.git
Framework • revision ...
Engine • revision ...
Tools • Dart 3.2.0 • DevTools 2.28.2
```

## 步骤 5：安装 Xcode（iOS 必需）

```bash
# 从 App Store 安装 Xcode
# 或者命令行
xcode-select --install
```

## 步骤 6：运行 Flutter 诊断

```bash
flutter doctor
```

根据提示安装缺失的依赖（主要是 Android Studio 或 Xcode）。

---

## 快捷安装脚本

```bash
# 一键安装（复制粘贴到终端执行）
cd ~ && \
mkdir -p development && \
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.16.0-stable.zip && \
unzip -q flutter_macos_3.16.0-stable.zip -d development/ && \
rm flutter_macos_3.16.0-stable.zip && \
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc && \
source ~/.zshrc && \
flutter --version
```

等待几分钟，安装完成后即可使用！

---

## 验证 Flutter 安装

```bash
# 检查 Flutter
which flutter
flutter --version

# 检查 Dart（随 Flutter 一起安装）
which dart
dart --version
```

---

安装完成后就可以运行 BrainFit 了！🎉
