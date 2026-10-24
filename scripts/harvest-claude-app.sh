#!/usr/bin/env bash
# Copy new or changed skills from the Claude app (its synced account skills) into the private config repos' inboxes.
# Usage: ./scripts/harvest-claude-app.sh [--dry-run] [--accept <skill>]
#   --dry-run          print the plan; change, commit and push nothing
#   --accept <skill>   after placing a skill by hand: record the app's current copy as harvested; then commit yourself
# A skill goes to the first <company>-agent-config repo whose forbidden-terms.txt matches its text, otherwise to
# agent-clients. A skill that already has a copy in an inbox stays in that repo, unless its text matches another
# company's terms: then it is not copied, so company text never lands in the wrong repo. Never into agent-toolkit.
# raw/<skill>/.harvested holds a hash of the app copy last harvested; a skill is "changed" when the app copy differs.
# Env: HARVEST_SYNCED_DIR (default ~/.claude/skills/synced), HARVEST_DEFAULT_REPO (default agent-clients).
set -uo pipefail
HERE="$(cd "$(dirname "$0")/.." && pwd)"
CODE="$(dirname "$HERE")"
SYNCED="${HARVEST_SYNCED_DIR:-$HOME/.claude/skills/synced}"
DEFAULT_REPO="${HARVEST_DEFAULT_REPO:-agent-clients}"
TODAY="$(date +%F)"
BUILTINS=" docx pdf pptx xlsx skill-creator docs google-workspace computer-use chrome-browser built-in-browser deep-research import-memory morning "
DRY=0; ACCEPT=""
while (( $# )); do
  case "$1" in
    --dry-run) DRY=1 ;;
    --accept) ACCEPT="${2:?--accept needs a skill name}"; shift ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown option: $1"; exit 2 ;;
  esac
  shift
done

echo "harvest-claude-app $(date '+%F %T')$( (( DRY )) && echo ' (dry run)')"
[[ -d "$SYNCED" ]] || { echo "no synced skills folder at $SYNCED"; exit 1; }
[[ -d "$CODE/$DEFAULT_REPO/_inbox" ]] || { echo "default repo $CODE/$DEFAULT_REPO has no _inbox/"; exit 1; }

