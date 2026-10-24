#!/usr/bin/env python3
"""Allowlist check: blocks anything that could identify a client, without knowing the client's name.

Usage: check-allowlists.py [--rev <commit>] [--seed]
  (no args)     check the working tree (tracked and untracked, not ignored files)
  --rev <sha>   check the files of that commit (the pre-push guard uses this)
  --seed        print every name and domain found, one per line, instead of checking (to seed the lists)

Blocks, and prints each hit as file:line: kind: what:
  name    a capitalised, CamelCase or ALL-CAPS word not in scripts/allowed-names.txt (a line there with a space
          or hyphen is a phrase, matched as a whole). A capitalised word
          that opens a sentence passes only if the repo also uses it as an ordinary lowercase word.
  domain  a URL or domain not covered by scripts/allowed-domains.txt
  email   any email address except the owner's noreply address
  data    in skills and templates (plugins/, templates/): a phone number, a currency amount, a measurement
          with a unit, a size like 1080x1350, a digit string of 7 or more, or a calendar date. Allowed only
          when the exact line is listed under "generic example lines" in scripts/allowed-terms.txt.
Standard library only.
"""
import os, re, subprocess, sys

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OWNER_EMAIL = "88559161+ibaadrh@users.noreply.github.com"
TEXT_EXT = (".md", ".yaml", ".yml", ".json", ".sh", ".py", ".js", ".txt", ".plist", "")
SKIP = re.compile(r"^scripts/(allowed|forbidden)-[a-z-]+\.txt$|^scripts/check-allowlists\.py$")
CODE_EXT = (".sh", ".py", ".js")
DATA_SCOPE = ("plugins/", "templates/")

def git(*a):
    return subprocess.run(["git", "-C", HERE, *a], check=True, capture_output=True, text=True).stdout

def load_files(rev):
    if rev:
        names = git("ls-tree", "-r", "--name-only", rev).splitlines()
        read = lambda p: subprocess.run(["git", "-C", HERE, "show", f"{rev}:{p}"], capture_output=True).stdout
    else:
        names = git("ls-files", "-co", "--exclude-standard").splitlines()
        read = lambda p: open(os.path.join(HERE, p), "rb").read() if os.path.isfile(os.path.join(HERE, p)) else b""
    out = {}
    for p in names:
        if SKIP.search(p) or not p.endswith(TEXT_EXT) or (os.path.splitext(p)[1] == "" and "/" not in p and p != "LICENSE"):
            continue
        try:
            out[p] = read(p).decode("utf-8")
        except UnicodeDecodeError:
            continue
    return out

def read_list(name, section=None):
    """Lines of scripts/<name>, minus comments. section='generic' returns only the lines after the generic marker."""
    path = os.path.join(HERE, "scripts", name)
    if not os.path.exists(path): return []
    lines, generic = [], False
    for raw in open(path, encoding="utf-8"):
        line = raw.rstrip("\n")
        if line.startswith("# --- generic example lines"): generic = True; continue
        if section == "generic":
            if generic and line.strip(): lines.append(line.strip())
            continue
        if generic: break
        if line.strip() and not line.lstrip().startswith("#"): lines.append(line.strip())
    return lines

URL = re.compile(r"https?://[^\s<>()\[\]'\"`|]+")
DOMAIN = re.compile(r"(?<![\w@/.-])((?:[a-z0-9-]+\.)+(?:com|net|org|io|ai|tech|app|dev|co|nl|de|uk|ae|be|fr|es|it|eu|us|events|me|so|gg|xyz|info|biz|store|shop|site|online|cloud))\b(/[^\s<>()\[\]'\"`|]*)?", re.I)
EMAIL = re.compile(r"[\w.+-]+@[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,}\b")
WORD = re.compile(r"[A-Za-z][A-Za-z0-9]*")
IDENT = re.compile(r"[A-Za-z0-9_]+")   # identifiers stay whole: WD_ROW_HEIGHT_RULE is one token
DATA = [
    ("phone", re.compile(r"(?<![\w.])\+\d{1,3}[\s.-]?\d[\d\s.-]{6,}\d\b|\b0\d{1,3}[\s-]\d{3,4}[\s-]?\d{3,4}\b")),
    ("price", re.compile(r"[€£¥]\s?\d|(?<![\w\"'(])\$\s?(?:\d{2,}|\d[.,]\d)|\b\d[\d,.]*\s?(?:EUR|USD|GBP|euros?|dollars?)\b", re.I)),
    ("measurement", re.compile(r"(?<![%\w.])(?<!%-)-?\d+(?:[.,]\d+)?\s?(?:mm|cm|km|kg|mg|g|mAh|kWh|Wh|W|V|Hz|kHz|MHz|GHz|KB|MB|GB|TB|px|pt|fps|LUFS|LU|dB|dBTP|ms|s|secs?|seconds?|mins?|minutes?|hrs?|hours?|days?|weeks?|months?|k)\b|\b\d+(?:[.,]\d+)?\s?(?:%|×|°)|\b\d+(?:[.,]\d+)?x\b")),
    ("size", re.compile(r"\b\d{2,5}\s?[x×]\s?\d{2,5}\b")),
    ("long number", re.compile(r"\b\d{7,}\b")),
    ("date", re.compile(r"\b20\d{2}-\d{2}-\d{2}\b|(?<![\d./])\d{1,2}/\d{1,2}/(?:20)?\d{2}(?![\d/])|(?<![\d.])\d{1,2}\.\d{1,2}\.20\d{2}(?![\d.])"
                        r"|\b\d{1,2}(?:st|nd|rd|th)?\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-z]*\b"
                        r"|\b(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)[a-z]*\.?\s+(?:\d{1,2}(?:st|nd|rd|th)?\b|20\d{2}\b)")),
]
SENTENCE_START = re.compile(r"(?:^|[.!?:;][*_`\"')\]]*\s+|[|>→=<\"(\[]\s*|\s{2,}|^\s*(?:[#>*+-]+|\d+[.)]|- \[[ x]\])\s+)[\s*_`\"'(\[]*$")

