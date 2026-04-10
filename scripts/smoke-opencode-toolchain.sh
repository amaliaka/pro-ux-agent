#!/usr/bin/env bash
set -euo pipefail

log() {
  echo "[smoke-opencode-toolchain] $*" >&2
}

fail() {
  echo "[smoke-opencode-toolchain] ERROR: $*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "${cmd}" >/dev/null 2>&1 || fail "Missing required command: ${cmd}"
}

assert_executable() {
  local path="$1"
  [ -x "${path}" ] || fail "Expected executable not found: ${path}"
}

main() {
  require_cmd opencode
  require_cmd engram
  require_cmd node
  require_cmd npm
  require_cmd python3
  require_cmd playwright
  require_cmd agent-browser

  local expected_browser="${PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH:-/usr/bin/chromium}"
  local agent_browser_path="${AGENT_BROWSER_EXECUTABLE_PATH:-${expected_browser}}"
  local opencode_config_dir="${HOME}/.config/opencode"
  local opencode_config_file="${opencode_config_dir}/opencode.json"
  local engram_plugin_file="${opencode_config_dir}/plugins/engram.ts"

  assert_executable "${expected_browser}"
  assert_executable "${agent_browser_path}"
  assert_executable /usr/local/bin/engram
  [ -f "${engram_plugin_file}" ] || fail "Expected Engram OpenCode plugin not found: ${engram_plugin_file}"
  [ -f "${opencode_config_file}" ] || fail "Expected OpenCode config not found: ${opencode_config_file}"

  node - "${opencode_config_file}" <<'NODE' >/dev/null || fail "OpenCode config is missing the engram MCP server entry."
const fs = require('fs');
const configPath = process.argv[2];
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const engram = config?.mcp?.engram;

if (
  !engram ||
  engram.type !== 'local' ||
  !Array.isArray(engram.command) ||
  engram.command[0] !== 'engram' ||
  engram.command[1] !== 'mcp'
) {
  process.exit(1);
}
NODE

  log "OpenCode: $(opencode --version 2>/dev/null || echo 'version command unavailable')"
  log "Engram: $(engram version 2>/dev/null || echo 'version command unavailable')"
  log "Node: $(node --version)"
  log "Python: $(python3 --version)"
  log "Playwright: $(playwright --version)"
  log "agent-browser: $(agent-browser --version)"
  log "Shared browser path (playwright): ${expected_browser}"
  log "Shared browser path (agent-browser): ${agent_browser_path}"
  log "Engram data dir: ${ENGRAM_DATA_DIR:-${HOME}/.engram}"

  if [ "${agent_browser_path}" != "${expected_browser}" ]; then
    fail "Browser executable mismatch between Playwright and agent-browser."
  fi

  # Ensure fresh env picks up executable path in known daemon-caching scenarios.
  if agent-browser close >/dev/null 2>&1; then
    log "Closed running agent-browser daemon."
  else
    log "No running agent-browser daemon found."
  fi

  log "Smoke check passed."
}

main "$@"
