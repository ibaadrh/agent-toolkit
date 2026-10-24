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
- one client's style presented as a default for everyone: caption looks, music timing, fade lengths, speeds,
  grades, video lengths, layouts, fonts, colours, formats, product sizes, scene lines. A config key with no value
  is fine. Additions to allowlists count if they let any of the above through.

Not a hit: the toolkit author's own methods and quality bars, written as general rules and marked as defaults a
client's config can override. Examples: ads test gates and windows (impressions, clicks, spend share, decay,
frequency), test structure and decision-metric order, the rule of three, the author's copy rules (no em dashes,
write the number, "as much as" never "up to", plain words), a loudness target and encode quality, QA intervals,
product-check tolerances, prompting rules (candid mid-moment people with natural skin, reference image prep,
candidate counts), naming conventions, the report format.

The owner has approved these specific author defaults; they are not hits (still flag anything client-specific
inside them, and anything new that is not on this list):
- 4:5 for feed images and 9:16 for vertical video; no added grain;
- the studio folder layout 1 Drop Footage Here, 2 Review, 3 Projects, 4 Final, Brand Kit;
- web breakpoints 390, 768, 1440;
- the default scene composition (product and devices sharp in front, the person behind and out of focus), the
  default prompt order, one named light and lens with generic examples (warm lamp light, soft morning window
  light, 50mm f/2.2), the product at least 10% of the frame;
- the realism fix (natural unretouched skin, the smile reaches the eyes, slightly lower saturation);
- references flattened onto light grey #EDEDED, JPEG, at most 2400 px; at least 6 to 8 candidates per hero;
- Nano Banana Pro at 2K; AI disclosure OPT_IN with no visible AI line; the file naming patterns;
- presenter lines at most about 19 words per 8 seconds; a video ad round of 2 or 3 clips.

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
