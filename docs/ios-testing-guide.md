# iOS 真机测试指南

## 准备工作

### 需要的设备/账号
- [ ] Mac 电脑（必须，iOS 开发只能在 Mac 上进行）
- [ ] iPhone（老爷您的手机）
- [ ] USB 数据线
- [ ] Apple ID（免费账号即可，不需要付费开发者账号）

---

## 方法一：最简单（使用 Xcode）

### 步骤 1：在 Mac 上打开项目

```bash
# 进入项目目录
cd ~/brainfit/projects/brainfit

# 打开 iOS 项目
open ios/Runner.xcworkspace
# 注意：是 .xcworkspace 不是 .xcodeproj
```

### 步骤 2：连接 iPhone

1. 用 USB 线将 iPhone 连接到 Mac
2. 在 iPhone 上点击「信任此电脑」
3. 解锁 iPhone

### 步骤 3：Xcode 配置

#### 3.1 选择目标设备
```
Xcode 顶部工具栏:
[Runner ▶] [iPhone 15 Pro]  ← 点击这里
                ↓
           [您的 iPhone 名称]  ← 选择这个
```

#### 3.2 配置签名（关键步骤）

1. 点击左侧项目导航栏的 **Runner**
2. 选择 **TARGETS** → **Runner**
3. 点击 **Signing & Capabilities** 标签

```
┌─────────────────────────────────────────┐
│ Runner                                  │
├─────────────────────────────────────────┤
│ [General] [Signing & Capabilities]      │
│            ↑ 点击这个                    │
│                                         │
│ Team: [None]     [Add Account...]       │
│       ↑                                 │
│  点击 Add Account 登录 Apple ID         │
└─────────────────────────────────────────┘
```

4. 点击 **Team** 下拉框 → **Add Account...**
5. 登录您的 Apple ID
6. 回到 Team 下拉框，选择您的个人团队（Personal Team）

#### 3.3 修改 Bundle ID（如果需要）

如果提示 Bundle ID 已被使用：
```
Bundle Identifier: com.brainfit.app.XXXX
                              ↑ 加随机数字
```

### 步骤 4：首次运行（会报错，正常）

1. 点击 Xcode 左上角的 **▶** 运行按钮
2. 会报错：`无法安装应用` 或 `不受信任的开发者`
3. 这是正常的，继续下一步

### 步骤 5：信任开发者证书

在 iPhone 上操作：

```
设置 → 通用 → VPN与设备管理（或"描述文件与设备管理"）
    ↓
找到您的 Apple ID
    ↓
点击「信任"您的Apple ID"」
    ↓
再次点击「信任」确认
```

### 步骤 6：再次运行

回到 Xcode，再次点击 **▶** 运行按钮

这次应该就能成功在 iPhone 上运行了！

---

## 方法二：使用 Flutter 命令行

### 步骤 1：连接设备并检查

```bash
# 检查设备是否连接
flutter devices

# 应该显示类似：
# iPhone 15 Pro (mobile) • 00008030-001... • ios • iOS 17.0
```

### 步骤 2：运行应用

```bash
cd ~/brainfit/projects/brainfit

# 安装依赖
flutter pub get

# 进入 iOS 目录安装 pod
cd ios
pod install
cd ..

# 运行到 iPhone
flutter run

# 或者指定设备 ID
flutter run -d "您的iPhone名称"
```

### 步骤 3：信任开发者（首次）

同方法一的步骤 5

---

## 常见问题

### ❌ 问题 1："Could not find an option named "no-sound-null-safety""
**解决：** 不需要这个参数了，直接运行 `flutter run`

### ❌ 问题 2："Unable to install the app"
**解决：** 
1. iPhone 设置 → 通用 → 设备管理 → 信任开发者
2. 确保 iPhone 已解锁

### ❌ 问题 3："No valid signing identities"
**解决：** 
1. Xcode → Runner → Signing & Capabilities
2. 登录 Apple ID
3. 选择 Personal Team

### ❌ 问题 4："The app ID cannot be registered"
**解决：** 
1. 修改 Bundle Identifier
2. 从 `com.brainfit.app` 改为 `com.brainfit.app.1234`（加随机数字）

### ❌ 问题 5：Firebase 初始化失败
**解决：** 
1. 检查 `ios/Runner/GoogleService-Info.plist` 是否存在
2. 检查 Bundle ID 是否与 Firebase 配置匹配

---

## 测试 Firebase 登录

应用启动后：

1. **匿名登录**（最快测试）
   - 点击「游客登录」或「立即体验」
   - 无需输入任何信息

2. **手机号登录**（使用测试号）
   - 输入：`+86 15001005686`
   - 验证码：`123456`
   - 登录成功

---

## 每次重新测试

如果过了一周再测试，可能需要：

```bash
cd ~/brainfit/projects/brainfit

# 更新代码
git pull

# 清理并重新构建
flutter clean
flutter pub get
cd ios
pod install --repo-update
cd ..

# 运行
flutter run
```

---

## 快捷命令总结

```bash
# 完整流程
cd ~/brainfit/projects/brainfit && \
flutter clean && \
flutter pub get && \
cd ios && pod install && cd .. && \
flutter run

# 或者直接用 Xcode
open ios/Runner.xcworkspace
```

---

## 需要帮助？

如果遇到问题：
1. 截图 Xcode 的错误提示
2. 或截图 iPhone 上的提示
3. 发给我帮您解决

**老爷，您现在做到哪一步了？我可以一步步指导您！**
