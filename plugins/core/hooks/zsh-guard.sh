#!/bin/sh
# Claude Code PreToolUse hook. Passes the event to the portable zsh guard; exit 2 refuses the command.
# Never blocks when python3 is missing. The guard itself only acts when $SHELL is zsh.
command -v python3 >/dev/null 2>&1 || exit 0
exec python3 -I "$(dirname "$0")/../skills/shell-safety-guard/scripts/zsh-guard.py" --hook
