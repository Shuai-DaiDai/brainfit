# BrainFit Firebase 配置指南

## 概述
BrainFit 使用 Firebase 提供以下服务：
- **Firebase Authentication** - 用户认证
- **Cloud Firestore** - 用户数据、练习记录、成就存储
- **Firebase Analytics** - 应用分析
- **Firebase Crashlytics** - 崩溃报告

---

## 快速开始

### 1. 创建 Firebase 项目

1. 访问 [Firebase Console](https://console.firebase.google.com/)
2. 点击 "创建项目"
3. 项目名称：`brainfit-app`
4. 启用 Google Analytics（可选）
5. 等待项目创建完成

---

### 2. 注册应用

#### Android 配置

1. 在 Firebase Console 点击 "添加应用" → "Android"
2. **Android 包名**: `com.brainfit.app`
3. **应用昵称**: BrainFit
4. 下载 `google-services.json`
5. 将文件放到: `android/app/google-services.json`

#### iOS 配置

1. 在 Firebase Console 点击 "添加应用" → "iOS"
2. **iOS Bundle ID**: `com.brainfit.app`
3. **应用昵称**: BrainFit
4. 下载 `GoogleService-Info.plist`
5. 将文件放到: `ios/Runner/GoogleService-Info.plist`

---

### 3. 启用 Firebase 服务

在 Firebase Console 中启用以下服务：

#### Authentication
- 进入 "Authentication" → "登录方法"
- 启用 "电子邮件/密码"
- 启用 "Google" 登录（可选）
- 启用 "Apple" 登录（iOS 必需）

#### Firestore Database
- 进入 "Firestore Database"
- 点击 "创建数据库"
- 选择 "测试模式"（开发阶段）
- 选择就近的数据中心（asia-east1 台湾/香港）

#### Analytics
- 自动启用，无需额外配置

---

### 4. Firestore 数据结构

#### 集合设计

```
users/{userId}/
  - email: string
  - displayName: string
  - brainAge: number
  - chronologicalAge: number
  - createdAt: timestamp
  - updatedAt: timestamp

users/{userId}/practiceSessions/{sessionId}/
  - type: string (breathing | meditation | nback | brainAge)
  - duration: number (seconds)
  - score: number
  - completedAt: timestamp
  - metadata: map

users/{userId}/achievements/{achievementId}/
  - unlocked: boolean
  - unlockedAt: timestamp
  - progress: number

users/{userId}/streak/
  - currentStreak: number
  - longestStreak: number
  - lastCheckIn: timestamp
  - totalCheckIns: number

users/{userId}/rewards/
  - balance: number
  - transactions: subcollection
```

#### 安全规则

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 用户只能读写自己的数据
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

### 5. Flutter 配置

项目已配置好以下依赖（`pubspec.yaml`）:

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9
```

---

### 6. 配置文件

#### android/build.gradle
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### android/app/build.gradle
```gradle
apply plugin: 'com.google.gms.google-services'

defaultConfig {
    minSdkVersion 21
}
```

#### ios/Podfile
```ruby
platform :ios, '13.0'
```

---

### 7. 初始化代码

主入口文件已配置 Firebase 初始化：

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: BrainFitApp()));
}
```

---

### 8. 测试配置

运行以下命令验证配置：

```bash
# 清理并重新构建
cd projects/brainfit
flutter clean
flutter pub get

# Android
cd android
./gradlew clean
./gradlew build

# iOS
cd ios
pod install --repo-update
```

---

### 9. 常见问题

#### Q: Android 构建失败？
A: 确保 `google-services.json` 文件位置正确，且 `android/app/build.gradle` 中已应用插件。

#### Q: iOS 构建失败？
A: 确保 `GoogleService-Info.plist` 已添加到 Xcode 项目中，且已运行 `pod install`。

#### Q: Firebase 初始化失败？
A: 检查 `firebase_options.dart` 文件是否与下载的配置文件匹配。

---

### 10. 下一步

配置完成后，实现以下功能：
1. ✅ 用户注册/登录
2. ✅ 数据云同步
3. ✅ 跨设备支持
4. ⏳ 社交功能（排行榜）
5. ⏳ 推送通知

---

## 文件清单

| 文件 | 说明 | 来源 |
|------|------|------|
| `android/app/google-services.json` | Android 配置 | Firebase Console 下载 |
| `ios/Runner/GoogleService-Info.plist` | iOS 配置 | Firebase Console 下载 |
| `lib/firebase_options.dart` | Flutter 配置 | 自动生成 |
| `lib/core/services/firebase_service.dart` | 服务封装 | 项目已提供 |

---

*配置完成后，BrainFit 将支持用户账户和数据云同步！*
