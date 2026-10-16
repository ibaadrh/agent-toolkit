#!/usr/bin/env python3
"""zsh-guard: catch shell commands that break, or silently change meaning, when zsh runs them.

Usage:
  zsh-guard.py '<command>'        check one command string
  zsh-guard.py -                  read the command from standard input
  zsh-guard.py --hook             read a Claude Code PreToolUse event (JSON) from standard input
Exit 0 = fine. Exit 1 = blocked, with one line per problem and its fix on standard error.
In --hook mode a block exits 2, which tells Claude Code to refuse the command and show the message.

Rules (each one checked against real zsh 5.9 behaviour):
  equals-start   a word starting with an unquoted "=" is replaced by a command's path ("echo ====" fails,
                 "echo =ls" prints /bin/ls, "[ a == b ]" fails). A lone "=" is fine.
  glob-in-option an unquoted * ? or [ inside a word that starts with "-" ("--include=*.md"): zsh tries to
                 match the whole word as a file name and stops with "no matches found".
  glob-after-eq  an unquoted glob after "=" in an argument ("a=*.md"); same failure. Assignments are fine.
  pattern-arg    an unquoted glob as the argument of a pattern flag (find -name, grep --include, rg -g ...):
                 zsh expands it against the current folder first, so "find . -name *.md" silently searches
                 for one file name, or fails when nothing matches.
  glob-in-url    an unquoted ? * or [ in a URL: "no matches found".
  glob-remote    an unquoted glob in a remote path (host:*.log): zsh expands it locally and fails.
  bracket-word   an unquoted [...] argument ("tr -d [:space:]", "grep [ab]"): "no matches found".
Not checked (zsh handles them like bash): single-quoted or escaped text, heredoc bodies, comments,
[[ ... ]], (( ... )), case patterns and assignments. Commands inside $( ... ) and `...` are checked too.
Add the comment "# zsh-guard: allow" to a command to skip the check on purpose.
Standard library only; Python 3.8 or later.
"""
import json, os, re, sys

GLOB = set("*?[")
PATTERN_FLAGS = {"-name", "-iname", "-path", "-ipath", "-wholename", "-iwholename", "-regex", "-iregex",
                 "-lname", "-ilname", "--include", "--exclude", "--exclude-dir", "-g", "--glob", "--iglob"}
ASSIGN_CMDS = {"export", "typeset", "declare", "local", "readonly", "integer", "float"}
OPS = ("&&", "||", ";;", "|&", ";", "|", "&", "(", ")", "\n")
ASSIGN_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*(\[[^\]]*\])?\+?=")
REMOTE_RE = re.compile(r"^[A-Za-z0-9._-]+(@[A-Za-z0-9._-]+)?:[^/]")


class Word:
    def __init__(self):
        self.chars, self.quoted = [], []

    def add(self, c, q):
        self.chars.append(c); self.quoted.append(q)

    @property
    def text(self):
        return "".join(self.chars)

    def unquoted(self, i):
        return not self.quoted[i]


def _balanced(s, i, open_c, close_c):
    """s[i] is just after the opening bracket. Return the index of the matching close (quote aware)."""
    depth, n = 1, len(s)
    while i < n:
        c = s[i]
        if c == "\\": i += 2; continue
        if c == "'":
            j = s.find("'", i + 1); i = n if j < 0 else j + 1; continue
        if c == '"':
            i += 1
            while i < n and s[i] != '"':
                i += 2 if s[i] == "\\" else 1
            i += 1; continue
        if c == open_c: depth += 1
        elif c == close_c:
            depth -= 1
            if depth == 0: return i
        i += 1
    return n


def lex(s, subcommands):
    """Split a command into words and operators, keeping track of which characters were quoted.
    Command substitutions are collected into `subcommands` and checked separately."""
    tokens, w, i, n = [], Word(), 0, len(s)
    heredocs = []  # pending (delimiter, strip_tabs)

    def end_word():
        nonlocal w
        if w.chars: tokens.append(w)
        w = Word()

    while i < n:
        c = s[i]
        # heredoc bodies start after the newline that ends the line holding "<<"
        if c == "\n" and heredocs:
            end_word(); tokens.append("\n"); i += 1
            for delim, strip in heredocs:
                while i < n:
                    j = s.find("\n", i); j = n if j < 0 else j
                    line = s[i:j]
                    i = j + 1
                    if (line.lstrip("\t") if strip else line) == delim: break
            heredocs = []
            continue
        if c in " \t":
            end_word(); i += 1; continue
        if c == "#" and not w.chars:
            j = s.find("\n", i); i = n if j < 0 else j; continue
        if c == "\\":
            if i + 1 < n and s[i + 1] == "\n": i += 2; continue
            if i + 1 < n: w.add(s[i + 1], True)
            i += 2; continue
        if c == "'":
            j = s.find("'", i + 1); j = n if j < 0 else j
            for ch in s[i + 1:j]: w.add(ch, True)
            if not w.chars: w.add("", True)
            i = j + 1; continue
        if c == "$" and s[i + 1:i + 2] == "'":
            j = i + 2
            while j < n and s[j] != "'": j += 2 if s[j] == "\\" else 1
            for ch in s[i + 2:j]: w.add(ch, True)
            i = j + 1; continue
        if c == '"':
            i += 1
            while i < n and s[i] != '"':
                if s[i] == "\\" and i + 1 < n: w.add(s[i + 1], True); i += 2; continue
                if s[i] == "$" and s[i + 1:i + 2] == "(":
                    j = _balanced(s, i + 2, "(", ")"); subcommands.append(s[i + 2:j]); w.add("$", True); i = j + 1; continue
                if s[i] == "`":
                    j = s.find("`", i + 1); j = n if j < 0 else j; subcommands.append(s[i + 1:j]); w.add("$", True); i = j + 1; continue
                w.add(s[i], True); i += 1
            if not w.chars: w.add("", True)
            i += 1; continue
        if c == "$" and s[i + 1:i + 3] == "((":
            k = s.find("))", i + 3); k = n if k < 0 else k + 1
            w.add("$", True); i = k + 1; continue
        if c == "$" and s[i + 1:i + 2] == "(":
            j = _balanced(s, i + 2, "(", ")"); subcommands.append(s[i + 2:j]); w.add("$", True); i = j + 1; continue
        if c == "$" and s[i + 1:i + 2] == "{":
            j = _balanced(s, i + 2, "{", "}"); w.add("$", True); i = j + 1; continue
        if c == "`":
            j = s.find("`", i + 1); j = n if j < 0 else j; subcommands.append(s[i + 1:j]); w.add("$", True); i = j + 1; continue
        if c == "<" and s[i:i + 2] == "<<" and s[i:i + 3] != "<<<":
            end_word(); i += 2
            strip = s[i:i + 1] == "-"
            if strip: i += 1
            while i < n and s[i] in " \t": i += 1
            m = re.match(r"""(['"]?)([^\s'"<>;&|()]+)\1""", s[i:])
            if m: heredocs.append((m.group(2), strip)); i += m.end()
            continue
        if c == "(" and s[i:i + 2] == "((" and not w.chars:
            j = s.find("))", i + 2); i = n if j < 0 else j + 2; continue
        op = next((o for o in OPS if s.startswith(o, i)), None)
        if op:
            end_word(); tokens.append(op); i += len(op); continue
        if c in "<>":
            end_word(); i += 1
            while i < n and s[i] in "<>&|": i += 1
            continue
        w.add(c, False); i += 1
    end_word()
    return tokens


