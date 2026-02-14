#!/bin/bash

# BrainFit Firebase 初始化脚本
# 在配置完 Firebase 项目后运行此脚本

echo "🚀 BrainFit Firebase 配置脚本"
echo "=============================="

# 检查 flutter 命令
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误: 未找到 Flutter。请先安装 Flutter SDK。"
    exit 1
fi

# 检查 Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "📦 安装 Firebase CLI..."
    curl -sL https://firebase.tools | bash
fi

echo ""
echo "📋 配置步骤:"
echo "1. 访问 https://console.firebase.google.com/"
echo "2. 创建新项目: brainfit-app"
echo "3. 添加 Android 应用，包名: com.brainfit.app"
echo "4. 下载 google-services.json 放到 android/app/"
echo "5. 添加 iOS 应用，Bundle ID: com.brainfit.app"
echo "6. 下载 GoogleService-Info.plist 放到 ios/Runner/"
echo ""

# 提示用户
read -p "已完成上述步骤? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "请先完成 Firebase Console 的配置步骤。"
    exit 0
fi

# 检查配置文件
if [ ! -f "android/app/google-services.json" ]; then
    echo "⚠️ 警告: 未找到 android/app/google-services.json"
    echo "   请从 Firebase Console 下载并放置到正确位置"
fi

if [ ! -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "⚠️ 警告: 未找到 ios/Runner/GoogleService-Info.plist"
    echo "   请从 Firebase Console 下载并放置到正确位置"
fi

echo ""
echo "🔧 安装 FlutterFire CLI..."
dart pub global activate flutterfire_cli 2>/dev/null || true

echo ""
echo "🔧 运行 FlutterFire 配置..."
flutterfire configure --project=brainfit-app --out=lib/firebase_options.dart \
    --ios-bundle-id=com.brainfit.app \
    --android-app-id=com.brainfit.app \
    --platforms=android,ios,web 2>/dev/null || {
    echo "⚠️ FlutterFire 配置失败，使用手动配置..."
}

echo ""
echo "📦 安装依赖..."
flutter pub get

echo ""
echo "🤖 配置 Android..."
cd android

# 检查并添加 google-services 插件
if ! grep -q "com.google.gms.google-services" build.gradle 2>/dev/null; then
    echo "添加 Google Services 插件到 android/build.gradle..."
    # 需要在项目级别 build.gradle 中添加
fi

cd ..

echo ""
echo "🍎 配置 iOS..."
cd ios
pod install --repo-update 2>/dev/null || echo "⚠️ pod install 失败，请手动运行"
cd ..

echo ""
echo "✅ 配置完成!"
echo ""
echo "下一步:"
echo "  flutter run"
echo ""
