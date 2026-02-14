# 🧠 BrainFit - 脑力健身房

<p align="center">
  <img src="docs/assets/app_icon.png" width="120" alt="BrainFit Logo">
</p>

<p align="center">
  <strong>用成瘾机制对抗成瘾</strong>
</p>

<p align="center">
  基于神经科学的游戏化专注力训练应用
</p>

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
- Android Studio / Xcode
- Firebase 项目

### 安装步骤

1. **克隆项目**
```bash
git clone <repo-url>
cd brainfit
```

2. **安装依赖**
```bash
flutter pub get
```

3. **配置 Firebase** ⚠️ 重要
```bash
# 方法1: 自动配置（推荐）
./scripts/setup_firebase.sh

# 方法2: 手动配置
# 1. 访问 https://console.firebase.google.com/
# 2. 创建项目 brainfit-app
# 3. 下载配置文件到对应位置
# 4. 运行 flutterfire configure
```

详细配置步骤见: [docs/firebase-setup.md](docs/firebase-setup.md)

4. **运行应用**
```bash
# 开发模式
flutter run

# 发布模式
flutter run --release
```

---

## 📱 项目结构

```
lib/
├── main.dart                    # 应用入口
├── app.dart                     # 应用配置
├── firebase_options.dart        # Firebase 配置
├── core/                        # 核心模块
│   ├── theme/                   # 主题配置
│   │   └── app_theme.dart
│   ├── router/                  # 路由管理
│   │   └── navigation_provider.dart
│   ├── services/                # 服务层
│   │   ├── firebase_service.dart    # Firebase 服务
│   │   ├── local_storage_service.dart
│   │   ├── haptic_service.dart
│   │   └── health_service.dart
│   └── providers/               # 全局状态
├── features/                    # 功能模块
│   ├── brain_age/               # 脑力年龄
│   ├── breathing/               # 呼吸练习
│   ├── meditation/              # 正念冥想
│   ├── dual_nback/              # N-back游戏
│   ├── streak/                  # 连续打卡
│   ├── rewards/                 # 奖励系统
│   └── achievements/            # 成就系统
└── presentation/                # 表现层
    └── screens/                 # 页面
        ├── splash/              # 闪屏
        ├── onboarding/          # 引导
        ├── home/                # 首页
        ├── brain_age/           # 脑力测试
        ├── breathing/           # 呼吸练习(4种)
        ├── meditation/          # 冥想
        ├── dual_nback/          # N-back
        ├── streak/              # 打卡
        ├── rewards/             # 奖励
        ├── neural_network/      # 神经网络
        ├── weekly_report/       # 周报
        └── profile/             # 个人中心
```

---

## 🛠️ 技术栈

| 技术 | 用途 | 版本 |
|------|------|------|
| **Flutter** | 跨平台框架 | 3.x |
| **Dart** | 编程语言 | 3.x |
| **Riverpod** | 状态管理 | 2.4.x |
| **Firebase** | 后端服务 | - |
| **Firestore** | 数据库 | - |
| **Hive** | 本地存储 | 2.2.x |
| **GoRouter** | 路由管理 | - |

### Firebase 服务
- 🔐 Authentication - 用户认证
- 💾 Firestore - 数据存储
- 📊 Analytics - 应用分析
- 🔔 Cloud Messaging - 推送通知

---

## 📝 配置说明

### Firebase 配置（必需）

1. **创建 Firebase 项目**
   - 访问 [Firebase Console](https://console.firebase.google.com/)
   - 创建项目: `brainfit-app`

2. **下载配置文件**
   ```
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```

3. **生成 Dart 配置**
   ```bash
   flutterfire configure --project=brainfit-app
   ```

详细配置: [docs/firebase-setup.md](docs/firebase-setup.md)

### 可选配置

#### HealthKit (iOS)
用于 HRV 监测，需要 Apple Developer 账号 ($99/年)

#### 推送通知
配置 Firebase Cloud Messaging 实现每日提醒

---

## 🧪 测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/brain_age_test.dart

# 覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📦 构建发布

### Android
```bash
flutter build apk --release          # APK
flutter build appbundle --release    # AAB (Play Store)
```

### iOS
```bash
flutter build ios --release
# 然后在 Xcode 中 Archive 并上传
```

---

## 📊 项目统计

- **代码行数**: 12,000+
- **页面数量**: 17
- **功能模块**: 11
- **测试覆盖率**: 待添加

---

## 🎯 产品路线图

### ✅ MVP (已完成)
- 4种呼吸练习
- 脑力年龄测试
- Dual N-back游戏
- 正念冥想
- Streak + 奖励系统
- 数据可视化

### 📅 v1.1 (计划中)
- [ ] HealthKit HRV 监测
- [ ] 屏幕时间追踪
- [ ] 推送通知
- [ ] 社交排行榜

### 📅 v1.2 (规划中)
- [ ] 团队协作挑战
- [ ] 高级数据洞察
- [ ] AI 个性化推荐
- [ ] 多语言支持

---

## 🤝 贡献

1. Fork 项目
2. 创建分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

## 🙏 致谢

- 设计灵感: Nike Training Club × Oura Ring × Duolingo
- 呼吸方法: Stanford Medicine, Dr. Andrew Huberman
- 游戏化理论: Nir Eyal《上瘾》

---

<p align="center">
  Made with ❤️ by BrainFit Team
</p>
