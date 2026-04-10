#!/usr/bin/env bash
set -euo pipefail

OMO_PACKAGE="${OMO_PACKAGE:-oh-my-opencode}"
OMO_VERSION="${OMO_VERSION:-latest}"
OMO_CLAUDE="${OMO_CLAUDE:-no}"
OMO_OPENAI="${OMO_OPENAI:-${OMO_CHATGPT:-no}}"
OMO_GEMINI="${OMO_GEMINI:-no}"
OMO_COPILOT="${OMO_COPILOT:-no}"
CLI_ARGS=("$@")

log() {
  echo "[install-oh-my-openagent] $*" >&2
}

fail() {
  echo "[install-oh-my-openagent] ERROR: $*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    fail "Missing required command: ${cmd}"
  fi
}

detect_libc() {
  if ! command -v ldd >/dev/null 2>&1; then
    return 1
  fi

  if ldd --version 2>&1 | grep -qi musl; then
    echo "musl"
    return 0
  fi

  if ldd --version 2>&1 | grep -Eqi 'glibc|gnu libc|gnu c library'; then
    echo "glibc"
    return 0
  fi

  return 1
}

require_choice() {
  local name="$1"
  local value="$2"
  shift 2
  local choice
  for choice in "$@"; do
    if [ "${value}" = "${choice}" ]; then
      return 0
    fi
  done
  fail "${name} must be one of: $* (got '${value}')"
}

require_cmd npx

# Upstream still documents the installer package as `oh-my-opencode`
# even after the repository rename to `oh-my-openagent`.
require_choice "OMO_CLAUDE" "${OMO_CLAUDE}" yes no max20
require_choice "OMO_OPENAI" "${OMO_OPENAI}" yes no
require_choice "OMO_GEMINI" "${OMO_GEMINI}" yes no
require_choice "OMO_COPILOT" "${OMO_COPILOT}" yes no

libc_family="$(detect_libc || true)"
if [ "${libc_family}" = "musl" ]; then
  fail "Oh My OpenAgent is not currently installable in this Alpine/musl image because its @ast-grep/cli dependency only publishes GNU libc Linux binaries. Use a glibc-based image for the OMO variant, or install OMO outside this Alpine container."
fi

log "Installing optional Oh My OpenAgent layer via ${OMO_PACKAGE}@${OMO_VERSION}"
if [ "${#CLI_ARGS[@]}" -gt 0 ]; then
  npx --yes "${OMO_PACKAGE}@${OMO_VERSION}" "${CLI_ARGS[@]}"
else
  npx --yes "${OMO_PACKAGE}@${OMO_VERSION}" install \
    --no-tui \
    --claude="${OMO_CLAUDE}" \
    --openai="${OMO_OPENAI}" \
    --gemini="${OMO_GEMINI}" \
    --copilot="${OMO_COPILOT}" \
    --skip-auth
fi
