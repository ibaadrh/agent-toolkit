---
name: browser-automation-hygiene
description: House rules for any skill that drives a real browser: wake a page in a hidden pane with one screenshot, retake a screenshot that may still show the previous state, and never trigger a native dialog (move files in by in-page fetch of a public URL instead). Use it whenever a skill navigates, reads or clicks in a browser page.
---

# Browser automation hygiene

Browser runs fail quietly. A page in a hidden pane stays blank, a screenshot still shows the state from before the last change, and a button opens a system window the agent cannot touch. This skill holds the general rules that stop those, learned while driving Firefly. Steps for one site live in that site's skill (for example `core/firefly-web-driver`).

## Config
This skill needs: none.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/platform-adapters` for the browser actions ("take a screenshot of the browser page", "run JavaScript in the browser page")
- `core/shopify-cdn-publish` to put a file at a public URL when it has none

## Steps
1. **Wake a hidden page.** If the browser pane is hidden, a fresh page can stay blank after a navigation. Take one screenshot to wake it, then wait for an element you know the page shows before you read or click.
2. **Distrust stale screenshots.** Right after a change, a screenshot can still show the previous state. Wait a second and take it again.
3. **Never trigger a native dialog.** A site's "choose file" button, a system print dialog or a download prompt opens a window outside the page that agent tools cannot operate. Move files in by in-page fetch of a public URL instead.

## Output
A run where every screenshot acted on showed the current page, and no step waited on a window the agent cannot reach.

## Known failures
- **A page stayed blank in a hidden browser pane, and a screenshot showed the previous state.** Fix: one screenshot to wake it, then wait (step 1); retake stale screenshots (step 2).
- **A site's own file picker could not be used.** It opens a native window outside the page. Fix: in-page fetch of a public URL (step 3).

## References
- None.
