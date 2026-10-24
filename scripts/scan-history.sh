#!/usr/bin/env bash
# Scan git history for client data: every file version (text and binary), commit message and author in the range.
# Usage: ./scripts/scan-history.sh [<git rev-list arguments>]    (default: --all, the whole history)
#   e.g. ./scripts/scan-history.sh origin/main..main
# Terms: scripts/forbidden-terms.txt plus the forbidden-terms.txt of every sibling repo, as in validate.sh. The owner's
# identifiers in scripts/allowed-terms.txt are removed from a line before it is checked. Exits 1 on a hit.
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"; cd "$HERE"
(( $# )) || set -- --all
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

for f in scripts/forbidden-terms.txt "$HERE"/../*/forbidden-terms.txt; do
  [[ -f "$f" && "$f" != "$HERE/../$(basename "$HERE")/forbidden-terms.txt" ]] && grep -vE '^\s*(#|$)' "$f" >> "$tmp/terms"
done
echo "$(wc -l < "$tmp/terms" | tr -d ' ') terms, $(git rev-list "$@" | wc -l | tr -d ' ') commits"

# Each line to check is "<where>: <text>". Commit messages and authors first, then every new file version.
git log --format='commit %h: %an <%ae> %cn <%ce>%n%B' "$@" \
  | awk '/^commit [0-9a-f]+: /{c=$2; print; next} NF{print "commit " c " " $0}' > "$tmp/lines"
git rev-list --objects "$@" | while read -r obj path; do
  [[ -n "$path" && "$(git cat-file -t "$obj")" == blob ]] || continue
  [[ "$path" =~ ^scripts/(forbidden|allowed)-[a-z-]+\.txt$ ]] && continue
  git cat-file -p "$obj" | LC_ALL=C grep -anE '.' | LC_ALL=C sed "s|^|$path@${obj:0:7}:|"
done >> "$tmp/lines"

hits=$(LC_ALL=C grep -aiE -f "$tmp/terms" "$tmp/lines" | TERMS="$tmp/terms" perl -ne '
  BEGIN { open(A, "scripts/allowed-terms.txt"); @a = grep { !/^\s*(#|$)/ } map { chomp; $_ } <A>;
          open(T, $ENV{TERMS}); @t = map { chomp; $_ } <T>; }
  my $body = $_; $body =~ s/\Q$_\E//gi for @a;
  for my $t (@t) { if ($body =~ /$t/i) { (my $p = substr($_, 0, 240)) =~ s/\s+$//; $p =~ s/[^\x20-\x7e]/?/g; print "$p\n"; last } }')
if [[ -n "$hits" ]]; then echo "$hits"; echo "client-specific terms found in history above"; exit 1; fi
echo "OK"
