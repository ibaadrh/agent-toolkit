---
name: firefly-web-driver
description: Driving Adobe Firefly (firefly.adobe.com) from a browser the agent controls, for image generation (Nano Banana Pro and other models), video generation from a first frame (Veo), and Firefly Speech voice-overs. Covers the in-page helper set, the desktop viewport, the 45-second script limit, reference uploads, harvesting results before Firefly revokes them, downloads and rename-by-size, and the model drift check. Use it whenever a skill generates images, video or speech in Firefly.
---

# Firefly web driver

Firefly has no API for this work, so the agent drives the website. Its UI sits inside shadow DOM, its inputs ignore typed keys, it hides its settings in a narrow window, and it throws away results when it re-renders. This skill holds the helper script and the order of operations that work around all of that. The result is generated images, clips or audio sitting as named files in the user's Downloads folder, ready to judge.

Last verified: 2026-10-15 (image), 2026-10-13 (video and Speech). Adobe changes the UI; step 1 checks before every run.

## Config
This skill needs: `references.yaml` (keys: `reference_pack`), `brand.yaml` (keys: `brand.image_style.reference_background`), `video.yaml` (keys: `video.tts.voice`, `video.tts.languages`), `ads.yaml` (keys: `ads.video.credits_per_clip`, `ads.video.min_credit_balance`). Defaults (the author's; a client's config or the calling skill can override): Nano Banana Pro at 2K for images, 4:5 for feed images and 9:16 for vertical, references on light grey `#EDEDED`.
Look in this order: see `core/client-config`. Image runs work with an empty config (references then come from the calling skill). For video, an empty credit floor means: report the balance and the round's cost, and ask before spending.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/ai-image-prompting` for the prompt itself
- `core/shopify-cdn-publish` to put reference images at a public URL
- `core/browser-automation-hygiene` for hidden pages, stale screenshots and native dialogs
- `core/product-accuracy-check` to judge every candidate with a real product in it
- `core/file-delivery` for moving files off the user's machine

## Steps
1. **Check the selectors still match before a run.** Open the page, paste `scripts/firefly-helpers.js` ("run JavaScript in the browser page"), and run `__checkSelectors('image')` (or `'video'`, `'speech'`). Anything `missing` means Adobe changed the UI. Find the new element with `deep(document, '<rough selector>').map(path)`, update the helper and `__SELECTORS`, then note the date at the top of the helper file and here.
2. **Use one browser.** Run Firefly in the browser where the user's Firefly account is signed in, and stay in it for the whole job. Ask the client which one if it is not in the brief.
3. **Open the right page:** `https://firefly.adobe.com/generate/image` for images. Video and Speech are reached from Firefly's menu.
4. **Emulate a desktop window.** A narrow browser pane makes Firefly fall back to its compact layout and hide the settings panel. Resize the window to 1440×900 while driving it ("resize the browser window"), and set it back to the desktop preset before taking screenshots and when done.
5. **Wake a hidden page.** If the browser pane is hidden, a fresh page can stay blank. Take one screenshot to wake it, then `await __waitFor('sp-picker[data-testid="firefly-picker-model"]')`.
6. **Paste the helpers after every navigation.** A page load wipes them.
7. **Respect the 45-second limit.** One browser script call gives up after about 45 s. Run one generation per call, or start one in the background (`window.__bg = __genOne()`) and check `__gen.length` in later calls.
8. **Settings (images).**
   1. Model: `await __pick('firefly-picker-model', 'firefly-menu-item-google:firefly:colligo:nano-banana-pro')` for Nano Banana Pro (default). For another model, read its item id from `__pickers()` and the open menu.
   2. Ratio: `await __pick('firefly-picker-size', 'firefly-menu-item-standard')` for 4:5 (default for feed images), `'firefly-menu-item-vertical'` for 9:16 (default for vertical).
   3. Resolution: check the panel reads 2K (default) or what the calling skill asked for.
   4. Cost: read `__cost()`. If it is not free on this plan, state the cost before generating.
9. **References.**
   1. `await __clearRefs()`, then add each one in the calling skill's slot order: `await __addRef(await __crop('<public URL>', [0,0,1,1]), '<name>.jpg')` (pass a third argument only when `brand.image_style.reference_background` overrides the grey).
   2. `__addRef` always writes to the last file input. Each filled slot gets its own input, and writing to the first one replaces slot 1.
   3. Check the panel reads the count you added ("Images (n/6)"; up to 6 for Nano Banana Pro).
   4. Images move in only by in-page fetch of a public URL. Never pass image bytes or base64 through your own messages. A browser page cannot read the user's disk, and Drive links are blocked inside Firefly; host references with `core/shopify-cdn-publish`.
   5. Never click "Your device". It opens a native file dialog that agent tools cannot operate.
