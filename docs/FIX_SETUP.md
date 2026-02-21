# 🧠 BrainFit 项目修复指南

> 修复 iOS/macOS 平台配置问题

---

## 🔧 修复步骤（在 Mac 上执行）

### 步骤 1: 进入项目目录

```bash
cd brainfit
```

### 步骤 2: 运行修复脚本

```bash
./scripts/setup_platforms.sh
```

或者手动执行：

```bash
# 启用桌面支持
flutter config --enable-macos-desktop

# 重新生成所有平台文件
flutter create --platforms=ios,macos,android,web .

# 安装依赖
flutter pub get
```

### 步骤 3: 运行应用

#### 方案 A: macOS 桌面版（最快）
```bash
flutter run -d macos -t lib/main_local.dart
```

#### 方案 B: iOS 模拟器
```bash
open -a Simulator
flutter run -t lib/main_local.dart
```

---

## ⚠️ 如果上述方法不行

### 备选方案：创建新项目并复制代码

如果 `flutter create` 无法修复，可以：

```bash
# 1. 创建新的 Flutter 项目
cd ~
flutter create --platforms=ios,macos,android brainfit_new

# 2. 复制代码文件
cp -r brainfit/lib/* brainfit_new/lib/
cp brainfit/pubspec.yaml brainfit_new/

# 3. 进入新项目
cd brainfit_new

# 4. 安装依赖
flutter pub get

# 5. 添加本地模式入口文件
cat > lib/main_local.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/mock_firebase_service.dart';
import 'core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A2E),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  await MockFirebaseService.initialize();
  await LocalStorageService.initialize();
  
  runApp(
    const ProviderScope(
      child: BrainFitApp(),
    ),
  );
}
EOF

# 6. 运行
flutter run -d macos -t lib/main_local.dart
```

---

## 📋 常见问题

### Q: `flutter create` 提示文件已存在？
**A**: 加上 `--overwrite` 参数：
```bash
flutter create --overwrite --platforms=ios,macos,android .
```

### Q: macOS 运行后窗口太小？
**A**: 可以拖动窗口边缘调整大小，应用支持响应式布局。

### Q: 提示缺少 `firebase_options.dart`？
**A**: 使用 `main_local.dart` 入口，它不需要 Firebase 配置。

### Q: 依赖安装失败？
**A**: 
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

---

## 🎯 快速验证

修复成功后，应该看到：

```
$ flutter devices
2 connected devices:

macOS (desktop) • macos • darwin-arm64 • macOS 14.x
Chrome (web)    • chrome • web-javascript

$ flutter run -d macos -t lib/main_local.dart
Launching lib/main_local.dart on macOS in debug mode...
🧠 BrainFit 本地模式启动
✅ 所有数据存储在本地，无需网络连接
```

---

## 📞 还是不行？

请告诉我：
1. `flutter doctor` 的输出
2. 具体的错误信息
3. macOS 版本

我可以进一步帮您排查！
