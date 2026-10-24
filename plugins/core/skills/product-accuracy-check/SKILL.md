---
name: product-accuracy-check
description: The gate every AI image or 3D render with a real physical product must pass before design work starts. A measured silhouette check with foreshortening correction, a feature checklist driven by product-spec.md, cable and connector physics, which end is which, the brand look-alike gate, honest retouches only, the fallback ladder (paste-back from reference renders, plate-first, references only), and the candidate verdict log. Use it on every generated candidate and every render before it goes into an ad, and whenever someone says "that's not my product".
---

# Product accuracy check

Image models redraw the product every time; they never copy its pixels. A result can get every feature right and still show the wrong object: too thin, too long, the wrong ends, a cable that plugs into nothing. This skill is the gate that catches that, by measuring instead of eyeballing, and the ladder of what to do when nothing passes. The result is a verdict per candidate, written in the log, and only passed candidates move on.

## Config
This skill needs: `product-spec.md` (all fields: dimensions, silhouette ratio and its tolerance, corner radius, finish and colour, logo, buttons, ports, lights and their default state, cables and which end is which, the fail list, reference images, render index), `references.yaml` (keys: `reference_pack`, `banned_assets`), `brand.yaml` (keys: `docs.playbook`).
Look in this order: see `core/client-config`. **No `product-spec.md`: stop.** Without measured facts the check is guessing. Ask for the spec, or offer to build it from the CAD file and the real photos. The silhouette tolerance, the cable-length band and the paste-back limits come from the spec; if one is empty, ask the owner for it.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the spec
- `core/ai-image-prompting`: the fail list feeds the prompt's "not a ..." words, and a failure here names what the next prompt must fix
- `core/house-report` for the report (candidates checked, passed, main reasons)

## Inputs
Each candidate image at full size, the real reference photos, and, if they exist, the reference renders with their camera angles (elevation and azimuth) from the render index.

## Steps
**The gate comes before any design work. Any doubt is a no. "Close enough" never ships.**

1. **Look at the product at 1:1.** Crop the product region of the full-size file and look at it next to the real reference photos. Never judge from a browser screenshot; it is too small. If reference renders exist, also overlay the closest one at the same scale at 50% opacity.
2. **Measure the silhouette, do not eyeball it.**
   1. Measure the product's long and short side in pixels along its top face.
   2. Correct for foreshortening: a side running away from the camera looks shorter by about the sine of the camera's elevation. So true ratio ≈ long ÷ (short ÷ sin(elevation)) when the short side runs away from the camera, and the other way round when the long side does.
   3. Near top-down, the corrected ratio must be within the spec's tolerance. At low angles, compare against the closest render instead of the number.
   4. Check thickness against the spec, and the shape seen from above (corners, ends).
   5. Fail anything on the spec's fail list (for example: rounder, flatter, longer, thinner or boxier than the real shape).
3. **Check every feature against the spec.**
   1. Logo: right size, position and finish. Fail a detailed redraw, an oversized logo, a logo moved to the centre, or one inside a badge.
   2. Finish and colour: exactly as the spec. Fail glossy for matte, grey or silver for black, and similar swaps.
   3. Lights: in the spec's default state. Fail a long glowing bar, a dash in the wrong place, any coloured glow.
   4. Buttons and ports: right number, side and end.
   5. Printed text and marks: any face shown must carry what the real face carries. A back view without the real back print fails.
4. **Check which end is which** (when the ends differ). Models swap ends often. For each end, check what connects there and what sits there (button, logo) against the spec.
5. **Check cables and connectors** (skip when the product has none). For products with cables, this is where most candidates fail.
   1. The product's own cable: right type (flat or round, braided or smooth), right width relative to the product, right length relative to the product (within the spec's accepted band), right plug housings and collars, prints the right colour on the right plug.
   2. Any other cable (a charger): right thickness and plug type, in the right end.
   3. Every plug fully seated in a real port, centred on the end, with true proportions. The other device has a visible port where the cable enters.
   4. Physics: cables rest on the surface with natural slack and gravity, cast contact shadows, have no floating ends, and the chain is continuous from device to product to charger.
