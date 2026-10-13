#!/usr/bin/env python3
"""RMS loudness envelope of an audio or video file, for timing captions to speech and finding a music drop.

Usage:
  rms_envelope.py <file> words [window_s=0.05] [threshold_db=-35]   start and end of each sound burst (speech)
  rms_envelope.py <file> drop  [window_s=0.5]                       the window with the largest loudness jump
Needs ffmpeg on PATH. Standard library only.
"""
import math, re, subprocess, sys

def envelope(path, win):
    cmd = ["ffmpeg", "-hide_banner", "-nostats", "-i", path, "-vn", "-ac", "1", "-ar", "48000", "-af",
           f"asetnsamples=n={int(48000*win)}:p=0,astats=metadata=1:reset=1,"
           "ametadata=print:key=lavfi.astats.Overall.RMS_level", "-f", "null", "-"]
    out = subprocess.run(cmd, capture_output=True, text=True).stderr
    times, levels = [], []
    for line in out.splitlines():
        t = re.search(r"pts_time:([0-9.]+)", line)
        if t: times.append(float(t.group(1)))
        v = re.search(r"RMS_level=(-?[0-9.]+|-inf)", line)
        if v: levels.append(-120.0 if v.group(1) == "-inf" else float(v.group(1)))
    return list(zip(times, levels))

def words(env, thr, win):
    bursts, start = [], None
    for t, db in env:
        if db > thr and start is None: start = t
        if db <= thr and start is not None: bursts.append((start, t)); start = None
    if start is not None: bursts.append((start, env[-1][0] + win))
    return bursts

def main():
    path, mode = sys.argv[1], sys.argv[2]
    if mode == "words":
        win = float(sys.argv[3]) if len(sys.argv) > 3 else 0.05
        thr = float(sys.argv[4]) if len(sys.argv) > 4 else -35.0
        for a, b in words(envelope(path, win), thr, win):
            print(f"{a:7.2f} -> {b:7.2f}  ({b-a:.2f}s)")
    elif mode == "drop":
        win = float(sys.argv[3]) if len(sys.argv) > 3 else 0.5
        env = envelope(path, win)
        jumps = [(env[i][0], env[i][1] - env[i-1][1]) for i in range(1, len(env))]
        t, j = max(jumps, key=lambda x: x[1])
        print(f"largest jump +{j:.1f} dB at {t:.2f}s; start the music about 3 s earlier ({max(0, t-3):.2f}s)")
    else:
        sys.exit("mode must be words or drop")

if __name__ == "__main__":
    main()
