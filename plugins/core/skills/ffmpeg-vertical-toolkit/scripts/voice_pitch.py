#!/usr/bin/env python3
"""Estimate the speaking pitch (F0) of a clip by autocorrelation, to check two clips have the same voice.

Usage: voice_pitch.py <file> [start_s=0] [length_s=1.0]
Prints the estimated F0 in Hz. Compare clips of the same person;
a gap like 130 Hz against 150 Hz is audible. Measure a stretch where the person is speaking.
Needs ffmpeg on PATH. Standard library only.
"""
import array, subprocess, sys

RATE = 16000

def samples(path, start, length):
    cmd = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-ss", str(start), "-t", str(length), "-i", path,
           "-vn", "-ac", "1", "-ar", str(RATE), "-f", "s16le", "-"]
    raw = subprocess.run(cmd, capture_output=True).stdout
    a = array.array("h"); a.frombytes(raw)
    return a

def f0(x, lo=60, hi=400):
    n = len(x)
    if n < RATE // 10: return None
    mean = sum(x) / n; x = [v - mean for v in x]
    best, best_lag = 0.0, None
    for lag in range(RATE // hi, RATE // lo):
        s = sum(x[i] * x[i + lag] for i in range(0, n - lag, 2))
        if s > best: best, best_lag = s, lag
    return RATE / best_lag if best_lag else None

def main():
    path = sys.argv[1]
    start = float(sys.argv[2]) if len(sys.argv) > 2 else 0.0
    length = float(sys.argv[3]) if len(sys.argv) > 3 else 1.0
    hz = f0(samples(path, start, length))
    print(f"F0 about {hz:.0f} Hz" if hz else "no clear pitch (silence or noise?)")

if __name__ == "__main__":
    main()
