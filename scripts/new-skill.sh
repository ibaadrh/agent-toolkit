#!/usr/bin/env bash
# Create a new skill folder from the template.  Usage: ./scripts/new-skill.sh <toolkit> <skill-name>
set -euo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
tk="$1"; name="$2"; dst="$HERE/plugins/$tk/skills/$name"
[[ -d "$HERE/plugins/$tk" ]] || { echo "no toolkit $tk"; exit 1; }
[[ -e "$dst" ]] && { echo "exists: $dst"; exit 1; }
mkdir -p "$dst/references" "$dst/scripts"
sed "s/skill-name-here/$name/; s/# Skill name/# $name/" "$HERE/templates/skill/SKILL.md" > "$dst/SKILL.md"
echo "created $dst. Edit SKILL.md, then add a row to plugins/$tk/README.md"
