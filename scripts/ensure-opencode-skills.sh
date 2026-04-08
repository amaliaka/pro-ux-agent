#!/usr/bin/env bash
set -euo pipefail

OPENCODE_SKILLS_DIR="${OPENCODE_SKILLS_DIR:-${HOME}/.config/opencode/skills}"
SKILLS_SEED_DIR="${SKILLS_SEED_DIR:-/opt/opencode-skills-seed}"

if [ ! -d "${SKILLS_SEED_DIR}" ]; then
  echo "Seed skills directory not found: ${SKILLS_SEED_DIR}" >&2
  exit 1
fi

mkdir -p "${OPENCODE_SKILLS_DIR}"

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

if [ "${copied}" -eq 0 ]; then
  echo "All seed skills already present in ${OPENCODE_SKILLS_DIR}"
fi
