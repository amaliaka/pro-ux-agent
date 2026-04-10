#!/usr/bin/env bash
set -euo pipefail

OPENCODE_SKILLS_DIR="${OPENCODE_SKILLS_DIR:-${HOME}/.config/opencode/skills}"
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_FILE:-${HOME}/.config/opencode/opencode.json}"
LOCAL_SKILL_ROOT="${LOCAL_SKILL_ROOT:-}"
ROOT_SKILL_NAME="${ROOT_SKILL_NAME:-frontend-ai-orchestrator}"
LOCAL_SKILL_NAMES="${LOCAL_SKILL_NAMES:-${ROOT_SKILL_NAME},frontend-scaffold-intake}"

SUPERPOWERS_PLUGIN_NAME="${SUPERPOWERS_PLUGIN_NAME:-superpowers}"
SUPERPOWERS_PLUGIN_REPO="${SUPERPOWERS_PLUGIN_REPO:-https://github.com/obra/superpowers.git}"
SUPERPOWERS_REF="${SUPERPOWERS_REF:-main}"
SUPERPOWERS_PLUGIN_REF="${SUPERPOWERS_PLUGIN_REF:-${SUPERPOWERS_REF}}"

UI_UX_PRO_MAX_REPO_URL="${UI_UX_PRO_MAX_REPO_URL:-https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git}"
UI_UX_PRO_MAX_REF="${UI_UX_PRO_MAX_REF:-main}"
UI_UX_PRO_MAX_CLI_VERSION="${UI_UX_PRO_MAX_CLI_VERSION:-latest}"

IMPECCABLE_REPO_URL="${IMPECCABLE_REPO_URL:-https://github.com/pbakaus/impeccable.git}"
IMPECCABLE_REF="${IMPECCABLE_REF:-main}"

PLAYWRIGHT_CLI_REPO_URL="${PLAYWRIGHT_CLI_REPO_URL:-https://github.com/microsoft/playwright-cli.git}"
PLAYWRIGHT_CLI_REF="${PLAYWRIGHT_CLI_REF:-main}"
PLAYWRIGHT_CLI_VERSION="${PLAYWRIGHT_CLI_VERSION:-latest}"
PLAYWRIGHT_VERSION="${PLAYWRIGHT_VERSION:-latest}"
PLAYWRIGHT_BROWSER_CHANNEL="${PLAYWRIGHT_BROWSER_CHANNEL:-chromium}"

AGENT_BROWSER_REPO_URL="${AGENT_BROWSER_REPO_URL:-https://github.com/vercel-labs/agent-browser.git}"
AGENT_BROWSER_REF="${AGENT_BROWSER_REF:-main}"
AGENT_BROWSER_VERSION="${AGENT_BROWSER_VERSION:-latest}"

INSTALL_RETRY_ATTEMPTS="${INSTALL_RETRY_ATTEMPTS:-3}"
INSTALL_RETRY_DELAY_SECONDS="${INSTALL_RETRY_DELAY_SECONDS:-3}"

WORKDIR="$(mktemp -d)"
SKILL_SOURCE_TRACK_DIR="${WORKDIR}/skill-sources"

log() {
  echo "[install-opencode-skills] $*" >&2
}

warn() {
  echo "[install-opencode-skills] WARNING: $*" >&2
}

fail() {
  echo "[install-opencode-skills] ERROR: $*" >&2
  exit 1
}

cleanup() {
  rm -rf "${WORKDIR}"
}
trap cleanup EXIT

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    fail "Missing required command: ${cmd}"
  fi
}

require_non_negative_int() {
  local name="$1"
  local value="$2"
  case "${value}" in
    ''|*[!0-9]*)
      fail "${name} must be a non-negative integer. Got '${value}'."
      ;;
  esac
}

require_positive_int() {
  local name="$1"
  local value="$2"
  require_non_negative_int "${name}" "${value}"
  if [ "${value}" -lt 1 ]; then
    fail "${name} must be >= 1. Got '${value}'."
  fi
}

check_node_version() {
  local major
  major="$(node -p "process.versions.node.split('.')[0]")"
  if [ "${major}" -lt 18 ]; then
    fail "Node.js 18+ is required. Current version: $(node --version)"
  fi
}

