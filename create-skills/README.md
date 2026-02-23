# 🛠️ Create Skills for OpenClaw

<p align="center">
  <img src="https://img.shields.io/badge/MCP-Compatible-brightgreen" alt="MCP Compatible">
  <img src="https://img.shields.io/badge/Python-3.8+-blue" alt="Python 3.8+">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="MIT License">
  <img src="https://img.shields.io/badge/Version-1.0.0-orange" alt="Version 1.0.0">
</p>

<p align="center">
  <b>基于 Anthropic MCP 最佳实践的 OpenClaw Skill 生成器</b><br>
  <i>Create production-ready OpenClaw skills following Model Context Protocol specifications</i>
</p>

---

## ✨ 特性

- 🎯 **4种 Skill 类型** - Tool、Resource、Prompt、Server
- 📐 **MCP 协议兼容** - 遵循 Anthropic Model Context Protocol 规范
- 🚀 **零依赖** - 纯 Python 标准库实现
- 📝 **完整模板** - 自动生成 SKILL.md、config.json、main.py
- 💻 **多模式支持** - 交互式、命令行、快速创建

---

## 📦 安装

```bash
# 克隆到 OpenClaw skills 目录
git clone <your-repo-url> ~/.openclaw/skills/create-skills

# 或者直接复制
cp -r skills/create-skills ~/.openclaw/skills/
```

---

## 🚀 快速开始

### 交互式模式（推荐）

```bash
python3 skills/create-skills/scripts/main.py --interactive
```

按照提示输入 Skill 名称、描述、类型等信息，一键生成完整项目。

### 快速创建

```bash
# 创建一个工具型 Skill
python3 skills/create-skills/scripts/main.py --quick weather-check --type tool

# 创建一个资源型 Skill
python3 skills/create-skills/scripts/main.py --quick file-reader --type resource
```

### 命令行模式

```bash
python3 skills/create-skills/scripts/main.py \
  --name "my-awesome-skill" \
  --description "Does something awesome" \
  --type tool \
  --author "Your Name" \
  --output-dir ./output
```

---

## 📚 Skill 类型详解

### 🔧 Tool（工具）

执行操作并返回结果，最常用的 Skill 类型。

**适用场景**:
- API 调用（天气、股票、翻译）
- 文件操作（读取、写入、转换）
- 计算任务（数学运算、数据处理）

**生成的代码包含**:
- MCP Tool Schema 定义
- 参数验证（JSON Schema）
- 执行函数框架
- 结构化输出

```python
# 示例：天气查询工具
def get_tool_schema(self) -> Dict:
    return {
        "name": "weather_current",
        "title": "Weather Information",
        "description": "Get current weather for any location",
        "inputSchema": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "City name or coordinates"
                }
            },
            "required": ["location"]
        }
    }
```

---

### 📖 Resource（资源）

提供上下文数据供 AI 使用。

**适用场景**:
- 文件内容读取
- 数据库查询
- 配置信息
- 知识库文档

**特点**:
- URI 标识资源
- 支持 MIME 类型
- 可订阅更新通知

```python
# 示例：文件资源
{
    "uri": "file:///path/to/document.txt",
    "name": "Document Content",
    "mimeType": "text/plain"
}
```

---

### 💬 Prompt（提示词）

可复用的交互模板。

**适用场景**:
- 系统提示词
- 少样本学习示例
- 对话模板
- 任务指令

```python
# 示例：代码审查提示词
{
    "name": "code-review",
    "description": "Review code for best practices",
    "arguments": [
        {"name": "language", "description": "Programming language"},
        {"name": "code", "description": "Code to review"}
    ]
}
```

---

### 🖥️ Server（服务器）

完整的 MCP 服务器实现。

**适用场景**:
- 外部服务集成（Slack、GitHub、数据库）
- 复杂业务逻辑
- 多工具组合
- 需要长时间运行的服务

**传输方式**:
- `stdio` - 本地进程通信
- `http` - 远程服务通信

---

## 📁 生成的项目结构

