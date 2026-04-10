#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "[install-container-packages] ERROR: provide at least one package name" >&2
  exit 1
fi

if command -v apt-get >/dev/null 2>&1; then
  apt-get update
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
  rm -rf /var/lib/apt/lists/*
  exit 0
fi

if command -v apk >/dev/null 2>&1; then
  # Some images need Alpine-only compatibility packages like gcompat.
  if [ -n "${APK_EXTRA_PACKAGES:-}" ]; then
    # shellcheck disable=SC2086
    apk add --no-cache $APK_EXTRA_PACKAGES "$@"
  else
    apk add --no-cache "$@"
  fi
  exit 0
fi

echo "[install-container-packages] ERROR: unsupported base image: expected apt-get or apk" >&2
exit 1
