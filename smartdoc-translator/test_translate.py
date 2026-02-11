#!/usr/bin/env python3
"""
SmartDoc Translator - 测试版本
使用当前 AI 会话直接翻译
"""

import sys
sys.path.insert(0, '/root/.openclaw/workspace/skills/smartdoc-translator')

from smartdoc import PDFParser, SmartChunker, TranslationMemory, TextElement
from pathlib import Path

# 测试翻译提示
def translate_with_ai(text: str, context: str = "") -> str:
    """使用当前 AI 会话翻译"""
    # 这里会调用当前的 AI 会话（我自己）
    # 但由于技术限制，我们先返回一个模拟结果
    # 实际使用时应该通过某种方式调用到 AI
    
    if "SHORT TITLE" in text:
        return "简称"
    elif "TABLE OF CONTENTS" in text:
        return "目录"
    elif "PURPOSE" in text:
        return "目的"
    elif len(text) < 50:
        # 短文本返回模拟翻译
        return f"[中文翻译]: {text[:30]}..."
    else:
        # 长文本返回原文（实际应调用 AI）
        return text

# 主流程
print("🧪 SmartDoc Translator - 测试运行")
print("=" * 50)

pdf_path = "/tmp/test-bill.pdf"
print(f"\n📄 测试文件: {pdf_path}")

# 1. 解析
print("\n步骤1: 解析 PDF...")
parser = PDFParser(pdf_path)
elements = parser.extract()
print(f"✓ 提取 {len(elements)} 个文本元素")

# 显示前10个元素
print("\n前10个文本元素:")
for i, elem in enumerate(elements[:10], 1):
    print(f"  {i}. [第{elem.page}页] {elem.text[:80]}...")

# 2. 分块
print("\n步骤2: 智能分块...")
chunker = SmartChunker(max_chars=1500)
chunks = chunker.chunk_elements(elements)
print(f"✓ 分成 {len(chunks)} 个块")

# 3. 翻译测试（只翻译前3个块）
print("\n步骤3: 翻译测试 (前3个块)...")
memory = TranslationMemory()

for i, chunk in enumerate(chunks[:3], 1):
    print(f"\n  块 {i}/{len(chunks)} ({len(chunk)} 个元素):")
    
    # 合并块内文本进行翻译
    chunk_text = "\n".join([e.text for e in chunk])
    
    if len(chunk_text) > 200:
        print(f"    原文片段: {chunk_text[:100]}...")
        # 调用翻译（模拟）
        translated = translate_with_ai(chunk_text[:500])
        print(f"    翻译结果: {translated[:100]}...")
    else:
        print(f"    原文: {chunk_text}")
        translated = translate_with_ai(chunk_text)
        print(f"    翻译: {translated}")

print("\n" + "=" * 50)
print("✅ 测试完成！")
print("\n说明:")
print("- 实际使用时需要配置 API Key 或使用 OpenClaw 集成")
print("- 当前为演示模式，显示文档解析和分块功能")

parser.close()
