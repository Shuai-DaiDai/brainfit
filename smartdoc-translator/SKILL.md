# SmartDoc Translator
# 智能文档翻译工具

将 PDF/PPT 翻译成中文，保留原格式，解决上下文一致性问题。

## 核心特性

✅ **使用 Kimi AI 翻译** - 直接使用当前 AI 模型，无需外部 API  
✅ **本地处理** - 大文件无需上传  
✅ **智能分块** - 解决上下文超限  
✅ **格式保留** - 保持原排版、字体、颜色  
✅ **术语一致** - 自动维护术语表  

## 翻译引擎

默认使用 **Kimi** (当前模型) 作为翻译引擎：
- 支持自定义翻译 prompt
- 自动维护术语表确保一致性
- 上下文记忆保持连贯性

## 安装

```bash
# 安装依赖
pip install -r requirements.txt

# 或者
pip install pymupdf python-pptx python-docx
```

### 配置翻译引擎

**方式1: API Key（推荐）**
```bash
export KIMI_API_KEY="your-api-key"
# 或
export OPENCLAW_API_KEY="your-api-key"
```

**方式2: 通过 OpenClaw 调用（无需 API Key）**
SmartDoc 会自动创建翻译请求文件，由 OpenClaw 处理

## 使用方法

```bash
# 基本用法
python smartdoc.py translate input.pdf -o output.pdf

# 指定风格
python smartdoc.py translate document.pdf --style technical

# 查看术语表
python smartdoc.py glossary

# 查看统计
python smartdoc.py stats
```

## 支持的格式

- PDF (.pdf)
- PowerPoint (.pptx, .ppt)
- Word (.docx) - 计划中

## 架构说明

```
Input (PDF/PPT)
    ↓
Parser (提取文本+位置+格式)
    ↓
Chunker (智能分块)
    ↓
Translator (调用AI翻译 + 术语表)
    ↓
Formatter (格式回填)
    ↓
Output (保留格式的中文文档)
```

## 技术细节

### 1. 大文件处理
- 本地解析，无需上传
- PyMuPDF 提取精确文本位置
- 支持 1000+ 页大文档

### 2. 上下文管理
- 智能分块（按段落/页）
- 维护上下文摘要
- 术语表实时同步

### 3. 格式保留
- 提取：位置 (x,y) + 字体 + 颜色
- 翻译：仅文本内容
- 回填：按原位置写入

### 4. 术语一致性
- 自动提取专有名词
- SQLite 术语库
- 增量学习

## 配置

术语表位置：`~/.smartdoc/memory.db`

自定义术语：
```python
from smartdoc import TranslationMemory

memory = TranslationMemory()
memory.add_term("API", "应用程序接口", "技术文档")
```

## 与 OpenClaw 集成

作为 Skill 使用：
```bash
# 在 OpenClaw 中
smartdoc translate report.pdf
```

## TODO

- [ ] 集成 OpenAI/Claude API 实现真实翻译
- [ ] 支持更多格式（DOCX, XLSX）
- [ ] 图形界面
- [ ] 批量处理
- [ ] 翻译质量评估

## License

MIT