```
my-skill/
├── SKILL.md              # 完整的使用文档
├── README.md             # 项目说明（可选）
├── config.json           # MCP 配置
│   ├── protocolVersion   # 协议版本
│   ├── capabilities      # 能力声明
│   └── transport         # 传输方式
├── .gitignore           # Git 忽略配置
└── scripts/
    └── main.py          # 主实现代码
        ├── Tool/Resource/Prompt/Server 类
        ├── Schema 定义
        ├── 执行逻辑
        └── CLI 接口
```

---

## 🎯 MCP 协议规范

本生成器遵循 Anthropic 的 Model Context Protocol 规范：

| 规范项 | 说明 |
|--------|------|
| **协议版本** | 2025-06-18 |
| **消息格式** | JSON-RPC 2.0 |
| **生命周期** | 初始化 → 能力协商 → 运行 → 终止 |
| **核心原语** | Tools、Resources、Prompts |
| **传输层** | stdio（本地）、HTTP（远程） |
| **错误处理** | 标准 JSON-RPC 错误码 |

---

## 💡 最佳实践

### 1. 命名规范

```bash
# ✅ 推荐：kebab-case，描述性强
weather-check
file-reader
code-formatter
slack-notifier

# ❌ 避免
mySkill        # 不用 camelCase
skill_1        # 不要无意义数字
foo-bar        # 不要无意义名称
```

### 2. 描述编写

```python
# ✅ 好的描述：清晰、具体、说明用途
"Get real-time weather information for any location worldwide"
"Read and parse JSON/YAML configuration files with validation"
"Format Python code according to PEP 8 standards"

# ❌ 避免
"A tool"                    # 太笼统
"Does something"           # 无信息量
"Weather"                  # 不完整
```

### 3. 输入参数设计

```python
# ✅ 好的设计：清晰的参数名和描述
"properties": {
    "location": {
        "type": "string",
        "description": "City name, address, or coordinates (lat,lon)"
    },
    "units": {
        "type": "string",
        "enum": ["metric", "imperial", "kelvin"],
        "description": "Temperature units",
        "default": "metric"
    }
}
```

---

## 🔧 完整示例

### 示例 1：创建天气查询 Skill

```bash
python3 skills/create-skills/scripts/main.py \
  --name "weather-check" \
  --description "Get current weather information for any location worldwide" \
  --type tool \
  --output-dir ./my-skills
```

生成后编辑 `scripts/main.py`：

```python
def execute(self, arguments: Dict[str, Any]) -> Dict:
    location = arguments.get('location', '')
    units = arguments.get('units', 'metric')
    
    # 调用天气 API
    weather_data = self._fetch_weather(location, units)
    
    return {
        "content": [
            {
                "type": "text",
                "text": f"Weather in {location}: {weather_data['temp']}°, {weather_data['condition']}"
            }
        ]
    }
```

### 示例 2：创建文件读取 Skill

```bash
python3 skills/create-skills/scripts/main.py \
  --name "file-reader" \
  --description "Read and provide file contents with syntax highlighting" \
  --type resource
```

---

## 🧪 测试生成的 Skill

```bash
# 1. 进入 Skill 目录
cd output/my-skill

# 2. 查看帮助
python3 scripts/main.py --help

# 3. 查看 Schema
python3 scripts/main.py --schema

# 4. 测试执行
python3 scripts/main.py --input '{"location": "Beijing"}'

# 5. 复制到 OpenClaw
cp -r my-skill ~/.openclaw/skills/
```

---

## 📖 参考文档

- [Model Context Protocol Specification](https://modelcontextprotocol.io)
- [Anthropic MCP Documentation](https://docs.anthropic.com)
- [OpenClaw Documentation](https://docs.openclaw.ai)

---

## 🤝 贡献

欢迎提交 Issue 和 PR！

---

## 📄 许可证

MIT License © 2026 帅小呆1号

---

<p align="center">
  Made with ❤️ for OpenClaw<br>
  Based on <a href="https://www.anthropic.com">Anthropic</a> MCP Best Practices
</p>
