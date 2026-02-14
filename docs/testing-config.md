# BrainFit 测试配置

## Firebase Authentication 测试号码

### 已配置的测试号码

| 电话号码 | 验证码 | 用途 |
|----------|--------|------|
| +86-15001005686 | 123456 | 开发测试 |

### 使用说明

在 Firebase Console 中，测试号码已添加到 Authentication → Sign-in method → Phone → 测试号码

**测试流程：**
1. 在登录页面输入手机号：`+86 15001005686`
2. 点击「发送验证码」
3. 输入验证码：`123456`
4. 登录成功

---

## 其他测试配置

### Firestore 安全规则（开发模式）
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**注意：** 生产环境需要更严格的规则！

---

## 测试账号

### 方式1：匿名登录（最简单）
无需任何配置，直接体验

### 方式2：手机号登录（推荐）
使用上面的测试号码

### 方式3：邮箱登录
需要先在 Firebase Console 启用 Email/Password

---

## 开发环境配置

### 本地调试
```bash
# 启动应用
flutter run

# 或者指定设备
flutter run -d ios
flutter run -d android
```

### 连接 Firebase Emulator（可选）
```dart
// main.dart 中添加
if (kDebugMode) {
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

---

## 常见问题

**Q: 测试号码收不到验证码？**
A: 确保在 Firebase Console 中正确配置了测试号码，且格式为国际格式（+86开头）

**Q: 可以添加更多测试号码吗？**
A: 可以，在 Firebase Console → Authentication → Sign-in method → Phone 中添加

**Q: 测试号码有使用限制吗？**
A: 没有次数限制，适合开发和测试

---

*最后更新：2026-02-14*
