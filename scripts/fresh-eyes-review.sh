#!/usr/bin/env bash
# Fresh-eyes review: a separate agent that has not seen any session reads only the diff and says whether anything
# in it could come from or identify a client, or presents a client's style as a general default.
# Usage: ./scripts/fresh-eyes-review.sh <git diff range, e.g. origin/main..main or <base> <head>>
# Exits 0 only on "VERDICT: CLEAN". Any hit, an unclear answer, or no reviewer available blocks (exit 1).
# The pre-push guard runs it for every push that touches skills, templates, docs, prompts or the allowlists.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"; cd "$HERE"
(( $# )) || { sed -n '2,6p' "$0"; exit 2; }
PATHS=(plugins templates docs prompts README.md AGENTS.md CLAUDE.md scripts/allowed-names.txt scripts/allowed-domains.txt scripts/allowed-terms.txt)

diff=$(git diff --no-color --unified=3 "$@" -- "${PATHS[@]}")
[[ -z "$diff" ]] && { echo "fresh-eyes: no changes to skills, templates, docs, prompts or allowlists; skipped"; exit 0; }
command -v claude >/dev/null || { echo "fresh-eyes: the claude CLI is not on PATH, so nobody reviewed this diff. Push blocked."; exit 1; }

read -r -d '' QUESTION <<'EOF'
You are reviewing a diff to a PUBLIC repository of general-purpose AI agent skills. You have no other context.
Read only the diff below and answer one question:

Could anything here come from or identify a specific client, company, product, person, account, price,
measurement, place or event, or is any client's style presented as a general default?

Count as a hit:
- a name of a client, company, brand, product, person, account, store, place or event that is not a public tool or
  platform (public tools and platforms such as Claude, Meta, Shopify, Firefly, Google, Kdenlive are fine);
- a specific price, measurement, ID, date, phone number, email or URL that looks like it came from client work
  rather than from public documentation or a plain made-up example;
- an incident story with client details (what happened to whom, when, with which numbers);
- a style choice presented as a default for everyone: speeds, grades, music timing, fade lengths, caption looks,
  video lengths, layouts, fonts, colours, word counts, formats, thresholds. A config key with no value is fine;
  a value filled in for everyone is a hit. Additions to allowlists count if they let any of the above through.

List every hit as "- <file>: <the exact text> (why)". Then end with exactly one last line:
VERDICT: CLEAN    (nothing found)
VERDICT: BLOCK    (one or more hits)
EOF

work=$(mktemp -d); trap 'rm -rf "$work"' EXIT
echo "fresh-eyes: reviewing $(printf '%s\n' "$diff" | wc -l | tr -d ' ') diff lines with a fresh agent..."
answer=$(cd "$work" && { printf '%s\n\n--- DIFF ---\n' "$QUESTION"; printf '%s\n' "$diff"; } \
         | claude -p --tools "" --no-session-persistence --strict-mcp-config 2>&1) || {
  echo "$answer"; echo "fresh-eyes: the reviewer did not run. Push blocked."; exit 1; }
echo "$answer"
last=$(printf '%s\n' "$answer" | grep -E '^VERDICT: (CLEAN|BLOCK)' | tail -1)
[[ "$last" == "VERDICT: CLEAN" ]] && { echo "fresh-eyes: clean"; exit 0; }
echo "fresh-eyes: blocked. Fix the content above (never weaken the guard or its lists to get through)."
exit 1
