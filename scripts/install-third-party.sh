#!/usr/bin/env bash
# Install the third-party tools listed in docs/THIRD-PARTY.md. Safe to run again.
# Usage: ./scripts/install-third-party.sh [--recommended] [--dry-run]
#   (no flag)       the tools in use: plugins, LSPs and MCP servers that need no key
#   --recommended   also the tools in the "Recommended" table
#   --dry-run       print every command, run nothing
# Clones go to $THIRD_PARTY_DIR (default ~/.claude/third-party).
# MCP servers that need a key are never installed; the list at the end says which key each needs.
set -uo pipefail
MARKET="ibaad-toolkit"
OFFICIAL="claude-plugins-official"
SKILLS_CLI="skills@1.7.2"
DIR="${THIRD_PARTY_DIR:-$HOME/.claude/third-party}"
RECOMMENDED=0; DRY=0
for a in "$@"; do
  case "$a" in
    --recommended) RECOMMENDED=1 ;;
    --dry-run) DRY=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "unknown option: $a"; exit 2 ;;
  esac
done

run() { echo "+ $*"; (( DRY )) && return 0; "$@" || echo "  failed, continuing"; }
need() { command -v "$1" >/dev/null && return 0; echo "skip: '$1' is not installed"; return 1; }

plugin() {   # plugin <name@marketplace>. Skips a plugin installed from any marketplace or synced from the Claude app.
  local name="${1%@*}"
  if claude plugin list 2>/dev/null | grep -qE "(^|[^a-z0-9-])$name@"; then echo "= $name already installed"; return; fi
  if compgen -G "$HOME/.claude/plugins/synced/*/$name" >/dev/null || compgen -G "$HOME/.claude/plugins/synced/*/$name~*" >/dev/null; then
    echo "= $name comes from your Claude app account"; return
  fi
  if [[ -f "$HOME/.claude/skills/$name/SKILL.md" ]]; then
    echo "= $name is already a standalone skill in ~/.claude/skills (remove it there to switch to the plugin)"; return
  fi
  run claude plugin install "$1"
}
mcp() {      # mcp <name> <claude mcp add args...>
  local name="$1"; shift
  if claude mcp get "$name" >/dev/null 2>&1; then echo "= mcp $name already added"; return; fi
  run claude mcp add --scope user "$@"
}
npx_skills() {   # npx_skills <owner/repo>
  need npx || return 0
  run npx -y "$SKILLS_CLI" add "$1" -g -a claude-code -y
}
clone_at() {     # clone_at <owner/repo> <sha> <setup command, run inside the clone, may be empty>
  need git || return 0
  local dest="$DIR/${1#*/}"
  if [[ -d "$dest/.git" ]]; then run git -C "$dest" fetch -q origin; else run git clone -q "https://github.com/$1.git" "$dest"; fi
  run git -C "$dest" checkout -q --detach "$2"
  if [[ -n "$3" ]]; then echo "+ (cd $dest && $3)"; (( DRY )) || (cd "$dest" && eval "$3") || echo "  failed, continuing"; fi
}

need claude || exit 1
(( DRY )) || mkdir -p "$DIR"

echo "== marketplaces"
claude plugin marketplace list 2>/dev/null | grep -q "$MARKET" \
  || { echo "The $MARKET marketplace is not added. Run ./scripts/install.sh first."; exit 1; }
run claude plugin marketplace update "$MARKET"
claude plugin marketplace list 2>/dev/null | grep -q "$OFFICIAL" || run claude plugin marketplace add "anthropics/$OFFICIAL"

echo "== in use"
for p in replica-skill taste-skill ui-ux-pro-max wix brightdata-plugin; do plugin "$p@$MARKET"; done
plugin "clangd-lsp@$OFFICIAL"
plugin "swift-lsp@$OFFICIAL"
mcp figma --transport http figma https://mcp.figma.com/mcp

if (( RECOMMENDED )); then
  echo "== recommended: plugins"
  for p in runway-api impeccable shopify-plugin android-reverse-engineering expo android-skills \
           aso-skills flutter-all text-to-cad superpowers andrej-karpathy-skills marketing-skills; do
    plugin "$p@$MARKET"
  done
  # Their names start with "claude-", which is reserved in other marketplaces, so they install from their own.
  run claude plugin marketplace add AgriciDaniel/claude-seo; plugin "claude-seo@agricidaniel-claude-seo"
  run claude plugin marketplace add AgriciDaniel/claude-ads; plugin "claude-ads@ai-marketing-hub-claude-ads"
  # Not in our marketplace: its hook event is spelled "preToolUse", so Claude Desktop skips it (see docs/THIRD-PARTY.md).
  run claude plugin marketplace add educlopez/ui-craft; plugin "ui-craft@ui-craft"

  echo "== recommended: skills via npx"
  for r in remotion-dev/skills ychoi-kr/claude-ffmpeg-skill truongduy2611/app-store-preflight-skills realkimbarrett/advertising-skills; do
    npx_skills "$r"
  done

  echo "== recommended: MCP servers without a key"
  need uvx && mcp blender blender -- uvx blender-mcp==2.0.0
  need uvx && mcp freecad freecad -- uvx freecad-mcp==0.1.27
  need npx && mcp shopify-dev-mcp shopify-dev-mcp -- npx -y @shopify/dev-mcp@1.17.0

  echo "== recommended: clones (in $DIR)"
  need uv && clone_at digitalsamba/claude-code-video-toolkit 959e0fc6c20210832078781e49daa7384cebb293 "uv sync"
  clone_at zubair-trabzada/geo-seo-claude 989cae01e8ebbc42a9ec798eb9e7cb423f5ec89c "./install.sh"
  clone_at mixelpixx/KiCAD-MCP-Server cbb59a6203997f5e916be7e0480d63fe5519134a ""
fi

cat <<EOF

Done. Run /reload-plugins inside Claude Code.

Manual steps:
- Website cloner: it is a template, one copy per site.
  gh repo create <name> --private --template JCodesMore/ai-website-cloner-template --clone
EOF
if (( RECOMMENDED )); then cat <<EOF
- Blender and FreeCAD MCP: install each app's addon from its repo before first use.
- KiCad MCP: run ./setup-macos.sh in $DIR/KiCAD-MCP-Server, then add it to the MCP config as its README says.
- claude-code-video-toolkit: open it in Claude Code and run /setup.
- impeccable: run /impeccable init once in each project.
EOF
fi
cat <<'EOF'

Not installed, because each needs a key or a device secret:
- google-analytics-mcp: Google Application Default Credentials with the analytics.readonly scope, and GOOGLE_PROJECT_ID.
- Nano-Banana-MCP: GEMINI_API_KEY.
- bambu-printer-mcp: the printer's IP address, serial number and LAN access code.
- Bright Data CLI and MCP (the plugin itself is installed): BRIGHTDATA_API_KEY, or run `bdata login`.
- Runway (if you installed runway-api): RUNWAYML_API_SECRET.
The exact install lines are in docs/THIRD-PARTY.md.
EOF