6. **Check scale** against hands and other objects in the scene.
7. **Check people and the scene.**
   1. No AI artefacts in skin, eyes or teeth; five fingers on every hand.
   2. One light direction.
   3. No gibberish text anywhere.
   4. **Brand look-alike gate:** no other brand's logo on anything, and no device that reads as a famous brand's product (for example coloured A/B/X/Y face buttons on a game controller). One visible third-party logo is a fail.
   5. The text zones the layout reserved are clean.
8. **Honest retouches only.** Allowed: removing a wrong extra feature (a second or misplaced button), or neutralising a look-alike detail (recolouring coloured face buttons dark grey). Never paint in a missing feature, reshape the product or lengthen a cable; regenerate instead. Note every retouch in the log.
9. **Log every candidate**, pass or fail, in `docs.playbook`:

   | Candidate | Method | Corrected ratio | Checks failed | Retouch | Verdict |
   |---|---|---|---|---|---|

10. **If nothing passes, climb the ladder** (stop at the first that passes):
    1. **Paste-back** (when reference renders exist and only the product failed; scene, person and cables passed): take the render whose elevation and azimuth are closest to the generated product, rotate and scale it in-plane to the generated product's footprint, and composite it with its shadow so it covers the whole generated product. Re-run steps 2 to 7. Reject if the angle differs by more than the spec's paste-back limit, or visibly when it has none, or if the cables no longer meet the plugs.
    2. **Regenerate** with a prompt that names the failure.
    3. **An edit-image pass** with the same references (fix prompt in `core/ai-image-prompting`).
    4. **A real photo**, or a render plate.

## Choosing the method up front (strictest first)
1. **Paste-back** is the default for heroes once reference renders exist.
2. **Plate-first** for macro and flat-lay layouts: start from a render plate (beauty, product layer, mask, camera), generate only the surroundings, then lay the product layer back at identical pixel coordinates. Reject if the generator moved the table or the framing (a mask edge offset beyond the spec's limit, or any visible offset when it has none).
3. **References only** while there are no renders, or when the product is smaller in the frame than the spec's paste-back limit. It still passes the measured check.

## Renders get checked too
A render of the real CAD is not automatically right. Check every render against the real photos before first use, exactly like an AI candidate. Never model the product from scratch or with an AI 3D tool; use only CAD-derived models. Old marketing renders are not a source for details.

## Output
A verdict per candidate in the log, the passed candidates (with any retouch noted), and, when nothing passed, which ladder step is next.

## Known failures
- **The owner rejected a hero: "not my actual product".** It had passed a feature-only check, but the product came out far longer and thinner than the real one. Fix: measure the silhouette (step 2).
- **Rounded, squat and boxy shapes; a detailed logo in a badge.** Cause: loose shape words and whole lifestyle photos as references. Fix: measured shape words in the prompt and the fail list here.
- **The cable was judged against the wrong facts for weeks.** The written spec described a different finish and listed the real finish as a failure. Fix: check the spec itself against calipers and the real product, not older notes.
- **Loose plug ends, extra cables running nowhere, a cable entering the long side.** Fix: step 5, and spell out the chain in the prompt.
- **Cable lengths far off, both much too short and much too long.** Fix: the length band in step 5.1.
- **The button and the logo at the same end; the cable in the wrong end.** Fix: step 4 on every candidate.
- **A product far too wide for its length.** Fix: step 2.
- **A real third-party logo on headphones; controllers that read as a famous console's.** Fix: the look-alike gate (step 7.4) and generic device names in the prompt.
- **A render still caught the plug half inserted.** Cause: a frame grabbed mid-animation. Fix: check renders like candidates. It was fixed by sliding the plug rows in, a whole number of texture repeats so the pattern stayed seamless.
- **A back render lacked the printed markings.** Fix: step 3.5; the render was not used until the model had the print.
- **Old marketing renders disagreed with the CAD on the back face.** Fix: the CAD is the truth for shape, real photos for print and marks; old renders are never a source for details.

## References
- `templates/client-config/product-spec.md` in the toolkit repo: the fields this check reads.
