---
name: ai-image-prompting
description: Rules for writing prompts for AI image and video generators (Firefly, Nano Banana Pro, Veo and similar) so the result looks like real photography and any real product in it stays exact. Covers composition zones, the fixed product block, naming generic devices, people, light and lens, the ban list, reference images, logos, the closing line for placeholder prompts, presenter video prompts and fix prompts. Style always comes from the client's config. Use it before writing any image or video generation prompt, for an ad hero, a social post photo, a placeholder prompt for someone else to run, or a first-frame presenter clip.
---

# AI image prompting

A generator only knows what the prompt and the reference images tell it. Vague words get filled in with whatever is most common: a famous brand's product, the wrong proportions instead of the real shape, a face where the headline should go. This skill holds the prompt rules that were proven on real ad work, and the failures that taught them. The result is a prompt (or a set of labelled prompts) ready to run, and a plan for judging what comes back.

## Config
This skill needs:
- `product-spec.md` for a product hero (keys: dimensions, silhouette ratio, corner radius, finish and colour, logo, buttons and ports and lights with their default state, cables and which end is which, the fail list, shape words that are wrong, the prompt product block)
- `references.yaml` (keys: `reference_pack`, `banned_assets`)
- `brand.yaml` (keys: `brand.name`, `brand.audience`, `brand.image_style.style_block`, `brand.image_style.people`, `brand.image_style.closing_line`, `brand.image_style.reference_background`, `brand.logo.full`, `docs.playbook`)

Look in this order: see `core/client-config`. A product hero with no `product-spec.md`: stop and ask for it; never describe a real product from memory or from a photo alone. A scene photo with no product needs `brand.name`. Defaults (the author's; a client's config can override): people candid and mid-moment with natural skin (`brand.image_style.people`), references flattened onto light grey `#EDEDED` (`brand.image_style.reference_background`), the product at least 10% of the frame, at least 6 to 8 candidates per hero. No default for the client's own style: if `brand.audience`, `brand.image_style.style_block` or `brand.image_style.closing_line` is needed and empty, ask; never fill it from another client.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` to read the keys above
- `core/house-report` for the report
- `core/product-accuracy-check` to judge every candidate with a real product in it
- `core/firefly-web-driver` for the mechanics of running prompts in Firefly

