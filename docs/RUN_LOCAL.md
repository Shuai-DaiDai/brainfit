# 🧠 BrainFit 本地运行指南（Mac）

> 无Firebase版本，所有数据存储在本地，适合网络受限环境测试

---

## 📋 前置要求

### 1. 安装 Flutter SDK

```bash
# 使用 Homebrew 安装（推荐）
brew install flutter

# 或者手动安装
# 1. 下载 Flutter SDK: https://docs.flutter.dev/get-started/install/macos
# 2. 解压到 ~/development/flutter
# 3. 添加到 PATH
```

### 2. 验证安装

```bash
flutter doctor
```

应该看到类似输出：
```
[✓] Flutter (Channel stable, 3.x.x, ...)
[✓] Android toolchain - develop for Android devices
[✓] Xcode - develop for iOS and macOS
[✓] Chrome - develop for the web
[✓] Android Studio
```

### 3. 安装 Xcode（iOS模拟器/真机测试必需）

```bash
# 从 App Store 安装 Xcode
# 或者使用命令行
xcode-select --install
```

---

## 🚀 快速开始

### 步骤 1: 进入项目目录

```bash
cd /path/to/brainfit-full
```

### 步骤 2: 安装依赖

```bash
flutter pub get
```

### 步骤 3: 选择运行入口

#### 选项 A: iOS 模拟器（推荐首次测试）

```bash
# 启动 iOS 模拟器
open -a Simulator

# 运行应用
flutter run -t lib/main_local.dart
```

#### 选项 B: macOS 桌面版（最快捷）

```bash
# 启用 macOS 桌面支持
flutter config --enable-macos-desktop

# 运行 macOS 版本
flutter run -d macos -t lib/main_local.dart
```

#### 选项 C: iOS 真机（需要配置）

```bash
# 1. 连接 iPhone 到 Mac
# 2. 在 Xcode 中配置签名（免费Apple ID即可）
# 3. 运行
flutter run -d ios -t lib/main_local.dart
```

---

## 📱 运行模式说明

### 本地模式特点

| 功能 | 本地模式 | 云端模式 |
|------|---------|---------|
| 网络连接 | ❌ 不需要 | ✅ 需要 |
| 用户登录 | ❌ 自动匿名 | ✅ 邮箱/手机 |
| 数据存储 | 📱 本地内存 | ☁️ Firestore |
| 数据持久化 | ⚠️ 退出后重置 | ✅ 永久保存 |
| 多设备同步 | ❌ 不支持 | ✅ 支持 |

### 注意事项

1. **数据不会持久化**：退出应用后所有数据会重置
2. **适合测试**：快速体验所有功能，无需配置
3. **金币重置**：每次重启应用会获得100初始金币

---

## 🔧 常见问题

### 问题 1: `flutter doctor` 显示 Xcode 未安装

```bash
# 安装 Xcode Command Line Tools
xcode-select --install

# 同意许可协议
sudo xcodebuild -license accept
```

### 问题 2: iOS 模拟器无法启动

```bash
# 打开 Xcode
open -a Xcode

# 安装模拟器
# Xcode > Preferences > Components > 安装 iOS Simulator

# 或者命令行
xcrun simctl list devices
xcrun simctl boot "iPhone 15 Pro"
```

### 问题 3: 依赖安装失败

```bash
# 清理缓存
flutter clean
flutter pub cache repair

# 重新安装
flutter pub get
```

### 问题 4: 编译错误

```bash
# 更新 Flutter
flutter upgrade

# 更新依赖
flutter pub upgrade

# 重新构建
flutter clean
flutter pub get
flutter run -t lib/main_local.dart
```

### 问题 5: macOS 桌面版显示异常

```bash
# 调整窗口大小
# 应用支持响应式布局，可以调整窗口大小查看效果

# 或者强制指定尺寸
flutter run -d macos --dart-define=FLUTTER_WEB_MAXIMUM_SURFACES=1
```

---

## 🎮 测试功能清单

### L1 急救层
- [ ] 共振呼吸（动画 + 引导）
- [ ] 循环叹息（快速减压）
- [ ] 4-7-8呼吸（助眠）
- [ ] 箱式呼吸（专注）

### L2 修复层
- [ ] 正念冥想（计时 + 铃声）

### L3 强化层
- [ ] Dual N-back（游戏）
- [ ] 脑力年龄测试

### 游戏化
- [ ] 连续打卡（Streak）
- [ ] 神经元币（奖励系统）
- [ ] 成就解锁
- [ ] 神经网络可视化

---

## 🛠️ 开发调试

### 热重载（Hot Reload）

```bash
# 在运行过程中修改代码后
# 按 r 键 - 热重载（保持状态）
# 按 R 键 - 热重启（重置状态）
# 按 q 键 - 退出
```

### 性能分析

```bash
# 性能模式运行
flutter run --profile -t lib/main_local.dart

# 发布模式测试
flutter run --release -t lib/main_local.dart
```

### 查看日志

```bash
# 带日志运行
flutter run -t lib/main_local.dart --verbose

# 只看错误
flutter run -t lib/main_local.dart 2>&1 | grep -i error
```

---

## 📦 构建发布版本

### iOS 发布包（需要开发者账号）

```bash
cd ios
pod install
cd ..

# 构建
flutter build ios --release

# 在 Xcode 中 Archive
# open ios/Runner.xcworkspace
```

### Android 发布包

```bash
# 构建 APK
flutter build apk --release

# 构建 AAB（Google Play）
flutter build appbundle --release
```

---

## 🔄 切换到云端版本

如果需要测试 Firebase 功能，切换回主入口：

```bash
# 使用默认入口（需要配置 Firebase）
flutter run

# 或者显式指定
flutter run -t lib/main.dart
```

---

## 🆘 获取帮助

1. **Flutter 官方文档**: https://docs.flutter.dev
2. **iOS 部署指南**: https://docs.flutter.dev/deployment/ios
3. **查看日志**: `flutter doctor -v`

---

**版本**: v1.0.0-local  
**更新日期**: 2026-02-21  
**作者**: 帅小呆1号
