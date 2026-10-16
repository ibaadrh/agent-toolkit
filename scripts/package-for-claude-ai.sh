#!/usr/bin/env bash
# Zip every skill for upload to the Claude app (Settings → Skills). Prints which changed since last package.
# Usage: ./scripts/package-for-claude-ai.sh [toolkit]
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"; cd "$HERE"
OUT="dist/claude-ai"; mkdir -p "$OUT"
STAMP="$OUT/.last-package"; last=$(cat "$STAMP" 2>/dev/null || echo "")
filter="${1:-}"
for skill in plugins/*/skills/*/; do
  [[ -n "$filter" && "$skill" != plugins/$filter/* ]] && continue
  name=$(basename "$skill"); zip="$OUT/$name.zip"
  changed="new"
  if [[ -n "$last" ]]; then
    git diff --quiet "$last" -- "$skill" && changed="same" || changed="CHANGED"
  fi
  rm -f "$zip"; (cd "$(dirname "$skill")" && zip -qr "$HERE/$zip" "$name" -x '*.DS_Store')
  echo "$changed  $zip"
done
git rev-parse HEAD > "$STAMP"
echo; echo "Upload the CHANGED/new zips in the Claude app. Config files go into the Project as docs named toolkit/<file>."
