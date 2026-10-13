#!/usr/bin/env python3
"""Flag frames whose difference from the previous frame is more than N times the median.

Usage: frame_spikes.py <video> [multiple=3]
Prints one line per spike: frame number, time in seconds, difference, multiple of the median.
A spike inside an AI clip is a glitch or a morph; at a planned cut it is expected.
Needs ffmpeg on PATH. Standard library only.
"""
import re, statistics, subprocess, sys

def diffs(path):
    cmd = ["ffmpeg", "-hide_banner", "-nostats", "-i", path, "-vf",
           "tblend=all_mode=difference,signalstats,metadata=print:key=lavfi.signalstats.YAVG",
           "-an", "-f", "null", "-"]
    out = subprocess.run(cmd, capture_output=True, text=True).stderr
    vals, times = [], []
    for line in out.splitlines():
        t = re.search(r"pts_time:([0-9.]+)", line)
        if t: times.append(float(t.group(1)))
        v = re.search(r"lavfi\.signalstats\.YAVG=([0-9.]+)", line)
        if v: vals.append(float(v.group(1)))
    return list(zip(times, vals))

def main():
    path = sys.argv[1]; mult = float(sys.argv[2]) if len(sys.argv) > 2 else 3.0
    d = diffs(path)
    if not d: sys.exit("no frames read; is ffmpeg on PATH and the file a video?")
    med = statistics.median(v for _, v in d) or 1e-6
    hits = [(i + 1, t, v) for i, (t, v) in enumerate(d) if v > mult * med]
    print(f"{len(d)} frame pairs, median diff {med:.3f}, threshold {mult}x")
    for f, t, v in hits:
        print(f"frame {f}  t={t:.3f}s  diff={v:.2f}  ({v/med:.1f}x median)")
    if not hits: print("no spikes")

if __name__ == "__main__":
    main()
