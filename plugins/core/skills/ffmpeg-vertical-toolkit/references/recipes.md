# ffmpeg recipes for vertical video

**Tested** means the command was run with ffmpeg 9.0 on generated test clips (an 8 s 1920×1080 clip and an 8 s 1080×1920 clip, 30 fps, with tones), and the output was checked as noted. **From the sources, not re-run** means the command comes from a real client job but could not be run on the test machine.

Paths in `<>` are yours to fill. Every command overwrites its output only with `-y`; leave `-y` out if the output might already exist.

## 1. Framing for 9:16 (1080×1920)

**Vertical crop from 16:9** (tested; output 1080×1920, SAR 1:1). Pick X so the subject is centred (0 to 1312 on a 1920 wide source).
```bash
ffmpeg -i <in.mp4> -vf "crop=608:1080:<X>:0,scale=1080:1920,setsar=1" -c:a copy <out.mp4>
```

**Wide shot over a blurred copy of itself** (tested; output 1080×1920, SAR 1:1). `<W>` is 1080 × `video.framing.wide_zoom` (1080 fits the width exactly; more crops the sides). `<blur>` is `video.framing.background_blur` (a `boxblur` value) and `<darken>` is `video.framing.background_darken` (an `eq` brightness, 0 for none).
```bash
ffmpeg -i <in.mp4> -filter_complex "split[a][b];[a]scale=-2:1920,crop=1080:1920,boxblur=<blur>,eq=brightness=<darken>[bg];[b]scale=<W>:-2,crop=1080:ih[fg];[bg][fg]overlay=0:(H-h)/2,setsar=1" -c:a copy <out.mp4>
```

`setsar=1` matters. Without it both recipes leave a pixel aspect ratio a hair off square (1216:1215 and 5120:5121), and the concat filter in section 2 then refuses to join them with other clips ("parameters do not match the corresponding output link").

## 2. Cutting and joining (frame accurate)

Trim each piece with `trim`/`atrim` and join with the concat filter, then re-encode. Never stream copy (`-c copy`) for cuts: it can only cut on keyframes. Tested: two pieces of 2.3 s and 2.0 s joined to 4.30 s and 129 frames.
```bash
ffmpeg -i <a.mp4> -i <b.mp4> -filter_complex "\
[0:v]trim=start=0.6:duration=2.3,setpts=PTS-STARTPTS,setsar=1[v0];[0:a]atrim=start=0.6:duration=2.3,asetpts=PTS-STARTPTS[a0];\
[1:v]trim=start=1:duration=2,setpts=PTS-STARTPTS,setsar=1[v1];[1:a]atrim=start=1:duration=2,asetpts=PTS-STARTPTS[a1];\
[v0][a0][v1][a1]concat=n=2:v=1:a=1[v][a]" \
-map "[v]" -map "[a]" -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a aac -b:a 192k <cut.mp4>
```

**AI video clips:** never use the last 0.25 s. An 8 s generated clip glitches in its final ~0.1 s, so stop every trim at 7.75 s.

## 3. Audio

**Mix and normalise** (tested; one pass landed on the integrated target). Presenter or dialogue first, voice-over or music second. `<loudnorm>` is `video.loudnorm`, written as `I=<target>:TP=<true peak>:LRA=<range>`.
```bash
ffmpeg -i <video_with_presenter.mp4> -i <voiceover.wav> -filter_complex \
"[0:a][1:a]amix=inputs=2:normalize=0,apad,loudnorm=<loudnorm>[a]" \
-map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -shortest <out.mp4>
```
Rules:
- The presenter's audio plays uncut and continuous under their whole section, even across cutaways, so lip-sync stays exact.
- The voice-over starts `video.audio.voiceover_gap_s` after the presenter's section ends (delay it with `adelay=<ms>|<ms>`).
- `normalize=0` keeps `amix` from halving each input's level.

**Music fades** (tested). `<in>` and `<out>` are `video.music.fade_in_s` and `video.music.fade_out_s`; leave a fade out when the key is empty and the owner wants none.
```bash
ffmpeg -ss <start_s> -i <song> -t <length_s> -af "afade=t=in:d=<in>,afade=t=out:st=<length_s - out>:d=<out>" <music.wav>
```
Where the song starts is the client's choice. `scripts/rms_envelope.py <song> drop` reports the time of the drop; `<start_s>` is that time minus `video.music.lead_in_s`, if the client times music to a drop at all.

**Measure loudness** of a finished file:
```bash
ffmpeg -i <file> -af loudnorm=<loudnorm>:print_format=summary -f null - 2>&1 | grep "Input Integrated"
```

## 4. A still image as a clip, with an optional slow zoom

Tested. `<frames>` is `video.end_card.duration_s` × `<fps>`; `<zoom>` is `video.end_card.zoom_per_frame` (0 for a still with no zoom).
```bash
ffmpeg -loop 1 -i <endcard.png> -vf "zoompan=z='zoom+<zoom>':d=<frames>:s=1080x1920:fps=<fps>,setsar=1" -frames:v <frames> -c:v libx264 -pix_fmt yuv420p <endcard.mp4>
```