## Inputs
- The job: a **product hero** (a real product must look exact), a **scene photo** (an image in the client's style, no exact product), or a **presenter video** (a short clip from a first frame).
- The layout the image goes into, with its text zones.
- For ads: the `## BRIEF` block (`core/brief-contract`). Angle and Hypothesis set the scene. Language sets nothing in the image, because the image has no text.

## Steps
1. **Plan the composition first.** Pick the layout before writing a word of the prompt. Name, in the prompt, every zone the layout needs: where the headline sits (as an empty area of the scene), where a callout goes, where the product sits, where any person's head is. A composition cannot be fixed by cropping later; crops cut heads.
2. **Build the prompt in this order:** product block → "No text." → scene → people → light and lens. Templates are in `references/prompt-templates.md`.
3. **Product block (product hero only).**
   1. Write it once per product from `product-spec.md`, then keep it word for word in every prompt. Store it in `product-spec.md` with a version and a date. Change it only when a test shows a wording failed, and log why.
   2. Start with "Use the attached images as the exact <product>; copy its shape exactly."
   3. Give measured facts: size in mm, the exact ratio ("exactly <N> times longer than wide"), the shape seen from above, the faces and edges, the finish and colour.
   4. Say what it is not, using the spec's fail list ("not a <wrong shape>, not a <wrong shape>"). Never use a loose shape word that fits a different object.
   5. Place the logo by size and position, and call it "a simple mark". Never describe what the logo shows; a description produces a detailed, oversized logo.
   6. Ask for the default state of anything fragile, when that state is real: "status light off".
   7. If the product connects to things, spell the whole chain out, end by end: what plugs into which end, and where each cable goes ("its cable plugs into the device's port and into the product; a round white charger cable leaves the product's other end out of frame").
   8. Close the block with "Real cables only: true thickness, plugs fully seated, natural slack." when cables appear.
4. **Scene.**
   1. Make the product large (by default at least 10% of the frame), sharp, and lying the way the spec says (for example flat, logo up).
   2. By default put the devices in the sharp foreground and the person behind, softly out of focus. This makes the product large almost every time and keeps faces natural. A client's layout can override it.
   3. **Name every other device generically**, with material, colour and shape: "a matte grey rounded case", "a plain white remote with grey buttons". An unnamed device comes out as a famous brand's look-alike.
   4. Make the scene specific to the topic (the exact industry, task and equipment), never a generic stock scene.
5. **People.** Who appears (ages, region) comes from `brand.audience`; ask if it is empty. How they appear is by default (a client's `brand.image_style.people` can override): candid or editorial wording, mid-moment (laughing, absorbed, looking off-camera), "natural skin", never posing at the camera with the product. Describe an action, not a look. Never frame a person as a customer giving a testimonial.
6. **Light and lens.** One light source and one lens, named: "warm lamp light", "soft morning window light", "50mm f/2.2".
7. **Ban list.** Never write: 8K, hyper-realistic, ultra-detailed, flawless, pores, skin texture. Never ask for text in the image ("No text." is always in the prompt). Never ask for a light or display to be on unless that is the point of the image.
8. **Reference images.**
   1. Use tight crops of real photos, from every side: front, side, back with any button, the cable or accessory, the product in use or connected, and one for scale. Whole lifestyle photos as references produce the wrong shape.
   2. Never use a reference that shows a wrong state (a lit light, an old claim, a prototype) or anything in `banned_assets`.
   3. Never add a photo of a person unless that person should appear.
   4. Flatten transparent references onto light grey (`#EDEDED` by default; `brand.image_style.reference_background` can override), as JPEG, at most 2400 px on the long side.
   5. References must be at a public URL the generator's page can fetch. Never pass image bytes or base64 through your own messages; they arrive corrupted.
9. **Logos in scene photos.** Supply the real logo as a reference image and instruct: "Naturally integrate the provided <brand.name> logo reference image into the scene, on <a uniform, a case, a vehicle>, rendered accurately and consistently with the reference image, not redrawn or restyled." Never describe the logo's colours or shape. Leave this out of a studio shot with no surface to put it on.
10. **Scene photos for someone else to generate** (for example, a placeholder in a social post): one prompt per photo slot, labelled ("AI image prompt, main background photo:"). Open with `brand.image_style.style_block` and close with `brand.image_style.closing_line`; whatever the client's style, the closing line keeps "No other text, no additional logos, no watermarks." Never mention aspect ratio, dimensions or orientation; the person running it sets those in the tool. Name the open space the layout needs.
11. **Presenter video.** Keep the prompt plain; template in `references/prompt-templates.md`. Start from a first frame that already looks natural. Never re-edit a face with an AI image model; it makes skin over-detailed and fake. Fix small product details in the first frame by patching pixels, not by regenerating. One clip per language and per voice: separate generations give the same person a different voice.
12. **Check the length** against the tool's limit before running (table below).
13. **Generate many, reject most.** Make at least 6 to 8 candidates per hero by default, and expect most to fail. Any doubt is a no; "close enough" never ships. Collect every result as soon as it appears, and judge candidates at full size, not in a small browser preview.
14. **Fix prompts.** When one candidate is right except for one thing, use the fix prompts in `references/prompt-templates.md` with the same references. When the product itself is wrong and a render of the real product exists, a paste-back of the render beats a fix prompt.
15. **Log.** In `docs.playbook`, record the prompt version, the references used, and every candidate's verdict with its reason.

## Tool limits (checked October 2026)
| Tool | Limit | What happens past it |
|---|---|---|
| Firefly image prompt | 1,000 characters | fails with a generic "Something went wrong" |
| Firefly video prompt | 512 characters | not tested; stay under it |
| Nano Banana Pro in Firefly | up to 6 reference images | not tested; the panel shows "Images (n/6)" |

Partner models in Firefly redraw the product; they never copy its pixels. Every candidate with a real product in it goes through the product check.

## Output
The prompt or labelled prompts, the reference list with a role per image, and the number of candidates to make. After a run: the candidates with a verdict each, reported in the house format (candidates made, candidates passed, prompt version).

## Known failures
- **The product came out too long and thin and the owner rejected it, though every feature was right.** Cause: a loose shape word that fits a different object and a check of features instead of proportions. Fix: measured shape words with the ratio and a "not a ..." list (step 3); measure the ratio in every candidate.
- **The product came out as the wrong shape with the logo in a badge.** Cause: whole lifestyle images and a render with a lit light as references. Fix: tight crops from every side, never a wrong-state reference (step 8).
- **Loose plug ends and cables running nowhere.** Cause: "its cable goes into the product" instead of the full chain. Fix: spell out every connection end by end (step 3.7). This cut loose plugs from most results to about a third.
- **The two ends of the product were swapped.** Cause: the prompt did not say which end connects to what. Fix: name the end for each connection, and check it in every candidate.
- **A face filled the headline zone.** Cause: no reserved zone. Fix: name the zone and the head height (step 1).
- **The product was small in the frame.** Fix: devices sharp in front, person blurred behind (step 4.2).
- **Other devices looked like famous brands; one printed a real brand's logo.** Cause: unnamed devices, coloured face buttons on a controller. Fix: generic names with material and colour (step 4.3). Reject any visible third-party logo.
- **The logo became a detailed, oversized face.** Cause: describing what the logo shows. Fix: size, position, "a simple mark" (step 3.5).
- **A glowing light appeared beside the logo.** Fix: "status light off" (step 3.6), and no lit references.
- **Plastic, over-detailed skin.** Cause: detail words, or re-editing a face with an image model. Fix: the ban list (step 7) and step 11.
- **A surface finish was wrong for weeks.** Cause: the written spec described a different finish and listed the real one as a failure. Fix: check every product word against the real product (CAD or calipers), not against older notes.
- **A multi-view reference sheet made the model draw several products.** Fix: test single views against a sheet, and log which works.
- **The prompt failed with "Something went wrong".** Cause: over the 1,000-character limit. Fix: step 12.

## References
- `references/prompt-templates.md`: the product block template, scene lines, a worked hero prompt, the scene-photo family, the presenter video template and the fix prompts.
