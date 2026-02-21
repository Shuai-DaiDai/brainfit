#!/bin/bash
# BrainFit 完整项目修复脚本
# 在 Mac 上运行此脚本配置所有平台

echo "🧠 BrainFit 项目修复脚本"
echo "========================"

# 检查是否在项目目录
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 请在 brainfit 项目目录中运行此脚本"
    exit 1
fi

echo "📦 步骤 1/4: 启用桌面支持..."
flutter config --enable-macos-desktop
flutter config --enable-web

echo ""
echo "📦 步骤 2/4: 重新生成平台文件..."
flutter create --platforms=ios,macos,android,web .

echo ""
echo "📦 步骤 3/4: 安装依赖..."
flutter pub get

echo ""
echo "✅ 步骤 4/4: 修复完成！"
echo ""
echo "🚀 现在可以运行:"
echo ""
echo "  # macOS 桌面版 (推荐)"
echo "  flutter run -d macos -t lib/main_local.dart"
echo ""
echo "  # iOS 模拟器"
echo "  flutter run -t lib/main_local.dart"
echo ""
echo "  # Android 模拟器"
echo "  flutter run -t lib/main_local.dart"
echo ""