retry_cmd() {
  local attempts="$1"
  local delay="$2"
  shift 2

  local attempt=1
  local status=0
  while true; do
    if "$@"; then
      return 0
    fi
    status=$?
    if [ "${attempt}" -ge "${attempts}" ]; then
      return "${status}"
    fi
    warn "Command failed (attempt ${attempt}/${attempts}): $*"
    attempt=$((attempt + 1))
    sleep "${delay}"
  done
}

npm_global_install() {
  retry_cmd "${INSTALL_RETRY_ATTEMPTS}" "${INSTALL_RETRY_DELAY_SECONDS}" npm install -g "$@"
}

find_system_chromium_executable() {
  local candidate
  for candidate in \
    "${PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH:-}" \
    "/usr/bin/chromium" \
    "/usr/bin/chromium-browser"; do
    [ -n "${candidate}" ] || continue
    if [ -x "${candidate}" ]; then
      echo "${candidate}"
      return 0
    fi
  done

  for candidate in chromium chromium-browser google-chrome-stable google-chrome chrome; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      command -v "${candidate}"
      return 0
    fi
  done
  return 1
}

resolve_shared_chromium_executable() {
  local path

  if [ -n "${AGENT_BROWSER_EXECUTABLE_PATH:-}" ] && [ -x "${AGENT_BROWSER_EXECUTABLE_PATH}" ]; then
    echo "${AGENT_BROWSER_EXECUTABLE_PATH}"
    return 0
  fi
  if [ -n "${PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH:-}" ] && [ -x "${PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH}" ]; then
    echo "${PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH}"
    return 0
  fi

  path="$(find_playwright_chromium_executable || true)"
  if [ -n "${path}" ] && [ -x "${path}" ]; then
    echo "${path}"
    return 0
  fi

  path="$(find_system_chromium_executable || true)"
  if [ -n "${path}" ] && [ -x "${path}" ]; then
    echo "${path}"
    return 0
  fi

  return 1
}

has_browser_runtime() {
  resolve_shared_chromium_executable >/dev/null 2>&1
}

find_playwright_chromium_executable() {
  local base
  local path
  for base in "/root/.cache/ms-playwright" "${HOME}/.cache/ms-playwright"; do
    [ -d "${base}" ] || continue
    path="$(
      find "${base}" -maxdepth 8 -type f -name chrome \
        \( \
          -path '*/chromium-*/chrome-linux/chrome' -o \
          -path '*/chromium-*/chrome-linux-arm64/chrome' -o \
          -path '*/chromium-*/chrome-*/chrome' \
        \) 2>/dev/null | head -n 1 || true
    )"
    if [ -n "${path}" ] && [ -x "${path}" ]; then
      echo "${path}"
      return 0
    fi
  done
  return 1
}

clone_repo() {
  local repo_name="$1"
  local repo_url="$2"
  local repo_ref="$3"
  local destination="${WORKDIR}/${repo_name}"

  rm -rf "${destination}"
  log "Cloning ${repo_name} (${repo_ref}) from ${repo_url}"

  if [ -n "${repo_ref}" ] && git clone --depth 1 --branch "${repo_ref}" "${repo_url}" "${destination}" >/dev/null 2>&1; then
    echo "${destination}"
    return 0
  fi

  if ! git clone --depth 1 "${repo_url}" "${destination}" >/dev/null 2>&1; then
    fail "Failed to clone ${repo_name} from ${repo_url}"
  fi

  if [ -z "${repo_ref}" ]; then
    echo "${destination}"
    return 0
  fi

  if ! git -C "${destination}" fetch --depth 1 origin "${repo_ref}" >/dev/null 2>&1; then
    warn "Depth-1 fetch failed for ${repo_name}@${repo_ref}; retrying without depth limit."
    git -C "${destination}" fetch origin "${repo_ref}" >/dev/null 2>&1 \
      || fail "Failed to fetch ref ${repo_ref} for ${repo_name}"
  fi

  git -C "${destination}" checkout FETCH_HEAD >/dev/null 2>&1 \
    || fail "Failed to checkout ref ${repo_ref} for ${repo_name}"

  echo "${destination}"
}

