#!/usr/bin/env python3
"""Check copy against the default hard rules and a client's voice.yaml before it ships.

Usage: check_copy.py <copy.txt | -> [--voice voice.yaml] [--lang <code>]
Prints FAIL and WARN lines; exits 1 if anything FAILs. Standard library only
(uses PyYAML when installed, otherwise reads the simple list format of the toolkit template).

FAIL: em dash or spaced en dash; "up to" with a number; a banned word or phrase from voice.yaml;
      a number claim not covered by voice.approved_claims (only when the list is filled);
      a [placeholder] left in the text.
WARN: emoji; exclamation marks (when voice.tone says "no exclamation"); first-person buying language
      that reads like a testimonial.
"""
import re, sys

def load_voice(path):
    try:
        import yaml  # optional
        d = yaml.safe_load(open(path, encoding="utf-8")) or {}
        v = d.get("voice", d)
        return {k: v.get(k) for k in ("tone", "banned_words", "banned_phrases", "approved_claims")}
    except ImportError:
        pass
    out, key = {"tone": "", "banned_words": [], "banned_phrases": [], "approved_claims": []}, None
    for raw in open(path, encoding="utf-8"):
        line = raw.split(" #")[0].rstrip()
        m = re.match(r"^\s*(tone|banned_words|banned_phrases|approved_claims):\s*(.*)$", line)
        if m:
            key, rest = m.group(1), m.group(2).strip()
            if key == "tone":
                out["tone"] = rest.strip("\"'"); key = None
            elif rest.startswith("["):
                out[key] = [x.strip().strip("\"'") for x in rest.strip("[]").split(",") if x.strip()]; key = None
            continue
        m = re.match(r"^\s*-\s+(.*)$", line)
        if key and m:
            out[key].append(m.group(1).strip().strip("\"'"))
        elif line.strip() and not line.startswith(" " * 4):
            key = None
    return out

EMOJI = re.compile("[\U0001F300-\U0001FAFF\U00002600-\U000027BF\U0001F000-\U0001F2FF]")
NUMBER_CLAIM = re.compile(r"[+\-]?\d+(?:[.,]\d+)?\s?(?:%|x\b|×)|\b\d+(?:[.,]\d+)?\s?(?:times|hours?|years?|days?)\b", re.I)
TESTIMONIAL = re.compile(r"\b(I|we) (bought|ordered|love(d)? (it|this|my)|use (it|this) every)\b", re.I)

def check(text, voice):
    fails, warns = [], []
    for m in re.finditer(r"—|\s–\s", text):
        fails.append(f"em dash or spaced en dash: ...{text[max(0,m.start()-20):m.end()+20]!r}...")
    for m in re.finditer(r"\bup to\s+[+\-]?\d", text, re.I):
        fails.append(f'"up to" with a number; write "as much as": ...{text[max(0,m.start()-10):m.end()+15]!r}...')
    low = text.lower()
    for w in voice.get("banned_words") or []:
        if re.search(r"\b" + re.escape(w.lower()) + r"\b", low): fails.append(f"banned word: {w!r}")
    for p in voice.get("banned_phrases") or []:
        if p.lower() in low: fails.append(f"banned phrase: {p!r}")
    for m in re.finditer(r"\[[^\]]+\]", text):
        fails.append(f"placeholder left in: {m.group(0)!r}")
    claims = [c.lower() for c in (voice.get("approved_claims") or [])]
    if claims:
        for sent in re.split(r"(?<=[.!?])\s+|\n+", text):
            if NUMBER_CLAIM.search(sent) and not any(c in sent.lower() for c in claims):
                fails.append(f"number claim not on the approved list: {sent.strip()!r}")
    elif NUMBER_CLAIM.search(text):
        warns.append("number claims found but voice.approved_claims is empty; check them by hand")
    if EMOJI.search(text): warns.append("emoji found")
    if "!" in text and "no exclamation" in (voice.get("tone") or "").lower(): warns.append("exclamation mark, but the tone bans them")
    for m in TESTIMONIAL.finditer(text): warns.append(f"reads like a testimonial: {m.group(0)!r}")
    return fails, warns

def main():
    args = sys.argv[1:]
    if not args: sys.exit(__doc__)
    voice = {}
    if "--voice" in args:
        i = args.index("--voice"); voice = load_voice(args[i + 1]); del args[i:i + 2]
    src = args[0]
    text = sys.stdin.read() if src == "-" else open(src, encoding="utf-8").read()
    fails, warns = check(text, voice)
    for f in fails: print("FAIL", f)
    for w in warns: print("WARN", w)
    if not fails and not warns: print("OK")
    sys.exit(1 if fails else 0)

if __name__ == "__main__":
    main()
