// Firefly in-page helpers. Paste the whole file into "run JavaScript in the browser page"
// after EVERY navigation: a page load wipes them.
// Last verified against firefly.adobe.com: 2026-10-15 (image), 2026-10-13 (video, Speech).
// Adobe changes the UI. Run __checkSelectors() first; anything "missing" means re-discover it with path().

// ---- finding things (Firefly's UI lives inside shadow DOM) ----
function deep(root, sel, out = []) {
  root.querySelectorAll('*').forEach(e => { if (e.matches(sel)) out.push(e); if (e.shadowRoot) deep(e.shadowRoot, sel, out); });
  return out;
}
// The chain of tags (with data-testid and class) from an element up through shadow hosts.
// Used to tell apart inputs that share a selector, e.g. the reference grid's file input.
function path(e) {
  const p = []; let n = e;
  while (n) {
    const id = n.getAttribute && n.getAttribute('data-testid');
    const cls = n.className && typeof n.className === 'string' ? n.className : '';
    p.push((n.tagName || '') + (id ? '#' + id : '') + (cls ? '.' + cls : ''));
    n = n.parentNode || n.host;
  }
  return p.join('<');
}
window.deep = deep; window.path = path;
const wait = ms => new Promise(r => setTimeout(r, ms)); window.wait = wait;

window.__waitFor = async (sel, ms = 30000) => {
  const t = Date.now();
  while (Date.now() - t < ms) { const e = deep(document, sel)[0]; if (e) return e; await wait(500); }
  throw new Error('timeout ' + sel);
};

// ---- step 1 of every run: do the selectors still match? ----
window.__SELECTORS = {
  image: {
    modelPicker: 'sp-picker[data-testid="firefly-picker-model"]',
    sizePicker: 'sp-picker[data-testid="firefly-picker-size"]',
    generate: '[data-testid=generate-image-generate-button]',
    cost: '[data-testid=generation-cost-indicator-v2-button]',
    refRemove: '[data-testid=uploaded-image-remove-button]',   // only present when a reference is loaded
  },
  video: { prompt: 'textarea' },
  speech: { language: 'sp-picker[label="Select a language"]', text: '[contenteditable]' },
};
window.__checkSelectors = (page = 'image') => {
  const out = {};
  for (const [k, s] of Object.entries(window.__SELECTORS[page])) out[k] = deep(document, s).length ? 'ok' : 'missing';
  if (page === 'image') {
    out.refInput = deep(document, 'input[type=file]').some(e => path(e).includes('FIREFLY-REFERENCE-IMAGES-GRID')) ? 'ok' : 'missing';
    out.promptField = deep(document, '[contenteditable]').some(e => path(e).includes('FIREFLY-MENTION-TEXT-FIELD')) ? 'ok' : 'missing';
  }
  if (page === 'video') out.firstFrameInput = deep(document, 'input[type=file]').some(e => path(e).includes('keyframes')) ? 'ok' : 'missing';
  return out;
};

// Every picker on the page with what it currently shows. Use it to confirm the model has not drifted.
window.__pickers = () => deep(document, 'sp-picker').map(p => ({
  testid: p.getAttribute('data-testid'), label: p.getAttribute('label'), value: p.value, text: (p.textContent || '').trim().slice(0, 60),
}));

// ---- settings ----
window.__pick = async (picker, item) => {
  deep(document, `sp-picker[data-testid="${picker}"]`)[0].click(); await wait(800);
  deep(document, `sp-menu-item[data-testid="${item}"]`).filter(e => e.getBoundingClientRect().width > 0)[0].click(); await wait(800);
};
window.__cost = () => deep(document, window.__SELECTORS.image.cost)[0]?.getAttribute('aria-label');

// ---- reference images (they enter only by in-page fetch of a public URL) ----
// Crop a public image to [x, y, w, h] (fractions of the image) onto the background colour bg. [0,0,1,1] = whole image.
// bg is the client's brand.image_style.reference_background; there is no default.
window.__crop = async (url, [x, y, w, h], bg) => {
  if (!bg) throw new Error('pass the background colour (brand.image_style.reference_background)');
  const im = new Image(); im.crossOrigin = 'anonymous'; im.src = url; await im.decode();
  const W = im.naturalWidth, H = im.naturalHeight, c = document.createElement('canvas');
  c.width = Math.round(w * W); c.height = Math.round(h * H);
  const g = c.getContext('2d'); g.fillStyle = bg; g.fillRect(0, 0, c.width, c.height);
  g.drawImage(im, x * W, y * H, w * W, h * H, 0, 0, c.width, c.height);
  return new Promise(r => c.toBlob(r, 'image/jpeg', .92));
};
window.__clearRefs = async () => { let b; while ((b = deep(document, window.__SELECTORS.image.refRemove)[0])) { b.click(); await wait(700); } };
// Always the LAST file input under the reference grid: each filled slot has its own input, and the first one replaces slot 1.
window.__addRef = async (blob, name) => {
  const ins = deep(document, 'input[type=file]').filter(e => path(e).includes('FIREFLY-REFERENCE-IMAGES-GRID'));
  const inp = ins[ins.length - 1]; const dt = new DataTransfer();
  dt.items.add(new File([blob], name, { type: blob.type })); inp.files = dt.files;
  inp.dispatchEvent(new Event('change', { bubbles: true, composed: true })); await wait(3500);
};

