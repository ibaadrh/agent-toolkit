---
name: meta-creative-publish
description: The safe way to turn a finished image or video into a live Meta ad. Covers the RGB and size check, uploading by public URL to get an image hash, why creatives are immutable, creating the ad paused, previewing, activating with explicit IDs, verifying the effective status, and AI self-disclosure. Use it whenever a creative goes to Meta Ads, when an upload is rejected, or when an ad "went live" but does not deliver.
---

# Meta creative publish

Getting an ad live on Meta has a fixed order, and most failures come from skipping a step: a palette PNG that Meta rejects, an ad that "succeeded" but never left draft, an edited creative that was never really edited. This skill holds that order. The result is a live ad whose status was read back and whose IDs are written down.

## Config
This skill needs:
- `meta.yaml` (keys: `meta.ad_account_id`, `meta.page_id`, `meta.instagram_account_id`, `meta.ai_disclosure`, `meta.visible_ai_line`)
- `brand.yaml` (keys: `docs.live_state`)

Look in this order: see `core/client-config`. No `meta.ad_account_id` or `meta.page_id`: stop, nothing can be published. An empty `meta.ai_disclosure`: ask the owner before the first upload, and publish no AI-made creative until they answer. `meta.instagram_account_id` is needed only for Instagram placements; without it, publish to Facebook placements and say so.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the account and page
- `core/shopify-cdn-publish` to get a public URL for the file
- `core/brief-contract` for the copy and the `utm_content`
- `core/house-report` for the report

## Inputs
The finished file per ratio, the brief (headline, primary text, destination, `utm_content`), and the ad set it goes into.

## Steps
1. **Check the file.** Open it with a script and check:
   - an image is `mode == "RGB"` (Python: `PIL.Image.open(p).mode`). Convert anything else with `.convert("RGB")` and save again. Meta rejects palette PNGs with error_subcode 2446496.
   - the size is exact for its ratio (for example 1080×1350 for 4:5, 1080×1920 for 9:16).
2. **Check the words.** Every word in the image matches the brief character for character, in the brief's language. Claims come only from the approved list.
3. **Get a public URL.** Meta takes images by URL. Host the file with `core/shopify-cdn-publish`, or any host Meta can fetch.
4. **Upload by URL** ("upload ad media", with the URL as the source and the media type set to image). It returns the image `hash`. The agent's working area may not be able to open the URL itself; Meta can.
5. **Check the account** ("read delivery errors"). Stop on any error that blocks delivery.
6. **Create the creative** from the image hash or video ID ("create an ad creative"), with the page, the copy, the destination with its `utm_content`, and AI self-disclosure set to `meta.ai_disclosure`. **Creatives are immutable**: any change later means a new creative and a new ad.
7. **Create the ad paused** ("create an ad").
8. **Preview it** ("preview an ad") and check it renders: image, headline, text and link.
9. **Activate it with explicit IDs** ("activate an ad, ad set or campaign"), passing the exact object IDs. With draft mode on, nothing goes live without this step.
10. **Read the status back** ("read campaigns, ad sets and ads") and confirm `effective_status` is what you expect. A tool result saying success is a claim, not evidence.
11. **Write the new IDs** (creative, ad) into the live state document.
12. **Report** in the house format: ad ID, effective status, hash, and the AI disclosure value.

## AI disclosure
- Content Credentials from the generator are stripped when the image is re-rendered (for example a layout rendered to PNG in a browser), so Meta will not label it on its own. Set the self-disclosure on the creative instead (step 6).
- For AI video, turn on Meta's "AI info" label the same way.
- Whether a visible "made with AI" line goes in the image itself is the client's choice (`meta.visible_ai_line`). Empty: ask before the first upload.
- An AI person in an ad is never framed as a customer giving a testimonial.

## Output
A live ad with its creative ID, ad ID, image hash and effective status, written to the live state document.

## Known failures
- **Upload rejected with error_subcode 2446496.** Cause: a palette (indexed colour) PNG. Fix: convert to RGB (step 1).
- **Risk: treating an unreachable CDN as a failed upload.** The agent's sandbox blocks the CDN host; Meta does not. Fix: upload by URL and let Meta fetch it (step 4).
- **Risk: editing a creative in place.** Creatives are immutable. Fix: a new creative and a new ad.
- **Risk: an ad that "succeeded" but is still in draft.** Cause: draft mode; nothing goes live without activation with explicit IDs. Fix: steps 9 and 10.
- **Meta did not label an AI image.** Cause: re-rendering stripped Content Credentials. Fix: self-disclosure on the creative.
- **An Instagram feed placement did not deliver.** Cause: the position was set as `feed`; Instagram's main feed is `stream`. The API accepts `feed` and then does not deliver there. Fix: use `stream` when setting placements on the ad set.

## Video upload
- No agent-driven video upload has been tested. The Drive connector cannot pull large files into the working area, and the ad platform's local-file picker is a native dialog the agent cannot operate.
- Until an agent-driven route is tested: deliver the video to the owner (`core/file-delivery`), ask them to upload it, and continue from step 5 with the video ID. Record a working route here when one is found.

## References
- None.
