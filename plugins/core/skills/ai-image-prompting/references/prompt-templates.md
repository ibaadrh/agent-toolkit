# Prompt templates

Fill the `<...>` parts from the client's config and the brief. Words in plain text are proven wording; keep them. The people, composition, light and lens wording here is the author's default; a client's `brand.image_style` or layout can override it. The client's own style block, closing line and audience come only from their config; with an empty key, ask.

## 1. Product hero

### Product block (write once per product, then keep it word for word)
Store the finished block in `product-spec.md` under "Prompt product block", with a version, the date and its character count. Leave enough of the tool's character limit for the scene.

> Use the attached images as the exact <product> and its <accessory>; copy its shape exactly. <Product>: <finish> <colour> <form>, <L> x <W> x <H> mm, exactly <ratio> times longer than wide, <shape from above> (not a <wrong shape 1>, not a <wrong shape 2>); <top face and edges>; small <finish> <logo subject> mark near <position>, a simple mark; <buttons, with position>; <ports, with position>; status light off. Its own <accessory>: <type, width in mm, finish, plug type>. Real cables only: true thickness, plugs fully seated, natural slack. No text.

Rules for filling it:
- Every number and shape word comes from `product-spec.md`. Nothing from memory or from a single photo.
- The "not a ..." words come from the spec's fail list and its "shape words that are wrong".
- Leave out lines that do not apply (no cable, no light). Keep "No text." always.

### Scene block (swap per layout)
Default order (a client's layout can change it): the setting and light, then the sharp foreground with the product and the full chain, then the person behind, then the reserved zones, then the lens.

> <brand.image_style.style_block>, <time of day>: <setting>, <light source>. Sharp foreground: <generic device, with material and colour> <lying how>; <product>'s <accessory> connects to the <device>'s <port> and to <product>; <every other connection, end by end>. <Product> <how it lies, per the spec>. Behind, blurred, <person from brand.audience, candid and mid-moment, doing what>. <Zone the layout needs>. <lens>, natural skin.

### Worked example (a made-up product, product block only)
> Use the attached images as the exact sensor and its cable; copy its shape exactly. Sensor: matte white soft-touch square, 40 x 40 x 14 mm, a rounded square from above with 8 mm corners (not a disc, not a puck, not a cube); flat top with a shallow chamfer on every edge; small grey wave mark near one corner, a simple mark; one USB-C port centred in one side; status light off. Its own cable: round white braided, 3 mm, white USB-C plugs. Real cables only: true thickness, plugs fully seated, natural slack. No text.

## 2. Scene photo for someone else to generate (no exact product)

> <brand.image_style.style_block> photograph of <who, in what work clothes or safety gear> <doing the exact task> <with the exact equipment> in <the exact place>, <what is visibly happening>, <light that fits the place>, clear open space in the <part of frame the layout needs> for text. Naturally integrate the provided <brand.name> logo reference image into the scene, on <the uniform, a case, the vehicle or the equipment>, rendered accurately and consistently with the reference image, not redrawn or restyled. No other text, no additional logos, no watermarks<, brand.image_style.closing_line>.

Product-only photo:
> <brand.image_style.style_block> product photograph of <the exact product> on <the background the client's style asks for>, no background clutter. No other text, no additional logos, no watermarks<, brand.image_style.closing_line>.

Rules:
- One prompt per photo slot, each labelled with its slot.
- Never mention aspect ratio, dimensions or orientation.
- "No other text, no additional logos, no watermarks" is always in the closing line. It does not forbid the supplied logo reference; it forbids invented logos, stray text and watermarks.
- Make the scene specific to the client's topic (the exact industry, task and equipment), never a generic stock scene.

## 3. Presenter video (first frame plus a short clip)

> <camera and framing from the client's video config or the brief>. Same <person> as the first frame, face unchanged. <What they do with the product, from the brief>. <They> talk to camera in <language>, relaxed and natural: "<line, by default at most about 19 words for 8 seconds>" No text<, and no music if the edit adds its own>.

Rules:
- Keep it plain. No "pores", "skin texture" or "ultra detailed".
- Re-check the model name in the tool before generating. Menus overlap and a stray click can switch the model.
- One clip per language. Never cut two clips of the same presenter together; the voices differ.
- The presenter speaks as a presenter, never as a customer ("I bought this").

## 4. Fix prompts (edit the image, same references)

**Product fix:**
> Keep everything exactly the same: person, pose, lighting, background, framing. Replace only the <product> and its <accessory> with the exact <product> and <accessory> from the reference images: <the measured shape in one line>, <logo, one line>, <finish>, plugs fully seated.

**Realism fix:**
> Keep composition, product and lighting unchanged. Make the skin natural and unretouched, let the smile reach the eyes, slightly lower saturation.

Fix prompts redraw the product again. When a render of the real product exists, pasting the render back over the generated product is more reliable.

## 5. Checklist before running
- [ ] Layout chosen and every zone named in the prompt
- [ ] Product block is the stored version, unchanged
- [ ] Every connection spelled out, end by end
- [ ] Every other device named generically, with material and colour
- [ ] Style block and audience from the client's config; people candid, mid-moment, natural skin, behind and blurred when the product leads (defaults)
- [ ] One light, one lens
- [ ] Nothing from the ban list; "No text." present
- [ ] References: tight crops, every side, none banned, none in a wrong state
- [ ] Under the tool's character limit