# Config repos: siblings with a forbidden-terms.txt and an _inbox/INBOX.md. Company repos: all of them but the default.
REPOS=(); COMPANY=()
for d in "$CODE"/*/; do
  d="${d%/}"; r="$(basename "$d")"
  [[ "$d" == "$HERE" ]] && continue
  [[ -f "$d/forbidden-terms.txt" && -f "$d/_inbox/INBOX.md" ]] || continue
  REPOS+=("$r"); [[ "$r" != "$DEFAULT_REPO" ]] && COMPANY+=("$r")
done

# Bring each repo up to date first, so the comparison is against what is on GitHub.
if (( ! DRY )); then
  for r in "${REPOS[@]}"; do
    git -C "$CODE/$r" pull --ff-only --quiet || { echo "ERROR: $r: pull failed; fix it and run again"; exit 1; }
  done
fi

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT

# src_hash <dir>: one hash over every file's name and content, ignoring .DS_Store and the .harvested stamp.
src_hash() {
  (cd "$1" && find . -type f ! -name .DS_Store ! -name .harvested -print0 | LC_ALL=C sort -z | xargs -0 shasum) | shasum | cut -d' ' -f1
}

if [[ -n "$ACCEPT" ]]; then
  src="$(find "$SYNCED" -mindepth 2 -maxdepth 3 -type d -name "$ACCEPT" | head -1)"
  [[ -f "$src/SKILL.md" ]] || { echo "no app skill named $ACCEPT under $SYNCED"; exit 1; }
  for r in "${REPOS[@]}"; do
    [[ -d "$CODE/$r/_inbox/raw/$ACCEPT" ]] || continue
    src_hash "$src" > "$CODE/$r/_inbox/raw/$ACCEPT/.harvested"
    echo "$r/_inbox/raw/$ACCEPT/.harvested now matches the app copy. Commit it with your hand-placed copy."; exit 0
  done
  echo "no inbox copy of $ACCEPT; place it in a repo's _inbox/raw/$ACCEPT/ first"; exit 1
fi

# Perl helpers for INBOX.md tables: cells(line) splits a row into trimmed cells; key(cell) turns "`raw/x/`" into "x".
PERL_ROWS='sub cells { my $t = shift; chomp $t; $t =~ s/^\|//; $t =~ s/\|\s*$//; map { s/^\s+|\s+$//gr } split /\|/, $t, -1 }
  sub key { my $s = shift; $s =~ s/`//g; $s =~ s{^raw/}{}; $s =~ s{/$}{}; $s };'

# is_done <name>: 0 if any INBOX.md has a row for it, in a table whose last column is Status, marked done.
is_done() {
  local r
  for r in "${REPOS[@]}"; do
    NAME="$1" perl -CSD -ne "$PERL_ROWS"'
      if (/^\|/) { my @c = cells($_);
        if (!$in) { $in = 1; $st = ($c[-1] eq "Status"); next }
        exit 1 if $st && key($c[0]) eq $ENV{NAME} && $c[-1] =~ /^(\x{2713}\s*)?done/i;
      } else { $in = 0 }' "$CODE/$r/_inbox/INBOX.md" || return 0
  done
  return 1
}

# is_anthropic <skill dir>: 0 for a built-in by name, by an Anthropic LICENSE.txt, or by the app's manifest.
is_anthropic() {
  local dir="$1" name; name="$(basename "$1")"
  [[ "$BUILTINS" == *" $name "* ]] && return 0
  [[ -f "$dir/LICENSE.txt" ]] && grep -qi anthropic "$dir/LICENSE.txt" && return 0
  [[ -f "$(dirname "$dir")/manifest.json" ]] && NAME="$name" perl -MJSON::PP -0777 -ne '
    my $m = eval { decode_json($_) } or exit 0;
    for (@{ $m->{skills} || [] }) { exit 1 if $_->{name} eq $ENV{NAME} && ($_->{creatorType} // "") eq "anthropic" }
    ' "$(dirname "$dir")/manifest.json" || return 0
  return 1
}

# update_inbox <repo> <name> <new|changed>: set the status of the skill's row, or add it under "Harvested from the Claude app".
update_inbox() {
  NAME="$2" KIND="$3" TODAY="$TODAY" perl -CSD -e "$PERL_ROWS"'
    open(my $fh, "<", $ARGV[0]) or die; my @l = <$fh>; close $fh; my ($in, $st, $done) = (0, 0, 0); my $tag = "pending (harvested $ENV{TODAY}, $ENV{KIND})";
    for my $i (0..$#l) {
      if ($l[$i] !~ /^\|/) { $in = 0; next }
      my @c = cells($l[$i]);
      if (!$in) { $in = 1; $st = ($c[-1] eq "Status"); next }
      next unless $st && key($c[0]) eq $ENV{NAME};
      (my $rest = $c[-1]) =~ s/^pending//; $rest =~ s/^\s*\(harvested [^)]*\)//; $rest =~ s/^\s+//;
      $rest = ". $rest" if $rest ne "" && $rest !~ /^[.,;:]/;
      $c[-1] = $tag . $rest; $l[$i] = "| " . join(" | ", @c) . " |\n"; $done = 1; last;
    }
    if (!$done) {
      my $row = "| `raw/$ENV{NAME}` | skill | to decide | $tag |\n";
      my ($h) = grep { $l[$_] =~ /^## Harvested from the Claude app/ } 0..$#l;
      if (defined $h) {
        my $j = $h + 1; $j++ while $j <= $#l && $l[$j] !~ /^\|/; $j++ while $j <= $#l && $l[$j] =~ /^\|/;
        splice @l, $j, 0, $row;
      } else {
        my @sec = ("## Harvested from the Claude app\n", "\n",
          "New skills found in the Claude app by agent-toolkit `scripts/harvest-claude-app.sh`. Decide a destination for each, then migrate it as usual.\n",
          "\n", "| Source | Kind | Proposed destination | Status |\n", "|---|---|---|---|\n", $row, "\n");
        my ($a) = grep { $l[$_] =~ /^## Account skills/ } 0..$#l; my $j = scalar @l;
        if (defined $a) { ($j) = grep { $l[$_] =~ /^## / } ($a + 1)..$#l; $j //= scalar @l }
        else { push @l, "\n" unless $l[-1] eq "\n" }
        splice @l, $j, 0, @sec;
      }
    }
    open($fh, ">", $ARGV[0]) or die; print $fh @l; close $fh;' "$CODE/$1/_inbox/INBOX.md"
}

# Plan. Each skill folder is <synced>/<name>/ or <synced>/<account bucket>/<name>/.
seen=" "; plan=(); skipped_builtin=(); skipped_done=(); skipped_same=(); notes=()
while IFS= read -r f; do
  dir="$(dirname "$f")"; name="$(basename "$dir")"
  [[ "$dir" == */.trash/* || -f "$(dirname "$dir")/SKILL.md" ]] && continue
  [[ "$seen" == *" $name "* ]] && { notes+=("$name: found twice under $SYNCED, used the first"); continue; }
  seen+="$name "
  is_anthropic "$dir" && { skipped_builtin+=("$name"); continue; }
  is_done "$name" && { skipped_done+=("$name"); continue; }

  # Route by forbidden terms.
  hits=()
  for r in "${COMPANY[@]+"${COMPANY[@]}"}"; do
    grep -vE '^\s*(#|$)' "$CODE/$r/forbidden-terms.txt" > "$tmp/terms"
    [[ -s "$tmp/terms" ]] && grep -rqiE -f "$tmp/terms" "$dir" && hits+=("$r")
  done
  if (( ${#hits[@]} > 1 )); then notes+=("$name: matches the terms of ${hits[*]}; skipped, place it by hand"); continue; fi
  route="${hits[0]:-$DEFAULT_REPO}"

  # An existing inbox copy decides the repo, so a skill never ends up in two inboxes.
  dest="$route"; kind=new
  for r in "${REPOS[@]}"; do [[ -d "$CODE/$r/_inbox/raw/$name" ]] && { dest="$r"; kind=changed; break; }; done
  [[ "$CODE/$dest" -ef "$HERE" ]] && { echo "ERROR: $name would go into agent-toolkit"; exit 1; }
  if [[ $kind == changed ]]; then
    stamp="$CODE/$dest/_inbox/raw/$name/.harvested"
    if [[ -f "$stamp" ]]; then [[ "$(cat "$stamp")" == "$(src_hash "$dir")" ]] && { skipped_same+=("$name"); continue; }
    elif diff -rq -x .DS_Store "$dir" "$CODE/$dest/_inbox/raw/$name" >/dev/null; then skipped_same+=("$name"); continue; fi
  fi
  if [[ "$dest" != "$route" ]]; then
    notes+=("$name: changed in the app, but it holds $route terms and its inbox copy is in $dest; not copied. Move those lines into $route's _inbox by hand, put the rest in $dest/_inbox/raw/$name/, then run --accept $name")
    continue
  fi
  plan+=("$kind|$name|$dest|$dir")
done < <(find "$SYNCED" -mindepth 2 -maxdepth 3 -name SKILL.md | sort)

# Report the plan.
echo
if (( ${#plan[@]} )); then
  echo "To harvest:"
  for p in "${plan[@]}"; do IFS='|' read -r kind name dest _ <<<"$p"; printf '  %-8s %-36s -> %s/_inbox/raw/%s/\n' "$kind" "$name" "$dest" "$name"; done
else
  echo "Nothing new or changed."
fi
list() { local t="$1"; shift; (( $# )) && echo "$t ($#): $*"; }
list "Skipped, built-in" ${skipped_builtin[@]+"${skipped_builtin[@]}"}
list "Skipped, done in an INBOX.md" ${skipped_done[@]+"${skipped_done[@]}"}
list "Skipped, same as the inbox copy" ${skipped_same[@]+"${skipped_same[@]}"}
for n in "${notes[@]+"${notes[@]}"}"; do echo "Note: $n"; done
(( DRY )) && { echo; echo "Dry run: nothing changed."; exit 0; }
(( ${#plan[@]} )) || exit 0

# Each target repo must have its own commit identity and nothing staged, so the commit holds only the harvest.
fail=0; touched=" "; bad=" "
for p in "${plan[@]}"; do
  IFS='|' read -r _ _ dest _ <<<"$p"
  [[ "$touched$bad" == *" $dest "* ]] && continue
  if [[ -z "$(git -C "$CODE/$dest" config --local user.email)" ]]; then echo "ERROR: $dest has no user.email of its own; skipped"; bad+="$dest "
  elif ! git -C "$CODE/$dest" diff --cached --quiet; then echo "ERROR: $dest has staged changes; skipped"; bad+="$dest "
  else touched+="$dest "; fi
done
[[ "$bad" == " " ]] || fail=1

# Copy, update INBOX.md, then commit and push each repo that changed.
for p in "${plan[@]}"; do
  IFS='|' read -r kind name dest dir <<<"$p"
  [[ "$bad" == *" $dest "* ]] && continue
  mkdir -p "$CODE/$dest/_inbox/raw/$name"
  rsync -a --delete --exclude .DS_Store "$dir/" "$CODE/$dest/_inbox/raw/$name/" \
    && src_hash "$dir" > "$CODE/$dest/_inbox/raw/$name/.harvested" \
    && update_inbox "$dest" "$name" "$kind" \
    && git -C "$CODE/$dest" add -A "_inbox/raw/$name" _inbox/INBOX.md \
    || { echo "ERROR: $dest: could not harvest $name"; fail=1; }
done
echo
for r in $touched; do
  git -C "$CODE/$r" diff --cached --quiet && continue
  git -C "$CODE/$r" commit --quiet -m "Harvest Claude app skills $TODAY" \
    && git -C "$CODE/$r" push --quiet \
    && echo "$r: committed and pushed $(git -C "$CODE/$r" rev-parse --short HEAD)" \
    || { echo "ERROR: $r: commit or push failed"; fail=1; }
done
exit $fail
