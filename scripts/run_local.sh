#!/bin/bash
# BrainFit Mac 本地运行快速脚本

echo "🧠 BrainFit 本地运行脚本"
echo "========================"

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装"
    echo "请运行: brew install flutter"
    exit 1
fi

echo "✅ Flutter 已安装"

# 进入项目目录
cd "$(dirname "$0")/.." || exit

# 获取依赖
echo "📦 安装依赖..."
flutter pub get

# 检查可用设备
echo ""
echo "📱 可用设备:"
flutter devices

# 询问运行方式
echo ""
echo "选择运行方式:"
echo "1) iOS 模拟器 (推荐首次测试)"
echo "2) macOS 桌面版 (最快捷)"
echo "3) iOS 真机 (需要配置签名)"
read -rp "请输入选项 (1-3): " choice

case $choice in
    1)
        echo "🚀 启动 iOS 模拟器..."
        open -a Simulator
        sleep 3
        flutter run -t lib/main_local.dart
        ;;
    2)
        echo "🖥️ 启用 macOS 桌面支持..."
        flutter config --enable-macos-desktop
        flutter run -d macos -t lib/main_local.dart
        ;;
    3)
        echo "📱 启动 iOS 真机..."
        flutter run -d ios -t lib/main_local.dart
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac
