# Prompt templates

Fill the `<...>` parts from the client's config. Words in plain text are proven wording; keep them.

## 1. Product hero

### Product block (write once per product, then keep it word for word)
Store the finished block in `product-spec.md` under "Prompt product block", with a version, the date and its character count. On a 1,000-character tool, aim for about 650 characters, which leaves about 350 for the scene.

> Use the attached images as the exact <product> and its <accessory>; copy its shape exactly. <Product>: <finish> <colour> <form>, <L> x <W> x <H> mm, exactly <ratio> times longer than wide, <shape from above> (not a <wrong shape 1>, not a <wrong shape 2>); <top face and edges>; small <finish> <logo subject> mark near <position>, a simple mark; <buttons, with position>; <ports, with position>; status light off. Its own <accessory>: <type, width in mm, finish, plug type>. Real cables only: true thickness, plugs fully seated, natural slack. No text.

Rules for filling it:
- Every number and shape word comes from `product-spec.md`. Nothing from memory or from a single photo.
- The "not a ..." words come from the spec's fail list and its "shape words that are wrong".
- Leave out lines that do not apply (no cable, no light). Keep "No text." always.

### Scene block (swap per layout)
Order: the setting and light, then the sharp foreground with the product and the full chain, then the person behind, then the reserved zones, then the lens.

> Candid photo, <time of day>: <setting>, <light source>. Sharp foreground: <generic device, with material and colour> <lying how>; <product>'s <accessory> connects to the <device>'s <port> and to <product>; <every other connection, end by end>. <Product> flat, large, logo up. Behind, blurred, <person: age, doing what>. <Zone: e.g. top third an empty soft pale wall>. <lens, e.g. 50mm f/2>, natural skin.

### Scene lines to start from
- **Kitchen, morning:** "a bright kitchen table in soft morning window light; sharp foreground on light oak: a matte grey phone lying face down ...; behind, blurred, a woman in her late 30s laughing; the top third an empty, softly out-of-focus pale wall."
- **Nightstand, evening:** "a walnut nightstand by a bed, warm lamp light; sharp foreground: a black e-reader lying flat ...; behind, blurred, a man in his 40s smiling at a book."
- **Sofa, afternoon:** "a sofa in afternoon light; on the coffee table in front, a plain white tablet in a grey case ...; behind, blurred, two friends in their 20s laughing."
- **Fingertip hero:** "Close-up: a hand holds <product> between thumb and index finger against a plain warm-white wall, soft window light from the left; <product> fills a third of the frame, logo toward camera, <any cable or strap> hanging naturally; the upper-left third is empty wall."

### Worked example (a made-up product, for the shape only)
> Use the attached images as the exact sensor and its cable; copy its shape exactly. Sensor: matte white soft-touch square, 40 x 40 x 14 mm, a rounded square from above with 8 mm corners (not a disc, not a puck, not a cube); flat top with a shallow chamfer on every edge; small grey wave mark near one corner, a simple mark; one USB-C port centred in one side; status light off. Its own cable: round white braided, 3 mm, white USB-C plugs. Real cables only: true thickness, plugs fully seated, natural slack. No text. Candid photo, morning: a hallway shelf, soft window light from the left. Sharp foreground: the sensor flat on pale oak, logo up; its cable runs from the sensor's port to a white wall charger out of frame. Behind, blurred, a man in his 50s putting on a coat, smiling. Top third an empty soft pale wall. 50mm f/2, natural skin.

## 2. Scene photo for someone else to generate (no exact product)

### Style block, every time
> Photorealistic, professional editorial stock-photography style, natural realistic lighting, sharp focus.

### Environment or action photo
> Photorealistic editorial photograph of <who, in what work clothes or safety gear> <doing the exact task> <with the exact equipment> in <the exact place>, <what is visibly happening>, realistic <place> lighting, sharp focus, clear open space in the <part of frame the layout needs> for text. Naturally integrate the provided <brand.name> logo reference image into the scene, on <the uniform, a case, the vehicle or the equipment>, rendered accurately and consistently with the reference image, not redrawn or restyled. No other text, no additional logos, no watermarks, photorealistic, not illustrated.

Example:
> AI image prompt, main background photo: Photorealistic editorial photograph of a technician in a dark work shirt servicing the brew group of a commercial espresso machine in a busy café kitchen, steam rising from the group head, realistic warm café lighting, sharp focus, clear open space in the upper third of the frame for text. Naturally integrate the provided <brand.name> logo reference image into the scene, on the technician's shirt and the toolbox, rendered accurately and consistently with the reference image, not redrawn or restyled. No other text, no additional logos, no watermarks, photorealistic, not illustrated.

### Studio or product-only photo
> Photorealistic product photograph of <the exact product> on a clean seamless white or light-grey studio background, professional product-photography lighting, soft even light with a subtle shadow, centred, no people, no background clutter. No other text, no additional logos, no watermarks, photorealistic, not illustrated.

Rules:
- One prompt per photo slot, each labelled with its slot.
- Never mention aspect ratio, dimensions or orientation.
- The closing line is exact. It does not forbid the supplied logo reference; it forbids invented logos, stray text and watermarks.

## 3. Presenter video (first frame plus a short clip)

> Natural phone front-camera selfie video, handheld, slight natural shake, soft overcast daylight from the window. Same <man or woman> as the first frame, face unchanged. <He or she> holds the small device still for two seconds, then lowers <his or her> hand out of frame. <He or she> talks to camera in <language>, relaxed and natural: "<line, at most about 19 words for 8 seconds>" No text, no music.

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
- [ ] People: age, mid-moment, behind and blurred when the product leads
- [ ] One light, one lens
- [ ] Nothing from the ban list; "No text." present
- [ ] References: tight crops, every side, none banned, none in a wrong state
- [ ] Under the tool's character limit