def check(cmd, depth=0):
    if "zsh-guard: allow" in cmd: return []
    subs, problems = [], []
    tokens = lex(cmd, subs)
    cmd_pos, prev, in_test, cmd_name = True, None, False, None
    for t in tokens:
        if isinstance(t, str):
            cmd_pos, prev, cmd_name = True, None, None
            continue
        text = t.text
        if text == "[[" and cmd_pos: in_test = True
        if in_test:
            if text == "]]": in_test = False
            cmd_pos, prev = False, text; continue
        assignment = bool(ASSIGN_RE.match(text)) and (cmd_pos or cmd_name in ASSIGN_CMDS)
        unq = [i for i, ch in enumerate(t.chars) if not t.quoted[i]]
        globs = [i for i in unq if t.chars[i] in GLOB]
        if not assignment:
            if t.chars and t.chars[0] == "=" and t.unquoted(0) and text != "=":
                problems.append(("equals-start", text,
                                 "zsh replaces a word starting with = by a command's path. Quote it: '%s'" % text
                                 + ("; inside [ ] use = instead of ==, or use [[ ]]" if text == "==" else "")))
            elif globs and text.startswith("-") and t.unquoted(0):
                problems.append(("glob-in-option", text,
                                 "zsh treats the whole word as a file pattern and stops with 'no matches found'. "
                                 "Quote the pattern: %s" % _quoted_fix(text)))
            elif globs and any(t.chars[i] == "=" and i < globs[0] for i in unq):
                problems.append(("glob-after-eq", text, "Quote it: '%s'" % text))
            elif globs and prev in PATTERN_FLAGS:
                problems.append(("pattern-arg", text,
                                 "zsh expands %s against the current folder before %s sees it "
                                 "(wrong results or 'no matches found'). Quote it: '%s'" % (text, prev, text)))
            elif "://" in text and any(t.chars[i] in "?*[" for i in unq):
                problems.append(("glob-in-url", text, "Quote the URL: '%s'" % text))
            elif globs and REMOTE_RE.match(text):
                problems.append(("glob-remote", text, "Quote the remote path so the remote side expands it: '%s'" % text))
            elif any(t.chars[i] == "[" for i in globs) and re.search(r"\[[^\]]+\]", text) and text not in ("[", "]"):
                problems.append(("bracket-word", text, "zsh reads [...] as a file pattern. Quote it: '%s'" % text))
        if cmd_pos: cmd_name = text
        cmd_pos, prev = False, text
    if depth < 5:
        for sub in subs: problems += check(sub, depth + 1)
    return problems


def _quoted_fix(text):
    if "=" in text:
        k, v = text.split("=", 1)
        return "%s='%s'" % (k, v)
    return "'%s'" % text


def report(problems):
    for rule, word, fix in problems:
        sys.stderr.write("zsh-guard [%s] %s\n  fix: %s\n" % (rule, word, fix))


def main():
    args = sys.argv[1:]
    if not args:
        sys.stderr.write(__doc__); sys.exit(64)
    if args[0] == "--hook":
        try:
            event = json.load(sys.stdin)
        except ValueError:
            sys.exit(0)  # not our input; never block on a parsing problem
        if event.get("tool_name") != "Bash": sys.exit(0)
        if not os.environ.get("SHELL", "").endswith("zsh") and not os.environ.get("ZSH_GUARD_ALWAYS"): sys.exit(0)
        problems = check(event.get("tool_input", {}).get("command", ""))
        if problems:
            report(problems)
            sys.stderr.write("Blocked before running: this shell is zsh. Rewrite the command with the fix above.\n")
            sys.exit(2)
        sys.exit(0)
    cmd = sys.stdin.read() if args[0] == "-" else " ".join(args)
    problems = check(cmd)
    report(problems)
    sys.exit(1 if problems else 0)


if __name__ == "__main__":
    main()
