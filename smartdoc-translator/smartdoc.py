#!/usr/bin/env python3
"""
SmartDoc Translator - 智能文档翻译工具
======================================

核心功能：
1. 本地解析 PDF/PPT（无需上传大文件）
2. 智能分块处理（解决上下文超限）
3. 保留原格式（位置、样式、字体）
4. 术语一致性维护

用法：
    python smartdoc.py translate input.pdf --output output.pdf
"""

import argparse
import json
import os
import re
import sqlite3
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
import tempfile

# 文档解析库
try:
    import fitz  # PyMuPDF
    HAS_FITZ = True
except ImportError:
    HAS_FITZ = False

try:
    from pptx import Presentation
    from pptx.util import Pt
    HAS_PPTX = True
except ImportError:
    HAS_PPTX = False


@dataclass
class TextElement:
    """文档文本元素"""
    text: str
    x: float  # 位置X
    y: float  # 位置Y
    font: str
    size: float
    color: str
    page: int  # 页码/幻灯片号
    element_type: str  # 'paragraph', 'header', 'table', etc.
    
    def to_dict(self):
        return asdict(self)


class TranslationMemory:
    """翻译记忆库 - 解决上下文一致性问题"""
    
    def __init__(self, db_path: str = "~/.smartdoc/memory.db"):
        self.db_path = Path(db_path).expanduser()
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self.conn = sqlite3.connect(str(self.db_path))
        self._init_db()
    
    def _init_db(self):
        """初始化数据库"""
        cursor = self.conn.cursor()
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS glossary (
                id INTEGER PRIMARY KEY,
                source TEXT UNIQUE,
                target TEXT,
                context TEXT,
                frequency INTEGER DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS translations (
                id INTEGER PRIMARY KEY,
                file_hash TEXT,
                chunk_hash TEXT,
                source TEXT,
                target TEXT,
                context_summary TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        self.conn.commit()
    
    def get_term(self, source: str) -> Optional[str]:
        """查询术语"""
        cursor = self.conn.cursor()
        cursor.execute("SELECT target FROM glossary WHERE source = ?", (source,))
        result = cursor.fetchone()
        return result[0] if result else None
    
    def add_term(self, source: str, target: str, context: str = ""):
        """添加术语"""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO glossary (source, target, context)
            VALUES (?, ?, ?)
            ON CONFLICT(source) DO UPDATE SET
                target = excluded.target,
                frequency = frequency + 1
        ''', (source, target, context))
        self.conn.commit()
    
    def get_recent_context(self, limit: int = 5) -> str:
        """获取最近翻译的上下文摘要"""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT context_summary FROM translations
            ORDER BY created_at DESC
            LIMIT ?
        ''', (limit,))
        results = cursor.fetchall()
        return "\n".join([r[0] for r in results if r[0]])


class SmartChunker:
    """智能分块器 - 解决上下文超限问题"""
    
    def __init__(self, max_tokens: int = 3000, overlap: int = 200):
        self.max_tokens = max_tokens
        self.overlap = overlap
    
    def chunk_text(self, text: str) -> List[str]:
        """将长文本智能分块"""
        # 按段落分割
        paragraphs = text.split('\n\n')
        chunks = []
        current_chunk = []
        current_length = 0
        
        for para in paragraphs:
            para_tokens = len(para) // 2  # 粗略估计
            
            if current_length + para_tokens > self.max_tokens:
                # 保存当前块
                if current_chunk:
                    chunks.append('\n\n'.join(current_chunk))
                # 保留部分重叠内容
                current_chunk = current_chunk[-2:] if len(current_chunk) > 2 else []
                current_length = sum(len(p) for p in current_chunk) // 2
            
            current_chunk.append(para)
            current_length += para_tokens
        
        if current_chunk:
            chunks.append('\n\n'.join(current_chunk))
        
        return chunks
    
    def chunk_elements(self, elements: List[TextElement]) -> List[List[TextElement]]:
        """按元素分块（保持页码完整）"""
        chunks = []
        current_chunk = []
        current_tokens = 0
        current_page = None
        
        for elem in elements:
            elem_tokens = len(elem.text) // 2
            
            # 新页码或超过限制，创建新块
            if (current_page is not None and elem.page != current_page) or \
               (current_tokens + elem_tokens > self.max_tokens):
                if current_chunk:
                    chunks.append(current_chunk)
                current_chunk = current_chunk[-3:] if len(current_chunk) > 3 else []
                current_tokens = sum(len(e.text) for e in current_chunk) // 2
            
            current_chunk.append(elem)
            current_tokens += elem_tokens
            current_page = elem.page
        
        if current_chunk:
            chunks.append(current_chunk)
        
        return chunks


class PDFParser:
    """PDF解析器 - 提取文本和格式"""
    
    def __init__(self, file_path: str):
        if not HAS_FITZ:
            raise ImportError("请安装 PyMuPDF: pip install pymupdf")
        self.file_path = file_path
        self.doc = fitz.open(file_path)
    
    def extract(self) -> List[TextElement]:
        """提取所有文本元素"""
        elements = []
        
        for page_num in range(len(self.doc)):
            page = self.doc[page_num]
            blocks = page.get_text("dict")["blocks"]
            
            for block in blocks:
                if "lines" in block:
                    for line in block["lines"]:
                        for span in line["spans"]:
                            element = TextElement(
                                text=span["text"],
                                x=span["bbox"][0],
                                y=span["bbox"][1],
                                font=span.get("font", "unknown"),
                                size=span.get("size", 12),
                                color=str(span.get("color", 0)),
                                page=page_num + 1,
                                element_type="text"
                            )
                            elements.append(element)
        
        return elements
    
    def close(self):
        self.doc.close()


class PPTParser:
    """PPT解析器"""
    
    def __init__(self, file_path: str):
        if not HAS_PPTX:
            raise ImportError("请安装 python-pptx: pip install python-pptx")
        self.file_path = file_path
        self.prs = Presentation(file_path)
    
    def extract(self) -> List[TextElement]:
        """提取所有文本元素"""
        elements = []
        
        for slide_num, slide in enumerate(self.prs.slides, 1):
            for shape in slide.shapes:
                if hasattr(shape, "text") and shape.text.strip():
                    element = TextElement(
                        text=shape.text,
                        x=shape.left if hasattr(shape, 'left') else 0,
                        y=shape.top if hasattr(shape, 'top') else 0,
                        font="unknown",
                        size=18,  # 默认PPT字号
                        color="0",
                        page=slide_num,
                        element_type="textbox"
                    )
                    elements.append(element)
        
        return elements


class SmartTranslator:
    """智能翻译器 - 调用我的API"""
    
    def __init__(self, memory: TranslationMemory):
        self.memory = memory
        self.glossary = {}
    
    def translate_chunk(self, text: str, context: str = "") -> str:
        """翻译文本块"""
        # 这里应该调用您的API
        # 目前使用模拟实现
        
        # 1. 应用术语表
        for term, translation in self.glossary.items():
            text = text.replace(term, f"[{translation}]")
        
        # 2. 构建提示词
        prompt = f"""请将以下文本翻译成中文。要求：
1. 保持专业术语一致
2. 语言流畅自然
3. 保留原文格式（如换行、段落）

上下文信息：
{context}

术语表：
{json.dumps(self.glossary, ensure_ascii=False, indent=2)}

待翻译文本：
{text}

翻译结果："""
        
        # 3. 返回模拟翻译（实际应调用API）
        return f"[翻译后的中文]: {text[:50]}..."
    
    def translate_with_memory(self, elements: List[TextElement]) -> List[TextElement]:
        """带记忆的翻译"""
        translated = []
        
        for elem in elements:
            # 检查术语表
            cached = self.memory.get_term(elem.text)
            if cached:
                elem.text = cached
            else:
                # 获取上下文
                context = self.memory.get_recent_context(3)
                # 翻译
                translated_text = self.translate_chunk(elem.text, context)
                elem.text = translated_text
                # 保存到记忆
                self.memory.add_term(elem.text, translated_text)
            
            translated.append(elem)
        
        return translated


class PDFFormatter:
    """PDF格式回填器"""
    
    def __init__(self, template_path: str):
        if not HAS_FITZ:
            raise ImportError("请安装 PyMuPDF")
        self.template_path = template_path
        self.doc = fitz.open(template_path)
    
    def write(self, elements: List[TextElement], output_path: str):
        """将翻译后的文本写回原位置"""
        # 按页分组
        pages = {}
        for elem in elements:
            if elem.page not in pages:
                pages[elem.page] = []
            pages[elem.page].append(elem)
        
        # 逐页替换文本
        for page_num, page_elements in pages.items():
            page = self.doc[page_num - 1]
            
            for elem in page_elements:
                # 在原位置添加翻译文本
                rect = fitz.Rect(elem.x, elem.y, elem.x + 200, elem.y + 50)
                page.add_textbox(
                    rect,
                    elem.text,
                    fontsize=elem.size,
                    fontname="china-s",  # 中文字体
                    color=int(elem.color) if elem.color.isdigit() else 0
                )
        
        self.doc.save(output_path)
    
    def close(self):
        self.doc.close()


class SmartDocApp:
    """主应用类"""
    
    def __init__(self):
        self.memory = TranslationMemory()
    
    def translate_file(self, input_path: str, output_path: str, 
                       target_lang: str = "zh") -> bool:
        """翻译文件"""
        input_path = Path(input_path)
        
        print(f"🔄 开始翻译: {input_path.name}")
        print(f"   输出路径: {output_path}")
        
        # 1. 解析文档
        print("📄 步骤1/4: 解析文档...")
        if input_path.suffix.lower() == '.pdf':
            parser = PDFParser(str(input_path))
        elif input_path.suffix.lower() in ['.pptx', '.ppt']:
            parser = PPTParser(str(input_path))
        else:
            print(f"❌ 不支持的格式: {input_path.suffix}")
            return False
        
        elements = parser.extract()
        print(f"   提取到 {len(elements)} 个文本元素")
        
        # 2. 智能分块
        print("🧩 步骤2/4: 智能分块...")
        chunker = SmartChunker(max_tokens=3000)
        chunks = chunker.chunk_elements(elements)
        print(f"   分成 {len(chunks)} 个块")
        
        # 3. 翻译
        print("🌐 步骤3/4: 翻译中...")
        translator = SmartTranslator(self.memory)
        translated_elements = []
        
        for i, chunk in enumerate(chunks, 1):
            print(f"   翻译块 {i}/{len(chunks)}...", end='\r')
            translated = translator.translate_with_memory(chunk)
            translated_elements.extend(translated)
        
        print(f"   ✓ 翻译完成 ({len(translated_elements)} 个元素)")
        
        # 4. 格式回填
        print("📝 步骤4/4: 格式回填...")
        if input_path.suffix.lower() == '.pdf':
            formatter = PDFFormatter(str(input_path))
            formatter.write(translated_elements, output_path)
            formatter.close()
        
        parser.close()
        
        print(f"✅ 翻译完成: {output_path}")
        return True


def main():
    parser = argparse.ArgumentParser(
        description='SmartDoc Translator - 智能文档翻译工具'
    )
    parser.add_argument('command', choices=['translate', 'glossary', 'stats'],
                       help='命令')
    parser.add_argument('input', nargs='?', help='输入文件')
    parser.add_argument('-o', '--output', help='输出文件')
    parser.add_argument('-l', '--lang', default='zh', help='目标语言')
    parser.add_argument('--style', choices=['formal', 'casual', 'technical'],
                       default='formal', help='翻译风格')
    
    args = parser.parse_args()
    
    app = SmartDocApp()
    
    if args.command == 'translate':
        if not args.input:
            print("❌ 请指定输入文件")
            sys.exit(1)
        
        output = args.output or args.input.replace('.pdf', '_zh.pdf')
        success = app.translate_file(args.input, output, args.lang)
        sys.exit(0 if success else 1)
    
    elif args.command == 'glossary':
        # 显示术语表
        print("📚 术语表:")
        # TODO: 查询并显示术语表
    
    elif args.command == 'stats':
        # 显示统计
        print("📊 翻译统计:")
        # TODO: 显示统计信息


if __name__ == '__main__':
    main()
