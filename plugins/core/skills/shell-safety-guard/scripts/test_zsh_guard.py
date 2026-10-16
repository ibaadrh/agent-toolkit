#!/usr/bin/env python3
"""Test zsh-guard.py against a list of commands, and check each verdict against what real zsh does.

Usage: test_zsh_guard.py
For every case: the expected verdict (block or pass), the guard's verdict, and what `zsh -f -c` actually
did in a throwaway folder holding a.md, sub/b.md and notes.txt. "breaks" = zsh exited with an error,
"silent" = zsh ran but the command meant something else, "ok" = it worked as written.
Exits 1 if any guard verdict differs from the expected one. Standard library only.
"""
import os, shutil, subprocess, sys, tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
GUARD = os.path.join(HERE, "zsh-guard.py")

# (command, expected guard verdict, what zsh does: breaks / silent / ok, note)
CASES = [
    ("grep -rn hello --include=*.md .", "block", "breaks", "the real failure: no matches found: --include=*.md"),
    ("grep -rn hello --include='*.md' .", "pass", "ok", "the fix"),
    ("grep -rn hello --include=\\*.md .", "pass", "ok", "escaped also works"),
    ("echo ====", "block", "breaks", "equals at word start"),
    ("printf '%s\\n' '===='", "pass", "ok", "quoted"),
    ("echo =ls", "block", "silent", "prints /bin/ls instead of =ls"),
    ("[ a == a ] && echo ok", "block", "breaks", "== in [ ]"),
    ("[ a = a ] && echo ok", "pass", "ok", "lone = is fine"),
    ("[[ a == a ]] && echo ok", "pass", "ok", "[[ ]] is fine"),
    ("find . -name *.md", "block", "silent", "expands to -name a.md and misses sub/b.md"),
    ("find . -name '*.md'", "pass", "ok", "quoted pattern"),
    ("echo a=*.zz", "block", "breaks", "glob after = in an argument"),
    ("X=*.zz; echo \"$X\"", "pass", "ok", "assignment does not glob"),
    ("export X=*.zz; echo \"$X\"", "pass", "ok", "export assignment does not glob"),
    ("echo https://example.com/a?b=1", "block", "breaks", "unquoted ? in a URL"),
    ("echo 'https://example.com/a?b=1'", "pass", "ok", "quoted URL"),
    ("echo host:*.log", "block", "breaks", "remote path glob (as scp or rsync would get it)"),
    ("echo ' a b ' | tr -d [:space:]", "block", "breaks", "unquoted bracket class"),
    ("echo ' a b ' | tr -d '[:space:]'", "pass", "ok", "quoted class"),
    ("echo $(echo ====)", "block", "breaks", "the trap inside $( )"),
    ("echo \"$(printf '%s' '====')\"", "pass", "ok", "quoted inside $( )"),
    ("ls *.md", "pass", "ok", "intended glob that matches"),
    ("case x.md in *.md) echo match;; esac", "pass", "ok", "case pattern"),
    ("echo foo # comment with *.zz and ====", "pass", "ok", "comment"),
    ("cat <<EOF\n==== *.zz --include=*.md\nEOF", "pass", "ok", "heredoc body"),
    ("python3 - <<'PY'\nprint('a=*.md ====')\nPY", "pass", "ok", "quoted heredoc with code"),
    ("git log --format=%h -1 >/dev/null 2>&1; echo ok", "pass", "ok", "% is not a glob"),
    ("perl -e 'print \"=\" x 4, \"\\n\"'", "pass", "ok", "program in single quotes"),
    ("echo $((2 == 2))", "pass", "ok", "arithmetic"),
    ("echo ok # zsh-guard: allow =ls", "pass", "ok", "explicit allow marker"),
]


def zsh_outcome(cmd, folder):
    if not shutil.which("zsh"): return "n/a"
    p = subprocess.run(["zsh", "-f", "-c", cmd], cwd=folder, capture_output=True, text=True)
    # zsh can print the error and still exit 0 (a failed $( ) inside a working command), so read stderr
    return "breaks" if ("not found" in p.stderr or "no matches" in p.stderr) else "ran"


def main():
    folder = tempfile.mkdtemp(prefix="zsh-guard-test-")
    os.makedirs(os.path.join(folder, "sub"))
    for f in ("a.md", "sub/b.md", "notes.txt"):
        with open(os.path.join(folder, f), "w") as h: h.write("hello\n")
    failures = 0
    print("%-6s %-6s %-7s %-8s %s" % ("expect", "guard", "zsh", "agrees", "command  (note)"))
    for cmd, expect, zsh_says, note in CASES:
        p = subprocess.run([sys.executable, GUARD, "-"], input=cmd, capture_output=True, text=True)
        got = "block" if p.returncode == 1 else "pass" if p.returncode == 0 else "error"
        real = zsh_outcome(cmd, folder)
        # A command zsh breaks must be blocked; one that runs must pass unless it silently changes meaning.
        real_ok = (real == "breaks") == (zsh_says == "breaks") if real != "n/a" else True
        ok = got == expect and real_ok
        failures += not ok
        print("%-6s %-6s %-7s %-8s %s  (%s)" % (expect, got, real, "yes" if ok else "NO", cmd.replace("\n", "\\n"), note))
    shutil.rmtree(folder)
    print("\n%d cases, %d failed" % (len(CASES), failures))
    sys.exit(1 if failures else 0)


if __name__ == "__main__":
    main()
