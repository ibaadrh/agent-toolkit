---
name: shell-safety-guard
description: A check that stops shell commands which break, or silently change meaning, when the user's shell is zsh, and says the fix for each. It catches words starting with "=" ("echo ====", "[ a == b ]"), unquoted globs inside flags ("grep --include=*.md"), after "=" in arguments, as the argument of pattern flags ("find -name *.md"), in URLs and remote paths, and unquoted bracket classes ("tr -d [:space:]"). Portable script plus an optional Claude Code hook. Use it before running any shell command on a machine whose shell is zsh (macOS default), and when a command fails with "no matches found" or "word not found".
---

# Shell safety guard

zsh is the default shell on macOS, and it treats some characters differently from bash. A command that works everywhere else can stop with "no matches found", or, worse, run and mean something different. This skill holds a small script that reads a command before it runs, names each trap, and gives the fix. The result is either "fine" or a refusal with a rewritten form to use instead.

## Config
This skill needs: none.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/platform-adapters` for "run a shell command on the user's machine"

## Inputs
The exact command string about to be run.

## Steps
1. **Check the command before running it.** `python3 scripts/zsh-guard.py '<command>'`, or pass it on standard input: `printf '%s' "<command>" | python3 scripts/zsh-guard.py -` (use standard input for anything with quotes or several lines). Exit 0: run it. Exit 1: do not run it; read the lines it printed.
2. **Apply the fix it names**, then check again. The fixes, by rule:

   | Rule | Breaks | Fix |
   |---|---|---|
   | equals-start | `echo ====` fails; `echo =ls` prints `/bin/ls`; `[ a == b ]` fails | Quote the word: `'===='`. In `[ ]` use `=`, or use `[[ ]]`. |
   | glob-in-option | `grep -rn x --include=*.md .` stops: "no matches found: --include=*.md" | Quote the pattern: `--include='*.md'` (or `--include=\*.md`). |
   | glob-after-eq | `echo a=*.md` stops | Quote it. Assignments (`X=*.md`, `export X=*.md`) are fine. |
   | pattern-arg | `find . -name *.md` runs as `-name a.md` when one .md file sits in the folder, and misses the rest; with none, it stops | Quote it: `-name '*.md'`. Same for `-path`, `-regex`, `--exclude`, `rg -g`. |
   | glob-in-url | `curl https://site/page?x=1` stops | Quote the whole URL. |
   | glob-remote | `scp host:*.log .` stops (zsh expands it locally) | Quote the remote path: `'host:*.log'`. |
   | bracket-word | `tr -d [:space:]`, `grep [ab]` stop | Quote it: `'[:space:]'`. |

3. **Mean it when you allow it.** If a flagged word is exactly what you want (rare), add the comment `# zsh-guard: allow` to the command and say why in your reply.
4. **In Claude Code, the hook does step 1 for you.** The core plugin's `hooks/hooks.json` runs the same script on every shell command when `$SHELL` is zsh, and refuses a flagged command with the fix. It never blocks if `python3` is missing or the input cannot be read.
5. **Other agents:** see `docs/PORTABILITY.md` ("Using the zsh guard").

## What it does not check
- **Unquoted variables are not split into words in zsh.** `G="python3 guard.py"; $G x` runs a command literally named `python3 guard.py` and fails with "command not found". Use a function, an array (`G=(python3 guard.py); $G x`), or `${=G}`. The guard cannot tell a deliberate split from a safe use, so it does not flag this.
- **An intended glob that matches nothing** (`rm *.tmp` in a clean folder) stops in zsh but passes in bash. The guard lets plain globs through, because they are usually meant. Add `(N)` to the glob in zsh (`rm -f *.tmp(N)`), or check first.
- History expansion with `!`: it only happens in interactive shells, not in commands an agent runs.

## Output
Exit 0 with nothing printed, or exit 1 with one line per problem: the rule, the word, and the fix. In hook mode a refusal is exit 2.

## Tests
`python3 scripts/test_zsh_guard.py` runs 30 commands, 10 bad and 20 good, through the guard and through a real `zsh -f` in a throwaway folder, and checks the two agree. Last run with zsh 5.9: 30 of 30 passed.

## Known failures
- **`grep -rn <word> ... --include=*.md` stopped with "no matches found: --include=*.md".** Hit as `--include=*.md`, and again as `--include=*.py` while building this skill. It is the reason the skill exists. Fix: glob-in-option.
- **`echo ======` stopped with "===== not found".** Hit while printing a separator. Fix: equals-start; quote it or use `printf '%s\n' '======'`.
- **A check loop ran nothing: every line reported "command not found".** Hit when the command was stored in a variable and run as `$G ...`, which zsh does not split. Not caught by the guard; see "What it does not check".
- **Risk: `find . -name *.md` returning one file instead of all of them**, with no error at all. Fix: pattern-arg.
- **Risk: a URL with a query string stopping a `curl` or `open` call.** Fix: glob-in-url.

## References
- `scripts/zsh-guard.py`: the guard (Python 3.8+, standard library only). `--hook` reads a Claude Code PreToolUse event.
- `scripts/test_zsh_guard.py`: the test suite.
- `hooks/hooks.json` and `hooks/zsh-guard.sh` in the core plugin: the Claude Code wrapper.
