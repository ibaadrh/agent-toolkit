# core

Shared building blocks. Every other toolkit assumes `core` is installed.

Nothing here is about one domain. If a mechanic is needed by two skills, it lives here once.

## Skills (to be built from the private inboxes, see docs/SYSTEM.md section 5)

| Skill | What it holds | Pulled from |
|---|---|---|
| `client-config` | How every skill finds `brand.yaml`, `ads.yaml` and friends (project `.claude/toolkit/`, the AGENTS.md or CLAUDE.md pointer, or Claude app Project docs), what counts as missing, how to stop and ask, and how to write a config file safely. | built (from the strategist, campaigns, Canva builder, invoice and video-studio raw skills) |
| `platform-adapters` | The only place tool names live. Skills name actions ("run JavaScript in the browser page", "deliver the file to the user"); one table per agent platform maps each action to that platform's tool. Claude is filled in; Codex, Cursor and Gemini CLI are templates. | built |
| `house-report` | The report format: one sentence, 2–3 metrics, what changed, numbered points for the owner or "Nothing needed from your side." Plus check-before-claim and the three-strikes rule (flagged twice → third time fix it). | built (from the ads-loop skills, video-studio, the invoice skill) |
| `brief-contract` | The `## BRIEF` block: decision, hypothesis, format, language, angle, headline, subhead, primary text, destination, utm_content, tested against, success metric, budget, decision date. The checks a brief must pass, field → usage per maker, and what each maker hands back. | built (from paid-ads-strategist, both makers, meta-campaigns) |
| `ai-image-prompting` | Reserve text zones in the prompt. A fixed product block with measured shape words. Spell out every connection. Name generic devices or they come out as brand look-alikes. One named light source, one named lens. Ban list: 8K, hyper-realistic, ultra-detailed, flawless, pores, any text. References: tight crops from every side. Logo via reference image, never described. Never state aspect ratio when the tool sets it. Presenter video and fix prompts. Style, people and composition always from the client's config (`brand.image_style`). | built (from the ad makers and their playbooks, the Canva builder) |
| `firefly-web-driver` | Driving firefly.adobe.com from a browser the agent controls: a selector check before every run, 1440×900 viewport emulation, the shadow-DOM helper set in `scripts/firefly-helpers.js` (wait-for, picker select, prompt insert, reference upload via DataTransfer to the last input, generate-and-harvest by size before blob URLs are revoked, download and rename-by-size), the 45 s script limit and background runs, the model drift check, video first frames and Firefly Speech. Last verified 2026-10-15. | built (from the static and video makers, both playbooks) |
| `product-accuracy-check` | The gate for any image or render with a real product: measured silhouette with foreshortening correction, a feature checklist from `product-spec.md`, which end is which, cable and connector physics, the brand look-alike gate, honest retouches only, the fallback ladder (paste-back, regenerate, edit, real photo) and method choice (paste-back, plate-first, references only), the verdict log. Renders get checked too. | built (from static-ad-maker §4, playbook §10 and §13) |
| `ffmpeg-vertical-toolkit` | 9:16 crop and blur-background framing (with `setsar=1`), frame-accurate trims joined by concat re-encode, never the last 0.25 s of AI clips, the loudnorm chain, ASS captions in Reels and Stories safe zones, contact sheets and strips, review re-encode, segment and join. Recipes tested 2026-10-16 in `references/recipes.md`; frame-spike, RMS-envelope and voice-pitch scripts. | built (from the video maker, the reel editor, the UGC workflow doc) |
| `file-delivery` | Delivering finished files to the user and onto their machine or cloud folder: naming and versions, the per-file size cap and split/join for large files, never delete (move to scratch), list the folder to prove each file landed, recover a partial write by re-writing only what is missing, check Drive links by title. Reference: .docx edits, the row-height fix, `soffice` export and `pdftoppm` check. | built (from the invoice, reel, video and static makers, video-studio) |
| `meta-creative-publish` | RGB PNG check (error_subcode 2446496), upload by public URL → image hash, creatives are immutable, create paused → preview → activate with explicit object IDs → verify `effective_status`, AI self-disclosure (OPT_IN), the Instagram `stream` placement gotcha. | built (from static-ad-maker, meta-campaigns-operator, the video maker) |
| `shopify-cdn-publish` | Host a file at a public URL when the agent can't reach the web directly: the four-step staged upload (`stagedUploadsCreate` → multipart POST → `fileCreate` → poll READY), why it is needed (Meta needs a public URL; the sandbox can't reach the CDN; the browser can't read disk; Drive links are CORS-blocked), and the owner's approval for public uploads. | built (from static-ad-maker and its playbook) |
| `readable-test-doctrine` | Readability gates (impressions per cell, leader link clicks) before judging, set per client in `ads.yaml` with no defaults. One ABO ad set per cell with equal budgets, never a split test inside CBO. Verify the spend share stayed inside the client's band. Decide on the earliest funnel metric; purchases only confirm. Rule of three for zero conversions. Culling past the gate. The don't-fool-yourself list. | built (from paid-ads-strategist, meta-campaigns-operator) |
| `claims-and-voice-rules` | The truthfulness rules (never invent, approved claims only, no fake testimonials, AI presenters never customers, exact award wording), what goes in `voice.yaml` including the client's own style rules, and the pre-ship check with `scripts/check_copy.py`. | built (from the ads-loop claim rules, the social copywriter, a personal email-voice skill's structure) |
| `browser-automation-hygiene` | Wake a page in a hidden pane with one screenshot, retake stale screenshots, never trigger a native dialog (move files in by in-page fetch of a public URL). | built (from the Firefly gotchas) |
| `llm-council` | Five-lens decision pressure test with anonymous peer review and a chairman verdict. Ported as-is; the stale HTML-output note is removed, the transcript folder is `docs.council_transcripts`, and there is a fallback for agents without sub-agents. | built (from llm-council) |
| `shell-safety-guard` | Stops shell commands that zsh would break or silently change (words starting with `=`, unquoted globs in flags, after `=`, as pattern-flag arguments, in URLs and remote paths, bracket classes), with the fix. Portable script `scripts/zsh-guard.py` plus a Claude Code hook in `hooks/`. 30 tests checked against real zsh. | built (written from scratch) |
| `resume-session` | Start a session from the notes file and the repo: where things stand, what is open, one next step; then wait. Optional `/resume-session` command. | built (written from scratch) |
| `wrap-up-session` | End a session with one checked entry in the notes file: done (with commit hashes), open, next step. Optional `/wrap-up-session` command. | built (written from scratch) |
| `park-a-note` | Append one dated line to the notes file and go back to work. Optional `/park-a-note` command. Notes file: `docs.session_notes`, else `SESSION-NOTES.md`. | built (written from scratch) |

## References

| Reference | What it holds |
|---|---|
| [`references/working-with-agents.md`](references/working-with-agents.md) | For the person: brief like a peer, one task per session, plan before big changes, the agent stops before irreversible actions, verify before "done", keep learnings in the repo, how to review agent output. Plus rules a project's AGENTS.md can copy. Linked from AGENTS.md. |

## Install alongside

| Tool | Why | Install | Licence | In use |
|---|---|---|---|---|
| [brightdata-plugin](https://github.com/brightdata/skills) | Web data for any toolkit: scrape pages, search, structured data from big platforms, competitor intel, brand listening, SEO audits. Its CLI and MCP need a Bright Data API key. | `claude plugin install brightdata-plugin@ibaad-toolkit` | MIT | yes |

Full list, versions and pins: [docs/THIRD-PARTY.md](../../docs/THIRD-PARTY.md).

## Install
```
/plugin install core --marketplace ibaadrh/agent-toolkit
```
