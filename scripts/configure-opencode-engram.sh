#!/usr/bin/env bash
set -euo pipefail

OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_FILE:-${HOME}/.config/opencode/opencode.json}"

mkdir -p "$(dirname "${OPENCODE_CONFIG_FILE}")"

node - "${OPENCODE_CONFIG_FILE}" <<'NODE'
const fs = require('fs');

const configPath = process.argv[2];
let config = {};

if (fs.existsSync(configPath)) {
  const raw = fs.readFileSync(configPath, 'utf8').trim();
  config = raw ? JSON.parse(raw) : {};
}

if (!config || typeof config !== 'object' || Array.isArray(config)) {
  config = {};
}
if (!config.mcp || typeof config.mcp !== 'object' || Array.isArray(config.mcp)) {
  config.mcp = {};
}

config.mcp.engram = {
  type: 'local',
  command: ['engram', 'mcp'],
  enabled: true
};

fs.writeFileSync(configPath, `${JSON.stringify(config, null, 2)}\n`);
NODE
