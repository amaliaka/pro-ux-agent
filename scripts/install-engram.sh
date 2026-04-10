#!/usr/bin/env bash
set -euo pipefail

ENGRAM_REPO="${ENGRAM_REPO:-Gentleman-Programming/engram}"
ENGRAM_VERSION="${ENGRAM_VERSION:-latest}"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"

log() {
  echo "[install-engram] $*" >&2
}

fail() {
  echo "[install-engram] ERROR: $*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "${cmd}" >/dev/null 2>&1 || fail "Missing required command: ${cmd}"
}

detect_os() {
  case "$(uname -s)" in
    Linux)
      echo "linux"
      ;;
    *)
      fail "Unsupported OS for engram binary install: $(uname -s)"
      ;;
  esac
}

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)
      echo "amd64"
      ;;
    aarch64|arm64)
      echo "arm64"
      ;;
    *)
      fail "Unsupported architecture for engram binary install: $(uname -m)"
      ;;
  esac
}

resolve_release_api() {
  if [ "${ENGRAM_VERSION}" = "latest" ]; then
    printf 'https://api.github.com/repos/%s/releases/latest\n' "${ENGRAM_REPO}"
  else
    printf 'https://api.github.com/repos/%s/releases/tags/%s\n' "${ENGRAM_REPO}" "${ENGRAM_VERSION}"
  fi
}

main() {
  require_cmd curl
  require_cmd node
  require_cmd tar

  local os
  local arch
  local tmpdir
  local release_json
  local asset_pattern
  local asset_url
  local binary_path

  os="$(detect_os)"
  arch="$(detect_arch)"
  tmpdir="$(mktemp -d)"
  release_json="${tmpdir}/release.json"

  trap "rm -rf -- '${tmpdir}'" EXIT

  log "Resolving engram release metadata for ${os}/${arch} (${ENGRAM_VERSION})"
  curl -fsSL "$(resolve_release_api)" -o "${release_json}"

  asset_pattern="^engram_.+_${os}_${arch}\\.tar\\.gz$"
  asset_url="$(node - "${release_json}" "${asset_pattern}" <<'NODE'
const fs = require('fs');

const releasePath = process.argv[2];
const pattern = new RegExp(process.argv[3]);
const release = JSON.parse(fs.readFileSync(releasePath, 'utf8'));
const assets = Array.isArray(release.assets) ? release.assets : [];

const match = assets.find((asset) => typeof asset.name === 'string' && pattern.test(asset.name));
if (!match || typeof match.browser_download_url !== 'string') {
  process.exit(1);
}

process.stdout.write(match.browser_download_url);
NODE
)" || fail "Could not find a release asset matching ${asset_pattern}"

  log "Downloading ${asset_url}"
  curl -fsSL "${asset_url}" -o "${tmpdir}/engram.tgz"
  tar -xzf "${tmpdir}/engram.tgz" -C "${tmpdir}"

  binary_path="${tmpdir}/engram"
  [ -f "${binary_path}" ] || fail "Expected engram binary was not found after extraction"

  mkdir -p "${INSTALL_DIR}"
  install -m 0755 "${binary_path}" "${INSTALL_DIR}/engram"

  log "Installed $( "${INSTALL_DIR}/engram" version 2>/dev/null || echo 'engram' ) to ${INSTALL_DIR}/engram"
}

main "$@"
