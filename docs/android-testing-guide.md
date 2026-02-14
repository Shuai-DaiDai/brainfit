# Android 真机测试指南

## 准备工作

### 需要的设备
- [ ] Android 手机（Android 5.0+）
- [ ] USB 数据线
- [ ] 电脑（Mac/Windows/Linux 都可以）

---

## 步骤 1：下载代码

```bash
# 克隆代码
git clone https://github.com/Shuai-DaiDai/brainfit.git
cd brainfit
```

---

## 步骤 2：安装依赖

```bash
# 安装 Flutter 依赖
flutter pub get
```

---

## 步骤 3：连接 Android 手机

### 3.1 开启开发者模式

```
手机设置 → 关于手机 → 版本号
连续点击 7 次 → 提示"您已处于开发者模式"
```

### 3.2 开启 USB 调试

```
设置 → 系统 → 开发者选项
    ↓
开启「USB 调试」
    ↓
连接 USB 线到电脑
    ↓
手机弹出「允许 USB 调试？」→ 点击「确定」
```

### 3.3 验证连接

```bash
# 检查设备是否连接
flutter devices

# 应该显示类似：
# SM G973N (mobile) • R39M30... • android-arm64 • Android 12 (API 31)
```

---

## 步骤 4：运行应用

```bash
# 直接运行
flutter run

# 或者指定设备
flutter run -d android

# 发布模式运行（更快）
flutter run --release
```

首次运行会自动编译 APK 并安装到手机。

---

## 常见问题

### ❌ 问题 1："flutter: command not found"
**解决：**
```bash
# 确保 Flutter 已添加到 PATH
export PATH="$PATH:/Users/您的用户名/flutter/bin"

# 或者检查 Flutter 安装
which flutter
flutter --version
```

### ❌ 问题 2："No devices found"
**解决：**
```bash
# 检查设备连接
adb devices

# 如果没有显示设备：
# 1. 重新插拔 USB
# 2. 更换 USB 线
# 3. 检查是否允许 USB 调试
```

### ❌ 问题 3："Gradle build failed"
**解决：**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### ❌ 问题 4：Firebase 初始化失败
**解决：**
1. 检查 `android/app/google-services.json` 是否存在
2. 检查包名是否为 `com.brainfit.app`
3. 在 Firebase Console 检查 Android 应用配置

### ❌ 问题 5：安装失败"INSTALL_FAILED_UPDATE_INCOMPATIBLE"
**解决：**
```bash
# 卸载旧版本
adb uninstall com.brainfit.app

# 重新运行
flutter run
```

---

## 快速命令总结

```bash
# 完整流程
cd ~/brainfit
git pull
flutter clean
flutter pub get
flutter run

# 只重新运行（不重新编译）
flutter run --hot

# 停止应用（终端中按）
# r → 热重载
# R → 热重启
# q → 退出
```

---

## 测试功能

应用启动后测试：

### 1. 匿名登录
- 点击「游客登录」或「立即体验」
- 无需输入任何信息

### 2. 手机号登录
- 输入：`+86 15001005686`
- 验证码：`123456`
- 登录成功

### 3. 测试主要功能
- ✅ 脑力年龄测试
- ✅ 呼吸练习（4种）
- ✅ 正念冥想
- ✅ Dual N-back
- ✅ 连续打卡
- ✅ 奖励系统

---

## 每次重新测试

```bash
cd ~/brainfit

# 更新代码（如果有更新）
git pull

# 重新运行
flutter run
```

---

## 需要帮助？

如果遇到问题：
1. 截图终端的错误信息
2. 或截图手机上的提示
3. 发给我帮您解决

**比 iOS 简单多了，不需要 Apple ID！** 🎉