copy_skill() {
  local source_name="$1"
  local skill_dir="$2"
  local skill_name
  local destination
  local owner_file
  local previous_owner

  skill_name="$(basename "${skill_dir}")"
  destination="${OPENCODE_SKILLS_DIR}/${skill_name}"
  owner_file="${SKILL_SOURCE_TRACK_DIR}/${skill_name}"

  if [ -f "${owner_file}" ]; then
    previous_owner="$(cat "${owner_file}")"
    if [ "${previous_owner}" != "${source_name}" ] && [ "${ALLOW_SKILL_COLLISIONS:-0}" != "1" ]; then
      fail "Skill name collision '${skill_name}' from '${previous_owner}' and '${source_name}'. Set ALLOW_SKILL_COLLISIONS=1 to override."
    fi
  fi

  printf '%s\n' "${source_name}" > "${owner_file}"

  if [ -d "${destination}" ]; then
    log "Replacing existing skill '${skill_name}' from '${source_name}'"
    rm -rf "${destination}"
  fi

  cp -R "${skill_dir}" "${destination}"
  log "Installed '${skill_name}' from '${source_name}'"
}

copy_skills_from_source_dir() {
  local source_name="$1"
  local base_dir="$2"
  local source_rel="$3"
  local source_dir="${base_dir}/${source_rel}"
  local copied=0
  local skill_dir

  if [ ! -d "${source_dir}" ]; then
    return 2
  fi

  log "Loading skills from '${source_name}:${source_rel}' into '${OPENCODE_SKILLS_DIR}'"
  for skill_dir in "${source_dir}"/*; do
    [ -d "${skill_dir}" ] || continue
    [ -f "${skill_dir}/SKILL.md" ] || continue
    copy_skill "${source_name}" "${skill_dir}"
    copied=1
  done

  if [ "${copied}" -eq 0 ]; then
    return 1
  fi

  return 0
}

copy_skills_from_candidates() {
  local source_name="$1"
  local base_dir="$2"
  shift 2
  local candidate
  local found_dir=0

  for candidate in "$@"; do
    if [ -d "${base_dir}/${candidate}" ]; then
      found_dir=1
      if copy_skills_from_source_dir "${source_name}" "${base_dir}" "${candidate}"; then
        return 0
      fi
      warn "Candidate '${source_name}:${candidate}' exists but no valid SKILL.md folders were found."
    fi
  done

  if [ "${found_dir}" -eq 0 ]; then
    warn "No candidate skill directories found for '${source_name}': $*"
    return 2
  fi
  return 1
}

install_repo_skills() {
  local repo_name="$1"
  local repo_url="$2"
  local repo_ref="$3"
  shift 3
  local repo_dir

  repo_dir="$(clone_repo "${repo_name}" "${repo_url}" "${repo_ref}")"
  copy_skills_from_candidates "${repo_name}" "${repo_dir}" "$@" \
    || fail "Could not install skills from ${repo_name} using candidates: $*"
}

configure_superpowers_plugin() {
  local plugin_url="${SUPERPOWERS_PLUGIN_REPO}"
  local plugin_spec

  if [ -n "${SUPERPOWERS_PLUGIN_REF}" ]; then
    plugin_url="${plugin_url}#${SUPERPOWERS_PLUGIN_REF}"
  fi
  plugin_spec="${SUPERPOWERS_PLUGIN_NAME}@git+${plugin_url}"

  mkdir -p "$(dirname "${OPENCODE_CONFIG_FILE}")"

  node - "${OPENCODE_CONFIG_FILE}" "${plugin_spec}" <<'NODE'
const fs = require('fs');

const configPath = process.argv[2];
const pluginSpec = process.argv[3];
let config = {};

if (fs.existsSync(configPath)) {
  try {
    const raw = fs.readFileSync(configPath, 'utf8').trim();
    config = raw ? JSON.parse(raw) : {};
  } catch (error) {
    console.error(`Invalid JSON in ${configPath}: ${error.message}`);
    process.exit(1);
  }
}

if (!config || typeof config !== 'object' || Array.isArray(config)) {
  config = {};
}
if (!Array.isArray(config.plugin)) {
  config.plugin = [];
}
if (!config.plugin.includes(pluginSpec)) {
  config.plugin.push(pluginSpec);
}

fs.writeFileSync(configPath, `${JSON.stringify(config, null, 2)}\n`);
console.log(`Configured Superpowers OpenCode plugin in ${configPath}: ${pluginSpec}`);
NODE
}

install_ui_ux_pro_max_via_cli() {
  local init_dir="${WORKDIR}/ui-ux-pro-max-init"

  log "Installing UI UX Pro Max via official uipro-cli flow"
  npm_global_install "uipro-cli@${UI_UX_PRO_MAX_CLI_VERSION}" >/dev/null \
    || return 1

  mkdir -p "${init_dir}"
  if ! (cd "${init_dir}" && uipro init --ai opencode >/dev/null 2>&1); then
    return 1
  fi

  copy_skills_from_source_dir "ui-ux-pro-max-skill(uipro-cli)" "${init_dir}" ".opencode/skills"
}

install_local_root_skill_if_present() {
  local skill_dir
  local skill_name
  local skill_list
  if [ -z "${LOCAL_SKILL_ROOT}" ]; then
    return 0
  fi

  skill_list="$(printf '%s' "${LOCAL_SKILL_NAMES}" | tr ',' ' ')"
  for skill_name in ${skill_list}; do
    [ -n "${skill_name}" ] || continue
    skill_dir="${LOCAL_SKILL_ROOT}/${skill_name}"
    if [ -f "${skill_dir}/SKILL.md" ]; then
      copy_skill "local-skill" "${skill_dir}"
    else
      warn "Local skill not found at ${skill_dir}; skipping."
    fi
  done
}

configure_shared_browser_executable() {
  local chrome_path

  chrome_path="$(resolve_shared_chromium_executable || true)"
  [ -n "${chrome_path}" ] || return 1

  export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH="${chrome_path}"
  export AGENT_BROWSER_EXECUTABLE_PATH="${chrome_path}"

  if ln -sf "${chrome_path}" /usr/local/bin/chromium-playwright 2>/dev/null; then
    export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH="/usr/local/bin/chromium-playwright"
    export AGENT_BROWSER_EXECUTABLE_PATH="/usr/local/bin/chromium-playwright"
    log "Configured shared Chromium executable (${AGENT_BROWSER_EXECUTABLE_PATH})"
    return 0
  fi

  warn "Unable to create /usr/local/bin/chromium-playwright symlink."
  log "Configured shared Chromium executable (${AGENT_BROWSER_EXECUTABLE_PATH})"
  return 0
}

ensure_agent_browser_daemon_stopped() {
  if ! command -v agent-browser >/dev/null 2>&1; then
    return 0
  fi

  if agent-browser close >/dev/null 2>&1; then
    log "Closed existing agent-browser daemon to apply current browser executable env."
    return 0
  fi

  warn "agent-browser close returned non-zero; continuing."
  return 0
}

install_playwright_stack() {
  if [ "${INSTALL_PLAYWRIGHT_CLI:-1}" != "1" ]; then
    log "Skipping Playwright CLI install because INSTALL_PLAYWRIGHT_CLI=0"
    return 0
  fi

  log "Installing Playwright CLI/runtime npm packages globally"
  npm_global_install "@playwright/cli@${PLAYWRIGHT_CLI_VERSION}" "playwright@${PLAYWRIGHT_VERSION}" >/dev/null \
    || fail "Failed to install Playwright CLI/runtime npm packages."

  command -v playwright >/dev/null 2>&1 || fail "Playwright CLI was not found after npm installation."

  if command -v playwright-cli >/dev/null 2>&1; then
    log "Running playwright-cli skill installer"
    if ! playwright-cli install --skills; then
      warn "playwright-cli skill installer failed; continuing because skills were copied directly."
    fi
  fi

  configure_shared_browser_executable || true

  if [ "${INSTALL_PLAYWRIGHT_BROWSER:-1}" = "1" ]; then
    if [ "${PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD:-0}" = "1" ]; then
      configure_shared_browser_executable \
        || fail "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 but no Chromium executable was found."
      log "Skipping Playwright browser download; using ${PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH}"
      return 0
    fi

    if command -v apt-get >/dev/null 2>&1; then
      log "Installing Playwright browser (${PLAYWRIGHT_BROWSER_CHANNEL}) with Linux deps"
      if ! playwright install --with-deps "${PLAYWRIGHT_BROWSER_CHANNEL}"; then
        warn "Playwright browser install with --with-deps failed; retrying without --with-deps."
        playwright install "${PLAYWRIGHT_BROWSER_CHANNEL}" \
          || fail "Failed to install Playwright browser/runtime prerequisites."
      fi
    else
      log "Installing Playwright browser (${PLAYWRIGHT_BROWSER_CHANNEL})"
      playwright install "${PLAYWRIGHT_BROWSER_CHANNEL}" \
        || fail "Failed to install Playwright browser/runtime prerequisites."
    fi
  fi

  configure_shared_browser_executable || true
}

install_agent_browser_stack() {
  if [ "${INSTALL_AGENT_BROWSER_CLI:-1}" != "1" ]; then
    log "Skipping agent-browser CLI install because INSTALL_AGENT_BROWSER_CLI=0"
    return 0
  fi

  log "Installing agent-browser CLI globally"
  npm_global_install "agent-browser@${AGENT_BROWSER_VERSION}" >/dev/null \
    || fail "Failed to install agent-browser npm package."

  command -v agent-browser >/dev/null 2>&1 || fail "agent-browser CLI was not found after npm installation."

  # Known upstream behavior: AGENT_BROWSER_EXECUTABLE_PATH can be ignored when
  # an existing daemon process is already running.
  ensure_agent_browser_daemon_stopped

  # Re-check after Playwright install and after agent-browser CLI install to make
  # single-browser reuse deterministic in both Docker and local environments.
  configure_shared_browser_executable || true

  if has_browser_runtime; then
    log "Detected existing browser runtime; skipping explicit agent-browser runtime install."
    return 0
  fi

  log "Installing agent-browser Chrome runtime"
  if retry_cmd "${INSTALL_RETRY_ATTEMPTS}" "${INSTALL_RETRY_DELAY_SECONDS}" agent-browser install; then
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    fail "Failed to install agent-browser runtime prerequisites."
  fi

  warn "agent-browser install failed; refreshing apt metadata and retrying with Linux deps."
  apt-get update >/dev/null
  retry_cmd "${INSTALL_RETRY_ATTEMPTS}" "${INSTALL_RETRY_DELAY_SECONDS}" agent-browser install --with-deps \
    || fail "Failed to install agent-browser runtime prerequisites."
}

preflight_checks() {
  require_positive_int "INSTALL_RETRY_ATTEMPTS" "${INSTALL_RETRY_ATTEMPTS}"
  require_non_negative_int "INSTALL_RETRY_DELAY_SECONDS" "${INSTALL_RETRY_DELAY_SECONDS}"

  require_cmd git
  require_cmd node
  require_cmd npm
  require_cmd python3
  check_node_version

  mkdir -p "${OPENCODE_SKILLS_DIR}" "${SKILL_SOURCE_TRACK_DIR}"
}

install_skills_phase() {
  log "Phase 1/3: installing skills"

  install_repo_skills "superpowers" "${SUPERPOWERS_PLUGIN_REPO}" "${SUPERPOWERS_REF}" "skills" ".opencode/skills"
  configure_superpowers_plugin

  if ! install_ui_ux_pro_max_via_cli; then
    warn "uipro-cli install path failed; falling back to repository skill copy."
    install_repo_skills "ui-ux-pro-max-skill" "${UI_UX_PRO_MAX_REPO_URL}" "${UI_UX_PRO_MAX_REF}" ".opencode/skills" ".claude/skills"
  fi

  install_repo_skills "impeccable" "${IMPECCABLE_REPO_URL}" "${IMPECCABLE_REF}" ".opencode/skills" ".claude/skills"
  install_repo_skills "playwright-cli" "${PLAYWRIGHT_CLI_REPO_URL}" "${PLAYWRIGHT_CLI_REF}" "skills" ".opencode/skills"
  install_repo_skills "agent-browser" "${AGENT_BROWSER_REPO_URL}" "${AGENT_BROWSER_REF}" "skills" ".opencode/skills"

  install_local_root_skill_if_present
}

install_runtime_phase() {
  log "Phase 2/3: installing runtime tooling"
  install_playwright_stack
  install_agent_browser_stack
}

finalize_phase() {
  log "Phase 3/3: finalizing"
  configure_shared_browser_executable || true

  log "All requested skills are installed in: ${OPENCODE_SKILLS_DIR}"
}

main() {
  preflight_checks
  install_skills_phase
  install_runtime_phase
  finalize_phase
}

main "$@"
