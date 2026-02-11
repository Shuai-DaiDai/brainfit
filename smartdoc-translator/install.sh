#!/bin/bash
#
# SmartDoc Translator 安装脚本
# ============================

echo "📝 SmartDoc Translator 安装"
echo "============================"
echo ""

# 检查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 需要 Python 3.8+"
    exit 1
fi

echo "✅ Python: $(python3 --version)"

# 安装目录
INSTALL_DIR="${HOME}/.openclaw/skills/smartdoc-translator"
echo ""
echo "📂 安装目录: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# 复制文件
echo "📦 复制文件..."
cp smartdoc.py "$INSTALL_DIR/"
cp requirements.txt "$INSTALL_DIR/"
cp SKILL.md "$INSTALL_DIR/"

# 安装依赖
echo ""
echo "⬇️  安装依赖..."
pip3 install -q -r requirements.txt

if [ $? -eq 0 ]; then
    echo "✅ 依赖安装成功"
else
    echo "⚠️  依赖安装可能失败，请手动运行: pip3 install -r requirements.txt"
fi

# 创建命令链接
echo ""
echo "🔗 创建命令..."
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/smartdoc" << 'EOF'
#!/bin/bash
python3 ~/.openclaw/skills/smartdoc-translator/smartdoc.py "$@"
EOF
chmod +x "$HOME/.local/bin/smartdoc"

# 添加到 PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo "✅ 已添加到 PATH (请运行: source ~/.bashrc)"
fi

echo ""
echo "🎉 安装完成！"
echo ""
echo "使用方法:"
echo "   smartdoc translate input.pdf -o output.pdf"
echo ""
echo "或完整路径:"
echo "   python3 ~/.openclaw/skills/smartdoc-translator/smartdoc.py translate input.pdf"
