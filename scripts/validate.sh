#!/usr/bin/env bash
# Validate the marketplace, every plugin, and every SKILL.md. Also scan for client data that must not be here.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"; cd "$HERE"
fail=0

echo "== plugin validate"
claude plugin validate . || fail=1

echo "== skill frontmatter"
while IFS= read -r f; do
  name=$(sed -n 's/^name: *//p' "$f" | head -1)
  dir=$(basename "$(dirname "$f")")
  [[ "$name" == "$dir" ]] || { echo "name '$name' != folder '$dir' in $f"; fail=1; }
  grep -q '^description:' "$f" || { echo "no description in $f"; fail=1; }
  grep -q '^## Config' "$f" || { echo "no '## Config' block in $f"; fail=1; }
  lines=$(wc -l < "$f"); (( lines <= 500 )) || { echo "$f is $lines lines (>500); move material to references/"; fail=1; }
done < <(find plugins -name SKILL.md)

# scan <title> <terms file> [grep --exclude-dir pattern]. Prints every line that matches a term, after the owner's
# own identifiers in scripts/allowed-terms.txt are removed from it. Sets fail=1 on a hit.
SCAN_PATHS=(plugins templates docs prompts scripts README.md AGENTS.md CLAUDE.md)
scan() {
  local title="$1" terms="$2" exclude=(); [[ -n "${3:-}" ]] && exclude=(--exclude-dir="$3")
  echo "$(wc -l < "$terms" | tr -d ' ') terms"
  local hits
  hits=$(grep -rniE -f "$terms" "${SCAN_PATHS[@]}" ${exclude[@]+"${exclude[@]}"} \
           --include='*.md' --include='*.yaml' --include='*.json' --include='*.sh' \
         | grep -vE '^scripts/(forbidden|allowed)-[a-z-]+\.txt' \
         | TERMS="$terms" perl -ne '
             BEGIN { open(A, "scripts/allowed-terms.txt"); @a = grep { !/^\s*(#|$)/ } map { chomp; $_ } <A>;
                     open(T, $ENV{TERMS}); @t = map { chomp; $_ } <T>; }
             my ($file, $line, $body) = split(/:/, $_, 3); $body =~ s/\Q$_\E//gi for @a;
             for my $t (@t) { if ($body =~ /$t/i) { print; last } }')
  if [[ -n "$hits" ]]; then echo "$hits"; echo "$title found above"; fail=1; fi
}
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

echo "== client-data scan"
# Terms: generic patterns in scripts/forbidden-terms.txt, plus the forbidden-terms.txt at the root of every
# sibling repo (the private config repos keep their client and company names there, not here).
for f in scripts/forbidden-terms.txt "$HERE"/../*/forbidden-terms.txt; do
  [[ -f "$f" && "$f" != "$HERE/../$(basename "$HERE")/forbidden-terms.txt" ]] && grep -vE '^\s*(#|$)' "$f" >> "$tmp/client"
done
scan "client-specific terms" "$tmp/client"

echo "== tool-name scan"
# Skills name actions, not tools. Tool names may appear only in plugins/core/skills/platform-adapters/.
grep -vE '^\s*(#|$)' scripts/forbidden-tool-names.txt > "$tmp/tools"
scan "platform tool names (write the action instead; see core/platform-adapters)" "$tmp/tools" platform-adapters

if command -v skills-ref >/dev/null; then
  echo "== skills-ref"; find plugins -name SKILL.md -exec dirname {} \; | xargs -n1 skills-ref validate || fail=1
fi

(( fail == 0 )) && echo "OK" || { echo "FAILED"; exit 1; }
