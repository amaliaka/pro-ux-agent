#!/usr/bin/env bash
set -euo pipefail

OPENCODE_CONFIG_DIR="${OPENCODE_CONFIG_DIR:-${HOME}/.config/opencode}"
OPENCODE_CONFIG_FILE="${OPENCODE_CONFIG_FILE:-${OPENCODE_CONFIG_DIR}/opencode.json}"
OPENCODE_SKILLS_DIR="${OPENCODE_SKILLS_DIR:-${OPENCODE_CONFIG_DIR}/skills}"
OPENCODE_PLUGINS_DIR="${OPENCODE_PLUGINS_DIR:-${OPENCODE_CONFIG_DIR}/plugins}"
SKILLS_SEED_DIR="${SKILLS_SEED_DIR:-/opt/opencode-skills-seed}"
PLUGINS_SEED_DIR="${PLUGINS_SEED_DIR:-/opt/opencode-plugins-seed}"
CONFIG_SEED_FILE="${CONFIG_SEED_FILE:-/opt/opencode-config-seed/opencode.json}"

if [ ! -d "${SKILLS_SEED_DIR}" ]; then
  echo "Seed skills directory not found: ${SKILLS_SEED_DIR}" >&2
  exit 1
fi

mkdir -p "${OPENCODE_CONFIG_DIR}" "${OPENCODE_SKILLS_DIR}"

copied=0
for seed_skill in "${SKILLS_SEED_DIR}"/*; do
  [ -d "${seed_skill}" ] || continue
  skill_name="$(basename "${seed_skill}")"
  target="${OPENCODE_SKILLS_DIR}/${skill_name}"
  if [ ! -d "${target}" ]; then
    cp -R "${seed_skill}" "${target}"
    echo "Seeded missing skill: ${skill_name}"
    copied=1
  fi
done

if [ -d "${PLUGINS_SEED_DIR}" ]; then
  mkdir -p "${OPENCODE_PLUGINS_DIR}"
  for seed_plugin in "${PLUGINS_SEED_DIR}"/*; do
    [ -f "${seed_plugin}" ] || continue
    plugin_name="$(basename "${seed_plugin}")"
    target="${OPENCODE_PLUGINS_DIR}/${plugin_name}"
    if [ ! -f "${target}" ]; then
      cp "${seed_plugin}" "${target}"
      echo "Seeded missing plugin: ${plugin_name}"
      copied=1
    fi
  done
fi

if [ -f "${CONFIG_SEED_FILE}" ]; then
  changed="$(node - "${CONFIG_SEED_FILE}" "${OPENCODE_CONFIG_FILE}" <<'NODE'
const fs = require('fs');

const seedPath = process.argv[2];
const targetPath = process.argv[3];

function readJson(path, fallback) {
  if (!fs.existsSync(path)) {
    return fallback;
  }

  const raw = fs.readFileSync(path, 'utf8').trim();
  if (!raw) {
    return fallback;
  }

  const parsed = JSON.parse(raw);
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
    return fallback;
  }

  return parsed;
}

function mergeMissing(seed, target) {
  if (Array.isArray(seed)) {
    const next = Array.isArray(target) ? target.slice() : [];
    const seen = new Set(next.map((item) => JSON.stringify(item)));
    for (const item of seed) {
      const key = JSON.stringify(item);
      if (!seen.has(key)) {
        next.push(item);
        seen.add(key);
      }
    }
    return next;
  }

  if (seed && typeof seed === 'object') {
    const next =
      target && typeof target === 'object' && !Array.isArray(target)
        ? { ...target }
        : {};

    for (const [key, value] of Object.entries(seed)) {
      if (key in next) {
        next[key] = mergeMissing(value, next[key]);
      } else {
        next[key] = value;
      }
    }
    return next;
  }

  return target === undefined ? seed : target;
}

const seed = readJson(seedPath, {});
const target = readJson(targetPath, {});
const merged = mergeMissing(seed, target);
const output = `${JSON.stringify(merged, null, 2)}\n`;
const previous = fs.existsSync(targetPath) ? fs.readFileSync(targetPath, 'utf8') : '';

if (previous !== output) {
  fs.writeFileSync(targetPath, output);
  process.stdout.write('changed');
}
NODE
)"
  if [ "${changed}" = "changed" ]; then
    echo "Merged bundled OpenCode config defaults into ${OPENCODE_CONFIG_FILE}"
    copied=1
  fi
fi

if [ "${copied}" -eq 0 ]; then
  echo "OpenCode seed assets already present in ${OPENCODE_CONFIG_DIR}"
fi
