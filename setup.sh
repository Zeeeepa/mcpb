#!/bin/bash
set -e

export SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
export MCP_DIR="$SCRIPT_DIR/mcp-servers"

mkdir -p "$MCP_DIR"

cd "$MCP_DIR"

if [ ! -d "athena-protocol" ]; then
  git clone https://github.com/Zeeeepa/athena-protocol.git
fi

if [ ! -d "mercury-spec-ops" ]; then
  git clone https://github.com/n0zer0d4y/mercury-spec-ops.git
fi

cd athena-protocol
npm install
npm run build
if [ ! -f .env ]; then
  cp .env.example .env 2>/dev/null || true
fi

cd "$MCP_DIR/mercury-spec-ops"
npm install
npm run build

cat > "$SCRIPT_DIR/mcp.json" << EOF
{
  "mcpServers": {
    "athena-protocol": {
      "command": "node",
      "args": ["$MCP_DIR/athena-protocol/dist/index.js"],
      "type": "stdio",
      "timeout": 300,
      "env": {
        "DEFAULT_LLM_PROVIDER": "anthropic",
        "ANTHROPIC_API_KEY": "YOUR_API_KEY_HERE"
      }
    },
    "mercury-spec-ops": {
      "command": "node",
      "args": ["$MCP_DIR/mercury-spec-ops/dist/src/server.js"],
      "type": "stdio",
      "timeout": 120
    }
  }
}
EOF