10. **Prompt.** `__prompt(text)` (the field ignores typed keys; this uses insertText). It returns the length; stay under 1,000 characters or the run fails with a generic "Something went wrong".
11. **Generate and harvest.** Run `await __seedKnown()` once, so images already on the page are not counted. Then `await __genOne(<output width in px>)` per candidate (the full-size width for the chosen ratio and resolution, so thumbnails are skipped). It clicks Generate and keeps each new full-size image as a Blob in `window.__gen`, because Firefly revokes blob URLs when it re-renders. Make every candidate the calling skill asks for (by default at least 6 to 8).
12. **Download and rename by size.**
   1. Note each Blob's size (`__gen.map(b => b.size)`), then `__dl(i, '<name>.png')` about 2.5 s apart.
   2. The files land in the user's Downloads folder. In Claude Desktop they can land as hidden temp files (`~/Downloads/.<random>.com.anthropic.claudefordesktop.*`) without the given name. On the user's machine ("run a shell command on the user's machine"), list them with their sizes and `mv -n` each one whose size matches a Blob into the job folder under its proper name.
   3. If scripted downloads stop producing files, click Firefly's own download button instead, then rename the same way.
   4. Copy the files into the working area to judge them at full size ("copy a file from the user's machine into the working area"). Browser screenshots come back about 580 px wide, too small to judge detail.
   5. The first download in a session can need one folder-access grant for Downloads.
13. **Video (first frame plus clip).**
   1. Store the first frame as a data URL in sessionStorage, then `await __setFrame('<key>', '<name>.png')`.
   2. Check it went in: `await __frameDiff(<frame panel thumbnail element>, '<key>')` should be about 0.
   3. Prompt: `__setPrompt(text)`, at most 512 characters (template in `core/ai-image-prompting`).
   4. **Check the model before every generation**: `__pickers()` must show the intended model (for example "Google - Veo 3.1"). The model list overlaps other panels, and a stray click has switched it to a different model.
   5. Check the credit balance first and say what the round costs (`ads.video.credits_per_clip` per clip). Below `ads.video.min_credit_balance`, stop.
   6. Download from the player's download icon (it often needs a second click), or `await __dlMedia('video', '<name>.mp4')`. Rename as in step 12.
14. **Firefly Speech.** `__speechText(text)` (the box is contenteditable and ignores typed keys), then `await __speechLang('<code>')` with a code from `video.tts.languages`. Pick the voice in `video.tts.voice`. If either key is empty, ask. Download with `await __dlMedia('audio', '<name>.wav')` or the player icon.
15. **Report** in the house format: candidates made, model, credits spent.

## Output
Named files in the job folder on the user's machine and in the working area, plus the prompt and reference list used.

## Known failures
- **Scripts died mid-generation.** Cause: the browser script call gives up after about 45 s. Fix: one generation per call, or a background run (step 7).
- **Generated images vanished before they were saved.** Cause: Firefly revokes blob URLs when it re-renders. Fix: harvest into Blobs at once (step 11).
- **The settings panel was missing.** Cause: the narrow pane switched Firefly to its compact layout. Fix: emulate 1440×900 (step 4).
- **A fresh page stayed blank.** Cause: the browser pane was hidden. Fix: one screenshot to wake it, then wait for the model picker (step 5).
- **A new reference replaced the first one.** Cause: writing to the first file input. Fix: always the last input (step 9.2).
- **A base64 image arrived corrupted.** Cause: passing image data through the agent's messages. Fix: in-page fetch of a public URL only (step 9.4).
- **References could not be loaded from the Mac or Drive.** Cause: the browser cannot read local disk, and Drive links are blocked by CORS inside Firefly (tested). Fix: public hosting (step 9.4).
- **Downloads arrived as hidden temp files, and once stopped appearing at all.** Cause: scripted downloads behave differently with the pane hidden. Fix: rename by size; fall back to Firefly's own download button (step 12).
- **The video model switched itself to another model.** Cause: a stray click in the overlapping model list. Fix: check the model before every generation (step 13.4).
- **Typing into the prompt or Speech box did nothing.** Cause: contenteditable fields ignore key events. Fix: insertText, or the native setter for the video textarea.
- **A screenshot still showed the previous state.** Cause: screenshots can lag a change. Fix: wait a second and take it again.
- **The prompt failed with "Something went wrong".** Cause: over 1,000 characters (step 10).

## References
- `scripts/firefly-helpers.js`: the helper set, with the selector table and the last-verified dates.
