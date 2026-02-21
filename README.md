# 🧠 BrainFit - 脑力健身房 (纯本地版)

> 科学验证的12种健脑方法，帮助对抗短视频过度使用
> 
> **⚡ 纯本地版特点：无需网络，无需登录，开箱即用**

---

## ✨ 核心功能

### 🚨 L1 急救层 - 即时缓解
| 功能 | 描述 | 状态 |
|------|------|------|
| **共振呼吸** | 5.5秒周期，最大化HRV | ✅ |
| **循环叹息** | 斯坦福验证减压法 | ✅ |
| **4-7-8呼吸** | 经典助眠放松 | ✅ |
| **箱式呼吸** | 海军海豹同款专注训练 | ✅ |

### 🧘 L2 修复层 - 深度恢复
| 功能 | 描述 | 状态 |
|------|------|------|
| **正念冥想** | 4场景+走神检测机制 | ✅ |
| **身体扫描** | 系统性放松 | ✅ |
| **渐进式肌肉放松** | PMR技术 | ✅ |

### 🎮 L3 强化层 - 能力训练
| 功能 | 描述 | 状态 |
|------|------|------|
| **Dual N-back** | 工作记忆训练 | ✅ |
| **脑力年龄测试** | 3维度评估系统 | ✅ |

### 🔥 游戏化系统
| 功能 | 描述 | 状态 |
|------|------|------|
| **连续打卡** | Streak + 里程碑奖励 | ✅ |
| **神经元币** | 游戏内经济系统 | ✅ |
| **成就系统** | 12个成就 | ✅ |
| **神经网络** | 可视化成长地图 | ✅ |
| **脑力周报** | 数据分析+分享 | ✅ |

---

## 🚀 快速开始

### 环境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- macOS / iOS / Android / Web

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/Shuai-DaiDai/brainfit.git
cd brainfit
```

2. **安装依赖**
```bash
flutter pub get
```

3. **运行应用**

#### macOS 桌面版（推荐开发测试）
```bash
flutter config --enable-macos-desktop
flutter run -d macos
```

#### iOS 模拟器
```bash
open -a Simulator
flutter run
```

#### Chrome 浏览器
```bash
flutter run -d chrome
```

#### Android
```bash
flutter run
```

---

## 📱 纯本地版特点

| 特性 | 本地版 | 云端版 |
|------|--------|--------|
| **网络连接** | ❌ 不需要 | ✅ 需要 |
| **用户登录** | ❌ 自动匿名 | ✅ 邮箱/手机/社交 |
| **数据存储** | 📱 本地 Hive 数据库 | ☁️ Firestore |
| **数据持久化** | ✅ 永久保存 | ✅ 永久保存 |
| **多设备同步** | ❌ 不支持 | ✅ 支持 |
| **隐私安全** | ✅ 数据不出设备 | ⚠️ 云端存储 |
| **启动速度** | ⚡ 快 | 🌐 需连接 |

---

## 🏗️ 技术架构

### 存储方案
```
Hive 本地数据库
├── user          - 用户信息
├── sessions      - 练习记录
├── streak        - 打卡数据
├── rewards       - 奖励余额
├── achievements  - 成就系统
└── settings      - 用户设置
```

### 核心依赖
| 包名 | 用途 |
|------|------|
| **hive** | 本地 NoSQL 数据库 |
| **flutter_riverpod** | 状态管理 |
| **just_audio** | 音频播放 |
| **fl_chart** | 数据可视化 |
| **uuid** | 唯一ID生成 |

---

## 📊 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 应用配置
├── core/                        # 核心模块
│   ├── theme/                   # 主题配置
│   ├── services/                # 服务层
│   │   └── local_storage_service.dart  # 本地存储
│   └── providers/               # 全局状态
├── presentation/                # 表现层
│   └── screens/                 # 17个页面
│       ├── splash/
│       ├── onboarding/
│       ├── home/
│       ├── breathing/           # 4种呼吸法
│       ├── meditation/
│       ├── dual_nback/
│       ├── brain_age/
│       ├── streak/
│       ├── rewards/
│       └── profile/
└── ...
```

---

## 🎮 使用指南

### 首次启动
1. 完成引导页（可跳过）
2. 进行脑力年龄测试（可选）
3. 获得初始 100 神经元币
4. 开始第一次练习！

### 推荐训练组合

#### 🚨 急救模式（3-5分钟）
刷完短视频后快速恢复：
1. 循环叹息（最快见效）
2. 4-7-8呼吸（助眠）
3. 箱式呼吸（高压场景）

#### 🌙 睡前模式（15-30分钟）
1. 4-7-8呼吸
2. 身体扫描
3. 渐进式肌肉放松

#### 🌅 晨间模式（10-20分钟）
1. 共振呼吸
2. 正念冥想
3. 自我肯定

#### 🎮 认知训练（15-20分钟）
1. Dual N-back
2. 正念冥想
3. 共振呼吸

---

## 💾 数据说明

### 存储位置
- **iOS**: `App Documents` 目录
- **Android**: `App Files` 目录
- **macOS**: `~/Library/Application Support/brainfit`
- **Web**: `LocalStorage`

### 数据安全
- 所有数据存储在设备本地
- 不传输到任何服务器
- 卸载应用会删除所有数据

### 备份方式
如需迁移数据，可手动备份：
```bash
# macOS
~/Library/Application Support/brainfit

# iOS (需越狱或使用 iTunes 备份)
# Android (需 root 或使用 adb)
```

---

## 🛠️ 开发指南

### 添加新的练习方法

1. 在 `lib/methods/` 创建新方法类
2. 继承 `BrainMethod` 接口
3. 在 `LocalStorageService` 添加相关逻辑
4. 更新 UI 页面

### 修改主题

编辑 `lib/core/theme/app_theme.dart`：
```dart
static ThemeData get darkTheme => ThemeData(
  // 自定义颜色、字体等
);
```

---

## 📦 构建发布

### iOS
```bash
flutter build ios --release
# 然后在 Xcode 中 Archive 并上传
```

### Android
```bash
flutter build apk --release          # APK
flutter build appbundle --release    # AAB (Play Store)
```

### macOS
```bash
flutter build macos --release
```

---

## 🤝 贡献

欢迎贡献新的科学验证方法或改进现有实现。

---

## 📄 License

MIT License - 详见 [LICENSE](LICENSE)

---

<p align="center">
  Made with ❤️ by BrainFit Team
</p>

---

## 🔄 版本历史

### v1.0.0+2 (2026-02-21)
- ✅ 移除所有 Firebase 依赖
- ✅ 改为纯本地存储
- ✅ 无需网络连接
- ✅ 无需用户登录
- ✅ 开箱即用

### v1.0.0+1 (2026-02-14)
- 🎉 初始版本
- 🔥 12种健脑方法
- 🎮 完整游戏化系统
