#!/bin/bash

# BrainFit GitHub 推送脚本
# 在您的 Mac 上运行此脚本

echo "🚀 BrainFit 代码同步指南"
echo "=========================="
echo ""

# 检查是否已有代码目录
if [ -d "~/brainfit" ]; then
    echo "⚠️  ~/brainfit 目录已存在"
    read -p "是否覆盖? (y/n): " confirm
    if [ "$confirm" != "y" ]; then
        exit 0
    fi
    rm -rf ~/brainfit
fi

# 方式1：从 GitHub clone（如果已推送）
echo "方式1：从 GitHub 下载"
echo "git clone https://github.com/Shuai-DaiDai/brainfit.git ~/brainfit"
echo ""

# 方式2：如果 GitHub 还没创建
echo "方式2：手动创建 GitHub 仓库"
echo ""
echo "步骤："
echo "1. 访问 https://github.com/new"
echo "2. 仓库名：brainfit"
echo "3. 选择 Private（私有）"
echo "4. 不勾选初始化 README"
echo "5. 点击 Create repository"
echo ""
echo "创建后，我会帮您推送代码"
echo ""

# 方式3：使用 R2 下载
echo "方式3：直接下载压缩包"
echo "如果上面的方式麻烦，我可以把代码打包上传到云存储"
echo "您直接下载解压即可"
echo ""

read -p "您选择哪种方式? (1/2/3): " choice

case $choice in
    1)
        git clone https://github.com/Shuai-DaiDai/brainfit.git ~/brainfit
        ;;
    2)
        echo "请先创建 GitHub 仓库，然后告诉我仓库地址"
        ;;
    3)
        echo "我来准备压缩包..."
        ;;
    *)
        echo "无效选择"
        ;;
esac
