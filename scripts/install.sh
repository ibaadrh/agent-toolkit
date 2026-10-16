#!/usr/bin/env bash
# Install the whole toolkit into Claude Code on this machine.
# Usage: ./scripts/install.sh [--local] [--with-third-party]
#   --local             install from this checkout instead of GitHub (for development)
#   --with-third-party  also run scripts/install-third-party.sh (the tools in use; see docs/THIRD-PARTY.md)
set -euo pipefail
MARKET="ibaad-toolkit"
REPO="ibaadrh/agent-toolkit"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
LOCAL=0; THIRD=0
for a in "$@"; do
  case "$a" in
    --local) LOCAL=1 ;;
    --with-third-party) THIRD=1 ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "unknown option: $a"; exit 2 ;;
  esac
done

if (( LOCAL )); then
  claude plugin marketplace add "$HERE" || true
else
  claude plugin marketplace add "$REPO" || true
fi
claude plugin marketplace update "$MARKET" || true

for p in core video-production website-development app-development engineering-3d-printing digital-marketing; do
  claude plugin install "$p@$MARKET" || echo "skip $p"
done

# Push guard for this checkout: scripts/hooks/pre-push runs validate.sh and scan-history.sh before every push.
if git -C "$HERE" rev-parse --git-dir >/dev/null 2>&1; then
  git -C "$HERE" config core.hooksPath scripts/hooks && echo "push guard on (core.hooksPath = scripts/hooks)"
fi

# Personal attribution: commits are yours, not the tool's.
SETTINGS="$HOME/.claude/settings.json"
if command -v jq >/dev/null && [[ -f "$SETTINGS" ]]; then
  tmp=$(mktemp); jq '.attribution = {commit: "", pr: ""}' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  echo "attribution disabled in $SETTINGS"
else
  echo 'Add to ~/.claude/settings.json:  "attribution": { "commit": "", "pr": "" }'
fi
if (( THIRD )); then
  "$HERE/scripts/install-third-party.sh"
else
  echo "Third-party tools: ./scripts/install.sh --with-third-party, or see docs/THIRD-PARTY.md."
fi
echo "Done. Run /reload-plugins inside Claude Code."