def prose_lines(path, text):
    """Yield (line number, text) for the parts of a file that are words for people: all of markdown, yaml and
    json; comments only in code."""
    ext = os.path.splitext(path)[1]
    for i, line in enumerate(text.splitlines(), 1):
        if ext in CODE_EXT:
            s = line.strip()
            if s.startswith("#!"): continue
            m = re.search(r"(?:^|\s)(#|//)\s(.*)$", line)
            if m: yield i, m.group(2)
            elif ext == ".py" and (s.startswith('"""') or s.endswith('"""')): yield i, s.strip('"')
            continue
        yield i, line

def names_in(line, phrases=()):
    clean = URL.sub(" ", line)
    clean = EMAIL.sub(" ", clean)
    for ph in phrases: clean = clean.replace(ph, " ")
    for m in IDENT.finditer(clean):
        w = m.group(0)
        if len(w) < 2 or w[0].isdigit() or not any(c.isupper() for c in w): continue   # 3MF, 4K: formats
        if m.start() and clean[m.start() - 1] == "$": continue                       # $NF, $PWD: shell variables
        start = SENTENCE_START.search(clean[:m.start()]) is not None
        yield w, start

def main():
    args = sys.argv[1:]
    rev = args[args.index("--rev") + 1] if "--rev" in args else None
    seed = "--seed" in args
    files = load_files(rev)
    listed = read_list("allowed-names.txt")
    allowed_names = {n for n in listed if not re.search(r"[\s-]", n)}
    phrases = sorted((n for n in listed if re.search(r"[\s-]", n)), key=len, reverse=True)
    allowed_domains = [d.lower() for d in read_list("allowed-domains.txt")]
    generic = set(read_list("allowed-terms.txt", "generic"))
    lower_words = set()
    for t in files.values():
        lower_words.update(w for w in WORD.findall(t) if w.islower())

    hits, seen_names, seen_domains = [], set(), set()
    def domain_ok(host, path):
        hp = re.sub(r"\.git$", "", (host + path).lower().rstrip("/.,;:"))
        for d in allowed_domains:
            if d.endswith("$"):
                if hp == d[:-1]: return True
            elif "/" in d:
                if hp == d or hp.startswith(d + "/") or hp.startswith(d + "#"): return True
            elif host == d or host.endswith("." + d):
                return True
        return False

    for path, text in sorted(files.items()):
        in_scope = path.startswith(DATA_SCOPE)
        for n, line in enumerate(text.splitlines(), 1):
            for m in EMAIL.finditer(line):
                if m.group(0) not in (OWNER_EMAIL, "git@github.com"): hits.append(f"{path}:{n}: email: {m.group(0)}")
            for m in URL.finditer(line):
                u = re.sub(r"^https?://", "", m.group(0)).rstrip(".,;:")
                host, _, rest = u.partition("/")
                host = host.lower().split(":")[0]
                seen_domains.add((host + ("/" + rest if rest else "")).rstrip("/"))
                if not domain_ok(host, "/" + rest if rest else ""): hits.append(f"{path}:{n}: domain: {u}")
            for m in DOMAIN.finditer(URL.sub(" ", EMAIL.sub(" ", line))):
                host, rest = m.group(1).lower(), (m.group(2) or "").rstrip(".,;:")
                seen_domains.add((host + rest).rstrip("/"))
                if not domain_ok(host, rest): hits.append(f"{path}:{n}: domain: {host}{rest}")
            if in_scope and line.strip() not in generic:
                for kind, rx in DATA:
                    m = rx.search(line)
                    if m: hits.append(f"{path}:{n}: data ({kind}): {m.group(0).strip()}  | {line.strip()[:140]}"); break
        for n, line in prose_lines(path, text):
            for w, start in names_in(line, phrases):
                if w in allowed_names: continue
                if start and w[0].isupper() and w[1:].islower() and w.lower() in lower_words: continue
                seen_names.add(w)
                hits.append(f"{path}:{n}: name: {w}")

    if seed:
        print("# names"); print("\n".join(sorted(seen_names)))
        print("# domains"); print("\n".join(sorted(seen_domains)))
        return
    if hits:
        print("\n".join(hits))
        print(f"check-allowlists: {len(hits)} hit(s). Remove client details, or add a genuinely public name, domain or "
              "generic example line to the allowlists (and list it in the report).")
        sys.exit(1)
    print("check-allowlists: OK")

if __name__ == "__main__":
    main()
