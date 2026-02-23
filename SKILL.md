# Create Skills - Skill Generator for OpenClaw

> 🛠️ A skill for creating new OpenClaw skills following Anthropic MCP best practices

---

## Overview

This skill helps you create new skills for OpenClaw using the Model Context Protocol (MCP) principles from Anthropic. It generates properly structured skills with:

- **SKILL.md** - Documentation and usage guide
- **scripts/main.py** - Main implementation
- **config.json** - Skill configuration

---

## Installation

```bash
# Copy skill to your OpenClaw skills directory
cp -r skills/create-skills ~/.openclaw/skills/

# Or use directly from workspace
python3 skills/create-skills/scripts/main.py --help
```

---

## Usage

### Interactive Mode
```bash
python3 skills/create-skills/scripts/main.py --interactive
```

### Command Line Mode
```bash
python3 skills/create-skills/scripts/main.py \
  --name "my-skill" \
  --description "Does something useful" \
  --type "tool" \
  --output-dir ./output
```

### Quick Create
```bash
# Create a basic tool skill
python3 skills/create-skills/scripts/main.py --quick weather --type tool

# Create a resource skill
python3 skills/create-skills/scripts/main.py --quick file-reader --type resource
```

---

## Skill Types

### 1. **Tool Skills** (Most Common)
Execute actions and return results.
- Example: API calls, file operations, calculations
- MCP Primitive: `tools/call`

### 2. **Resource Skills**
Provide contextual data to AI.
- Example: File contents, database records, API responses
- MCP Primitive: `resources/read`

### 3. **Prompt Skills**
Reusable interaction templates.
- Example: System prompts, few-shot examples
- MCP Primitive: `prompts/get`

### 4. **Server Skills**
Full MCP server implementations.
- Example: Integration with external services
- Transport: stdio or HTTP

---

## Generated Skill Structure

```
my-skill/
├── SKILL.md           # Documentation
├── config.json        # Skill configuration
└── scripts/
    ├── main.py       # Main implementation
    └── lib/          # Helper modules (optional)
```

---

## Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `--name` | Skill name (kebab-case) | Required |
| `--description` | Short description | "A new skill" |
| `--type` | Skill type (tool/resource/prompt/server) | tool |
| `--author` | Author name | "OpenClaw User" |
| `--version` | Initial version | 1.0.0 |
| `--output-dir` | Output directory | ./output |

---

## Best Practices (from Anthropic MCP)

### 1. **Tool Design**
- Use descriptive names with clear action verbs
- Provide comprehensive descriptions
- Define JSON Schema for inputs
- Return structured content arrays

### 2. **Resource Design**
- Use URI-based identifiers
- Support MIME types
- Enable dynamic updates via notifications

### 3. **Error Handling**
- Return proper JSON-RPC error codes
- Provide meaningful error messages
- Use progress notifications for long operations

### 4. **Security**
- Validate all inputs
- Use secure transports (TLS for HTTP)
- Implement proper authentication
- Never expose sensitive credentials

---

## Examples

### Example 1: Weather Tool
```bash
python3 skills/create-skills/scripts/main.py \
  --name "weather-check" \
  --description "Get current weather for any location" \
  --type tool
```

Generated tool schema:
```json
{
  "name": "weather_current",
  "title": "Weather Information",
  "description": "Get current weather information for any location",
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

### Example 2: File Resource
```bash
python3 skills/create-skills/scripts/main.py \
  --name "file-reader" \
  --description "Read and provide file contents" \
  --type resource
```

### Example 3: MCP Server
```bash
python3 skills/create-skills/scripts/main.py \
  --name "todo-server" \
  --description "MCP server for todo list management" \
  --type server \
  --transport stdio
```

---

## MCP Protocol Compliance

This skill generator follows Anthropic's Model Context Protocol specification:

- **JSON-RPC 2.0** message format
- **Lifecycle management** with capability negotiation
- **Three core primitives**: Tools, Resources, Prompts
- **Two transport mechanisms**: stdio and HTTP
- **Proper error handling** with standard error codes
- **Notification support** for real-time updates

---

## Dependencies

- Python 3.8+
- No external dependencies (uses standard library)

---

## License

MIT License - Created for OpenClaw ecosystem

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-23 | Initial release following MCP best practices |

---

*Generated with love by 帅小呆1号 based on Anthropic's "The Complete Guide to Building Skill for Claude"*