## 5. Captions (ASS)

From the sources, not re-run (the test machine's ffmpeg has no libass). Burn with:
```bash
ffmpeg -i <in.mp4> -vf "ass=<captions.ass>:fontsdir=<folder with the font files>" -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a copy <out.mp4>
```

Template. Every `<...>` comes from `video.captions`: font, size, colour, outline, position. ASS colours are written blue-green-red (`&H<BB><GG><RR>&`).
```
[Script Info]
ScriptType: v4.00+
PlayResX: 1080
PlayResY: 1920

[V4+ Styles]
Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding
Style: Cap,<font>,<size>,<colour>,<colour>,<outline colour>,&H00000000,<bold -1 or 0>,0,0,0,100,100,0,0,1,<outline>,0,<alignment>,65,65,<margin_v>,1

[Events]
Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text
Dialogue: 0,<start>,<end>,Cap,,0,0,0,,{\pos(<x>,<y>)}Your first line, with one {\c<highlight>}key{\c<colour>} word
```
- Size, colour, outline, alignment, margins and positions are the client's look (`video.captions.*`). With an empty key, ask; never borrow one.
- Whatever the position, keep captions off the product and inside the safe zones below. Check each placement on the QA sheet.
- Time each line to the speech with `scripts/rms_envelope.py <file> words`.

**Safe zones on 1080×1920** (Meta guidance, as quoted by third parties):
| Placement | Keep clear |
|---|---|
| Reels | bottom 35% (672 px) |
| Stories | top 14% (270 px) and bottom 20% (384 px) |
| All | sides 6% (65 px) |

Design to the Reels margins. A 9:16 video in a feed-only placement gets cropped and loses captions near the top (y around 250); run 9:16 video with Reels and Stories placements included.

## 6. Looking at the video (contact sheets and strips)

**Keyframe contact sheet of raw footage** (tested without the timestamp). One thumbnail every 4 s or more:
```bash
ffmpeg -skip_frame nokey -i <IMG.MOV> -vf "select='isnan(prev_selected_t)+gte(t-prev_selected_t\,4)',scale=180:-1,tile=10x6" -fps_mode vfr -frames:v 1 <sheet.jpg>
```
The source job also stamped each thumbnail with its time by adding `drawtext=text='%{pts\:hms}':x=4:y=4:fontsize=18:fontcolor=yellow:box=1:boxcolor=black@0.6` before `tile` (needs ffmpeg with freetype; not re-run). On ffmpeg 7 and later, `-vsync vfr` is `-fps_mode vfr`.

**QA sheet of a finished vertical video**, one frame every 2.5 s (tested):
```bash
ffmpeg -i <final.mp4> -vf "fps=1/2.5,scale=216:384,tile=11x2" -frames:v 1 <qa.jpg>
```

**Frame strip of an AI clip**, 2 to 4 frames a second (tested):
```bash
ffmpeg -i <clip.mp4> -vf "fps=3,scale=270:-1,tile=8x1" -frames:v 1 <strip.jpg>
```

## 7. Automatic checks

All three scripts are in `scripts/`, use only the Python standard library plus ffmpeg, and were tested on clips with known answers.
- **Frame-difference spike scan:** `python3 scripts/frame_spikes.py <video> 3`. Flags frames that differ from the previous one by more than 3× the median. Tested: found the planned cut at 2.300 s (41.9× the median) and nothing else. A spike inside an AI clip is a glitch.
- **RMS envelope:** `python3 scripts/rms_envelope.py <file> words` lists sound bursts (tested: found 1.00 to 1.80 s and 2.40 to 3.60 s exactly). `... drop` reports the time of the largest loudness jump and nothing else (tested: found 4.00 s).
- **Voice pitch:** `python3 scripts/voice_pitch.py <file> <start_s> 1`. Tested: 130 Hz and 150 Hz tones read as 130 and 150. Two clips of the same presenter should land within about 5 Hz; 130 against 150 is audible.

Frame count of any file (use it after every join and against a timeline):
```bash
ffprobe -v error -count_packets -select_streams v:0 -show_entries stream=nb_read_packets -of csv=p=0 <file>
```

## 8. Review copy and size limits

**Review re-encode** (tested). A keyframe every 60 frames, so the file can be cut into parts cleanly:
```bash
ffmpeg -i <final.mp4> -c:v libx264 -crf 20 -maxrate 12M -bufsize 24M -g 60 -keyint_min 60 -sc_threshold 0 -c:a copy <review.mp4>
```

**Split into parts and join again** (tested: 240 frames before, 240 after). Parts can use stream copy because the review copy has regular keyframes. Use a segment length that keeps each part under the size cap (14 s at the bitrate above stays under 30 MB).
```bash
ffmpeg -i <review.mp4> -f segment -segment_time 14 -reset_timestamps 1 -c copy part_%03d.mp4
for f in part_*.mp4; do echo "file '$f'"; done > list.txt
ffmpeg -f concat -safe 0 -i list.txt -c copy <joined.mp4>
```
Then compare the frame counts of the review copy and the joined file. The delivery steps are in `core/file-delivery`.
