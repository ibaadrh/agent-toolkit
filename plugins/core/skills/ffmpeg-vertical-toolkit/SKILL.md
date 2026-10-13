---
name: ffmpeg-vertical-toolkit
description: Tested ffmpeg recipes and checks for vertical (9:16) video, for ads, reels and UGC-style edits. Covers 9:16 crop and blur-background framing, frame-accurate trims joined by concat with re-encode, trimming the end of AI clips, the loudnorm audio chain, ASS captions inside Reels and Stories safe zones, contact sheets and frame strips, the frame-difference spike scan, the RMS envelope for word timing and finding a music drop, voice-pitch matching, and the review re-encode with split and join for size limits. Use it whenever a skill edits, checks or delivers a vertical video.
---

# ffmpeg vertical toolkit

Short vertical edits fail in the same few ways: a cut lands on the wrong frame, two clips will not join, the presenter's voice changes halfway, a caption sits under the platform's buttons, an AI clip glitches in its last frames. This skill holds the recipes and checks that prevent those, each tested. The result is a finished 1080×1920 video that has been looked at, measured and checked before anyone sees it.

## Config
This skill needs: `video.yaml` (keys: `video.captions.font`, `video.captions.highlight_color_ass`, `video.loudnorm`, `video.default_ratio`).
Look in this order: see `core/client-config`. Defaults when a key is empty: loudness `I=-14:TP=-1.5:LRA=9`; captions bold white with a black outline in any clean sans-serif the client has a licence for, ask which; no highlight colour (all white).

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/file-delivery` to deliver the result, including the size-limit split and join
- `core/house-report` for the report (runtime, file size, what was checked)

## Inputs
The source clips, the edit plan (what goes where, in seconds), the audio (presenter, voice-over, music), and the caption lines.

## Steps
1. **Survey the footage.** `ffprobe` every clip (size, frame rate, rotation, duration). Make a keyframe contact sheet of each and look at it before choosing segments. Phone footage at 4K, 60 fps, rotated 90° is normal.
2. **Frame each shot for 9:16.** Tight shots: the vertical crop. Wide shots: 1.3× over a blurred copy of itself. Add `setsar=1` to both (recipes, section 1).
3. **Cut frame-accurately.** `trim`/`atrim` per piece, the concat filter, then re-encode. Never stream copy for cuts. Never use an AI clip past its last 0.25 s (stop an 8 s clip at 7.75 s).
4. **Build the audio.** Presenter audio uncut under their section; voice-over 0.05 s after; music faded in and out, started about 3 s before its drop; `amix normalize=0` → `apad` → `loudnorm` → AAC 192k.
5. **Caption.** ASS file at 1080×1920. Keep text inside the Reels and Stories safe zones and off the product. Time each line to the speech with the RMS envelope. Add no grain and no filters; natural looks better.
6. **Check before anyone sees it.**
   1. A QA contact sheet of the final (one frame every 2.5 s), and a frame strip of every AI clip. Look at them.
   2. Crop the product in the AI clips frame by frame: right shape, right logo, lights in the right state, no morphing. Cut away from any frame that drifts.
   3. Run the frame-difference spike scan. Any spike that is not a planned cut is a glitch.
   4. If more than one clip of the same presenter is used, compare their voice pitch.
   5. Compare the presenter's face against the last approved version. Waxy or bumpy skin: do not ship.
   6. Check the frame count of the final against the edit plan, and the loudness.
7. **Make the review copy** with regular keyframes (`-g 60`), and hand it to `core/file-delivery`. Never overwrite a version the owner has seen; bump the version.

All commands are in `references/recipes.md`. The checks are scripts in `scripts/`.

## Output
The finished video, its review copy, the QA sheet, and the check results (spikes found, pitch per clip, frame count, loudness), reported in the house format with runtime and file size.

## Known failures
- **Two clips refused to join** ("parameters do not match the corresponding output link"). Cause: the crop and blur recipes leave a pixel aspect ratio a hair off square (1216:1215, 5120:5121). Found while testing these recipes. Fix: `setsar=1` (step 2).
- **The presenter looked fake.** Cause: an AI image edit of the first frame exaggerated skin pores and bumps, and the video model carried it through. Fix: patch small product details with pixels, never an AI re-edit of a face (`core/ai-image-prompting`), and check the face (step 6.5).
- **The presenter's voice changed mid-ad** (one clip clearly lower than the others). Cause: two separate generations of the same presenter cut together. Fix: one presenter clip per language, its audio uncut; the voice-over only plays over product footage. Check pitch (step 6.4).
- **Glitches at the end of AI clips, and the product morphing when the presenter moved it.** Fix: stop at 7.75 s of 8; use the presenter only while the product looks right, and cut to real footage over hand movement.
- **Captions near the top disappeared in the feed.** Cause: a 9:16 video in a feed-only placement is cropped. Fix: include Reels and Stories placements; keep captions inside the safe zones.
- **Word timings could not be made with a speech model.** Cause: the sandbox could not download the model. Fix: the RMS envelope script.
- **Risk: cuts landing on the wrong frame.** Stream copy cuts only on keyframes. Fix: trim and re-encode (step 3).
- **Risk: a timeline built on wrong frame counts.** Fix: count packets with `ffprobe -count_packets` before writing any timeline.

## References
- `references/recipes.md`: every command, marked tested or from the sources.
- `scripts/frame_spikes.py`, `scripts/rms_envelope.py`, `scripts/voice_pitch.py`: the automatic checks (Python standard library plus ffmpeg).