// ---- image prompt (contenteditable ignores typed keys; insertText works) ----
window.__prompt = t => {
  const ed = deep(document, '[contenteditable]').filter(e => path(e).includes('FIREFLY-MENTION-TEXT-FIELD'))[0];
  ed.focus(); document.execCommand('selectAll'); document.execCommand('insertText', false, t); return ed.innerText.length;
};

// ---- generate and harvest by size ----
// Firefly revokes blob URLs when it re-renders, so each new image is fetched into a Blob at once and kept in __gen.
window.__gen = window.__gen || []; window.__known = window.__known || new Set();
// Run once before the first __genOne, so images already on the page are not counted as new.
window.__seedKnown = async () => {
  for (const i of deep(document, 'img').filter(i => i.src.startsWith('blob:'))) {
    try { window.__known.add((await fetch(i.src).then(r => r.blob())).size); } catch (e) {}
  }
  return window.__known.size;
};
// One generation per call: the browser script call gives up after about 45 s.
// For longer waits start it in the background (window.__bg = __genOne()) and check __gen.length in later calls.
// minWidth: the full-size output width for the chosen ratio and resolution; smaller images (thumbnails) are skipped.
window.__genOne = async (minWidth, minBytes = 0, ms = 100000) => {
  if (!minWidth) throw new Error('pass the expected output width in px');
  deep(document, window.__SELECTORS.image.generate)[0].click(); const t0 = Date.now();
  while (Date.now() - t0 < ms) {
    await wait(4000);
    for (const i of deep(document, 'img').filter(i => i.src.startsWith('blob:') && i.naturalWidth >= minWidth)) {
      try {
        const b = await fetch(i.src).then(r => r.blob());
        if (!window.__known.has(b.size) && b.size > minBytes) { window.__known.add(b.size); window.__gen.push(b); return { i: window.__gen.length - 1, size: b.size }; }
      } catch (e) {}
    }
  }
  return 'timeout';
};

// ---- downloads (they land in the user's Downloads folder; rename by size afterwards) ----
// Call about 2.5 s apart. Note each Blob's size: __gen[i].size.
window.__dl = (i, name) => {
  const a = document.createElement('a'); a.href = URL.createObjectURL(window.__gen[i]); a.download = name;
  document.body.appendChild(a); a.click(); setTimeout(() => a.remove(), 2000);
};
// For a generated video or Speech audio: fetch the player's blob and download it.
window.__dlMedia = async (sel, name) => {
  const m = deep(document, sel)[0]; const b = await fetch(m.currentSrc || m.src).then(r => r.blob());
  const a = document.createElement('a'); a.href = URL.createObjectURL(b); a.download = name;
  document.body.appendChild(a); a.click(); setTimeout(() => a.remove(), 2000); return b.size;
};

// ---- video: first frame and prompt ----
// The first frame goes in from a data URL kept in sessionStorage under `key`.
window.__setFrame = async (key, name) => {
  const inp = deep(document, 'input[type=file]').filter(e => path(e).includes('keyframes'))[0];
  const b = await fetch(sessionStorage.getItem(key)).then(r => r.blob()); const dt = new DataTransfer();
  dt.items.add(new File([b], name, { type: b.type })); inp.files = dt.files;
  inp.dispatchEvent(new Event('change', { bubbles: true, composed: true }));
};
// Compare an image element (e.g. the frame panel's thumbnail) with the stored frame on a 40×70 canvas. About 0 = same image.
window.__frameDiff = async (imgEl, key) => {
  const load = src => new Promise((res, rej) => { const im = new Image(); im.onload = () => res(im); im.onerror = rej; im.src = src; });
  const px = im => { const c = document.createElement('canvas'); c.width = 40; c.height = 70; const g = c.getContext('2d'); g.drawImage(im, 0, 0, 40, 70); return g.getImageData(0, 0, 40, 70).data; };
  const a = px(imgEl), b = px(await load(sessionStorage.getItem(key))); let s = 0;
  for (let i = 0; i < a.length; i += 4) s += Math.abs(a[i] - b[i]) + Math.abs(a[i + 1] - b[i + 1]) + Math.abs(a[i + 2] - b[i + 2]);
  return s / (40 * 70 * 3);
};
// Video prompt: a plain textarea that only takes a value through the native setter (512 characters at most).
window.__setPrompt = p => {
  const ta = deep(document, window.__SELECTORS.video.prompt)[0];
  Object.getOwnPropertyDescriptor(HTMLTextAreaElement.prototype, 'value').set.call(ta, p);
  ta.dispatchEvent(new Event('input', { bubbles: true, composed: true })); return p.length;
};

// ---- Firefly Speech ----
window.__speechText = t => { const el = deep(document, window.__SELECTORS.speech.text)[0]; el.focus(); document.execCommand('selectAll'); document.execCommand('insertText', false, t); return el.innerText.length; };
window.__speechLang = async code => { // e.g. 'en-US', 'fr-FR'
  deep(document, window.__SELECTORS.speech.language)[0].click(); await wait(800);
  deep(document, `sp-menu-item[value="${code}"]`).filter(e => e.getBoundingClientRect().width > 0)[0].click(); await wait(800);
};

'firefly helpers loaded';
