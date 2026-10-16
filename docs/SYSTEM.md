# The system

How all your skills and workflows become one portable toolkit that works in Claude Code, the Claude app and other AI agents (Codex, Cursor, Gemini CLI), on any machine, for any client or product. What carries over to other agents, and how, is in `docs/PORTABILITY.md`.

Read this once. After that, `docs/HOW-TO-USE.md` is the one you open day to day.

---

## 1. The problem this solves

Today your skills live in three places and are tangled with the clients they were built for:

| Where | What's there | Problem |
|---|---|---|
| Claude app account skills | 12 skills (a product ads loop, a B2B social pipeline, a reel editor, a video studio router, an invoice sequencer, an email voice, llm-council) | Not in git. Each one has client names, IDs, Drive paths and brand colours hard-coded inside. |
| Claude Code (`~/.claude/skills` + per-repo `.claude/skills`) | Project-level skills, CLAUDE.md files, settings | Spread across repos. Not portable to a new laptop or a new account. |
| Third-party plugins | taste-skill, Wix, Bright Data | Installed by hand. Nothing records which ones you rely on. |

The same mechanics are also written out several times. The Firefly browser helpers appear in two skills. The ffmpeg vertical-video recipes appear in two. The "house report" format appears in five. Drive delivery appears in four. When you learn something new you have to remember to fix it everywhere.

## 2. The three rules of the new system

**Rule 1. Skills are generic. Clients are config.**
A skill never contains a brand name, an account ID, a Drive path or a hex colour. It reads those from a small config file. The same `static-ad-maker` skill makes ads for your own product, for an agency client, or for a product you launch next year. You only write a new `brand.yaml`.

**Rule 2. One place is the source of truth: the git repo.**
Everything installs *from* the repo. Claude Code gets it through the plugin marketplace. The Claude app gets it through a packaged zip made by a script. You never edit a skill inside `~/.claude` or inside the Claude app directly. You edit it in the repo, commit, and re-install.

**Rule 3. Shared mechanics live once, in `core`.**
Anything two skills both need (Firefly driver, ffmpeg recipes, Drive delivery, the report format, the brief contract, the AI image prompting rules) is one skill or one reference file in the `core` plugin. Domain skills point to it. Fix it once, every workflow improves.

## 3. The shape

Two private GitHub repos on your personal account, plus one config repo for each company you do in-house work for, owned by that company's GitHub organisation.

### Repo 1: `agent-toolkit` (this repo). Generic. Could be made public one day.

```
agent-toolkit/
├── README.md                       The front page. The five toolkits, two-command install.
├── AGENTS.md                       Rules any agent follows when editing this repo (no client data, no tool names, decoupling checklist).
├── CLAUDE.md                       One line: "See AGENTS.md."
├── .claude-plugin/marketplace.json Makes the repo a Claude Code marketplace. Lists the six plugins below.
├── plugins/
│   ├── core/                       Shared building blocks every toolkit uses.
│   ├── video-production/           Toolkit 1
│   ├── website-development/        Toolkit 2
│   ├── app-development/            Toolkit 3
│   ├── engineering-3d-printing/    Toolkit 4
│   └── digital-marketing/          Toolkit 5
├── templates/                      Skill template, client-config templates, project AGENTS.md template (plus a CLAUDE.md pointer).
├── scripts/                        install.sh, package-for-claude-ai.sh, harvest-claude-app.sh (+ launchd/), validate.sh, scan-history.sh, hooks/pre-push, new-skill.sh
├── prompts/                        Ready-to-paste Claude Code prompts for migrating and refining.
├── docs/                           This file, HOW-TO-USE, HOW-TO-ADD-A-SKILL, DECOUPLING-CHECKLIST.
└── ../agent-clients/_inbox/                         Raw exports waiting to be refactored. Empty when migration is done.
```

Each plugin folder is its own "project" on GitHub in every way that matters: its own README, its own version, its own WORKFLOW.md, its own list of third-party tools it depends on. People can read one toolkit without knowing the others exist. But they all install from one marketplace with one command, and they all share `core`.

Why one repo and not five? Because `core` must be shared, and because one install command on a new machine beats six. If a toolkit ever deserves to be public on its own, `git subtree split` moves that folder into its own repo in one command without losing history. Start together, split later if needed.

Inside each plugin:

```
plugins/digital-marketing/
├── .claude-plugin/plugin.json      name, version, description
├── README.md                       What this toolkit does, what's inside, how to use it, what to install alongside
├── WORKFLOW.md                     The start-to-finish playbook for this domain (the thinking, in order)
├── skills/
│   ├── paid-ads-strategist/SKILL.md (+ references/, scripts/)
│   ├── static-ad-maker/
│   ├── ugc-video-ad-maker/
│   ├── meta-campaigns-operator/
│   ├── competitor-ad-research/
│   └── ...
├── commands/                       Optional slash commands, e.g. /ads-loop
└── agents/                         Optional sub-agents, e.g. ad-juror
```

### Repo 2: `agent-clients`. Private forever.

```
agent-clients/
├── clients/
│   ├── _template/      copied from templates/client-config/
│   ├── <client-a>/     brand.yaml  content.yaml  voice.yaml  canva.yaml
│   ├── <client-b>/     brand.yaml  reel-style.yaml
│   └── <agency>/       brand.yaml  voice.yaml
├── personal/           Skills that are yours, not toolkit material (an invoice sequencer, for example)
└── studio.yaml         Your video-studio volumes and the clients table
```

### Repo 3, one per company: `<company>-agent-config`. Owned by the company.

Same layout as `agent-clients`, for work you do inside a company rather than for agency clients: that company's products under `clients/`, your work-only skills (an email voice) under `personal/`. It lives in the company's GitHub organisation and is pushed with your company account, so company material never sits in a personal repo.

This split is the decoupling. The toolkit never knows which clients or companies exist. The config repos never contain a workflow.

## 4. How a skill finds its client config

Every generic skill starts with the same block:

```
## Config
This skill needs: brand.yaml, ads.yaml
Look for them in this order:
1. `.claude/toolkit/` in the current project folder (Claude Code).
2. The path named under "Toolkit config" in the project's AGENTS.md (or CLAUDE.md).
3. In the Claude app: Project docs named `toolkit/brand.yaml`, `toolkit/ads.yaml`.
4. If none exist, stop and ask for the missing values, then offer to write the file.
```

So plugging a toolkit into a product is one step: copy the client's folder from `agent-clients` into `<product-repo>/.claude/toolkit/` (or upload the files as docs into the Claude app Project). Done. Every skill in every toolkit now knows the brand, the account IDs and the paths.

Config files are YAML with a fixed schema per file. The schemas live in `templates/client-config/`. A skill reads keys like `brand.colors.primary` or `meta.ad_account_id`. If a key is missing, the skill says which key and stops; it never guesses.

Live documents (a product's "Live State" and "Run Log", a client's "Ideas Log") stay where they are, in the client's Claude Project or Drive. The config file just holds their names or IDs.

## 5. The five toolkits, and what goes in each

The table shows: skills you already have that move in (after decoupling), third-party tools to adopt as-is, and gaps where you write something new because nothing good exists publicly.

### Toolkit 1: video-production

| Yours (decoupled) | Adopt from the community | Write new |
|---|---|---|
| `video-studio-router` (studio layout, two-volume rule, new-client onboarding) | `ahujasid/blender-mcp` (28.7k) | `firefly-web-driver` (your shadow-DOM helpers for firefly.adobe.com, Veo 3.1, Nano Banana Pro, Firefly Speech; nothing public does consumer Firefly) |
| `kdenlive-reel-editor` (from the raw reel-editing skill: edit_plan.json → prep_clips.py → build_kdenlive.py → melt render) | `remotion-dev/skills` (official) | `kdenlive-project-builder` reference + scripts (no public Kdenlive automation exists; yours is the only one) |
| `ugc-video-ad-maker` mechanics (presenter clip, first-frame pixel patch, ffmpeg edit, ASS captions) | `digitalsamba/claude-code-video-toolkit` (ffmpeg, ElevenLabs, Playwright recording) | `blender-reference-render-pack` (STEP → GLB → master.blend → ortho and accessory renders + index.csv) |
| | `ychoi-kr/claude-ffmpeg-skill` (tested recipes) | `ffmpeg-vertical-toolkit` (your 9:16 crop/blur, loudnorm chain, contact sheets, spike scan) |
| | `runwayml/skills` only if you pay for Runway | |

### Toolkit 2: website-development

| Yours | Adopt | Write new |
|---|---|---|
| Your Wix headless and Shopify setup notes (from your projects, collect them) | `Leonxlnx/taste-skill` (you have it; keep as plugin, don't fork) | `wix-headless-launch` (your way of building and optimising on Wix headless) |
| | `pbakaus/impeccable` (deterministic anti-slop detector + hook) | `shopify-storefront-launch` |
| | `JCodesMore/ai-website-cloner-template` (the web cloner) | `site-seo-baseline` (your checklist on top of claude-seo) |
| | `AgriciDaniel/claude-seo` (32 /seo commands, the SEO workhorse) | |
| | `zubair-trabzada/geo-seo-claude` (llms.txt, AI-search citability) | |
| | Official `@shopify/dev-mcp` and `wix-mcp` (both already connected for you) | |
| | `educlopez/ui-craft` (a11y audit agent) | |

Skip `ui-ux-pro-max` unless you want its palette database; it overlaps with taste-skill and impeccable.

### Toolkit 3: app-development

| Yours | Adopt | Write new |
|---|---|---|
| Your Flutter / Play Store notes (collect what you learned from past Android releases) | `SimoneAvogadro/android-reverse-engineering-skill` (jadx APK decompile → APIs, features) | `app-feature-extraction` (screenshots + APK → feature spec; nothing public does the full flow) |
| | `expo/skills` (official; eas-app-stores, eas-workflows) if React Native | `app-release-checklist` (Play Store + App Store, keystores, screenshots, listing) |
| | `android/skills` (official Google) | `mobile-ui-taste` (your app UI rules; taste-skill is for websites, not app screens) |
| | `Eronred/aso-skills` (40 ASO skills: keywords, screenshots, listing A/B) | |
| | `truongduy2611/app-store-preflight-skills` (App Review rejection scan) | |
| | `cleydson/flutter-claude-code` if Flutter (thin, expect to maintain) | |

### Toolkit 4: engineering-3d-printing

| Yours | Adopt | Write new |
|---|---|---|
| Your Blender product-accuracy pipeline (from static-ad-maker: measured spec sheet, silhouette check) | `earthtojake/text-to-cad` (20.8k; CAD, DfAM printability check, OrcaSlicer G-code, send to Bambu) | `functional-first-design` (the thinking skill: define the job, constraints, tolerances, print orientation, "not over-engineered" rules) |
| Your PlatformIO / ESP32 habits (the `.platformio` folder says you have them) | `neka-nat/freecad-mcp` if you need FreeCAD GUI/FEM | `bambulab-print-tutorial` (slice settings, filament, supports, first-layer, the easy-to-follow print guide) |
| | `mixelpixx/KiCAD-MCP-Server` for boards | `embedded-esp32-platformio` (nothing good exists publicly) |
| | `obra/superpowers` brainstorming + `forrestchang/andrej-karpathy-skills` (the anti-over-engineering layer) | |

Avoid `flowful-ai/cad-skill`: non-commercial licence, which matters for a studio.

### Toolkit 5: digital-marketing

| Yours (this is your strongest material) | Adopt | Write new |
|---|---|---|
| `paid-ads-strategist` (decision ladder, readability gates, brief contract) | `coreyhaines31/marketingskills` (50 skills: copywriting, cro, launch, emails, competitor profiling) | `competitor-ad-research` (Meta Ads Library via the Meta MCP you already have, plus the Composio `competitive-ads-extractor` pattern) |
| `meta-campaigns-operator` (ABO-per-cell rule, launch sequence, scale/kill thresholds, diagnosis) | `AgriciDaniel/claude-ads` (Google + Meta ops with gated changes) | `low-budget-launch-plan` (your small-daily-budget doctrine turned into a playbook) |
| `static-ad-maker` (Firefly hero, product check, Claude Design layouts A–D, juror rubric, CDN → Meta hash) | `realkimbarrett/advertising-skills` (direct-response copy system) | `newsletter-system` (Mailchimp MCP is connected; marketingskills `emails` covers the rest; no Beehiiv/Substack MCP exists) |
| `ugc-video-ad-maker` (loop role; mechanics live in video-production) | `googleanalytics/google-analytics-mcp` (official GA4) | `free-tools-stack` (researched list of free tools per job, kept current) |
| `social-content-research`, `b2b-social-copywriter`, `canva-post-builder` (the B2B social pipeline) | `ConechoAI/Nano-Banana-MCP` (cheapest static-ad iteration) | |
| | Meta Ads MCP (already connected) | |

### core (shared by all five)

From the audit, these repeat across your skills and become single modules:

| Module | Used by |
|---|---|
| `house-report` (one sentence, 2–3 metrics, numbered points or "Nothing needed from your side.") | everything |
| `brief-contract` (the `## BRIEF` block schema) | strategist, both ad makers, campaigns |
| `ai-image-prompting` (reserve text zones, name generic devices, one light one lens, the ban list, the closing qualifier) | static ads, Canva, any image gen |
| `firefly-web-driver` | static ads, video ads |
| `product-accuracy-check` | static ads, 3D renders |
| `ffmpeg-vertical-toolkit` | video ads, reels |
| `file-delivery` (outputs → deliver the file to the user → write file to device, 30 MB split, `mv` not `rm`) | everything that produces files |
| `platform-adapters` (action → tool name, one table per agent platform; the only place tool names appear) | every skill |
| `shell-safety-guard` (zsh traps, portable script plus hook) | every skill that runs shell commands |
| `resume-session`, `wrap-up-session`, `park-a-note` (session notes) | every project |
| `meta-creative-publish` + `shopify-cdn-publish` | static ads, video ads, campaigns |
| `readable-test-doctrine` (300 impressions / 25 clicks gates, ABO never CBO, 40/60 check, rule of three) | strategist, campaigns |
| `claims-and-voice-rules` (no em dashes, approved-claims list pattern) | all copy |
| `browser-automation-hygiene` (wake a hidden page, stale screenshots, no native dialogs) | Firefly, cloners |
| `llm-council` | any decision |
| `client-config` (the loader convention from section 4) | every skill |

## 6. How it reaches each place you use Claude

| Surface | How the toolkit gets there | Refresh |
|---|---|---|
| Claude Code, any machine | `claude plugin marketplace add ibaadrh/agent-toolkit` then `claude plugin install <toolkit>@ibaad-toolkit`. `scripts/install.sh` does all six. | `claude plugin update` or `/reload-plugins` |
| A specific product repo | Add the marketplace to that repo's `.claude/settings.json` under `extraKnownMarketplaces` + `enabledPlugins`. Copy the client config into `.claude/toolkit/`. Anyone who opens the repo gets the right toolkit. | git pull |
| Claude app (claude.ai, desktop) | `scripts/package-for-claude-ai.sh` zips each skill. Upload in Settings → Skills. Client configs go into the Project as docs named `toolkit/<file>`. | Re-upload the zip when the skill changes. The script prints which ones changed since last package. |
| Claude Code on the web / cloud sessions | Same as Claude Code. Private repo access is through your GitHub connection. | same |
| Codex, Cursor, Gemini CLI | Symlink the skill folders into `~/.agents/skills/` (all three read it). Plugins, hooks and slash commands do not carry over. Steps: `docs/PORTABILITY.md`. | git pull |
| A new account or a teammate | Give them read access to `agent-toolkit`. They run `install.sh`. They never need `agent-clients` unless they work on that client. | same |

Account skills in the Claude app can't be git-synced today, so the zip step is manual. Keep it honest: the repo is the source; the app is a copy.

## 7. Commits are yours

You asked that contributions come from you, not Claude. Three settings do that:

1. In the repo, `git config user.name "Ibaad Rahman"` and `git config user.email "88559161+ibaadrh@users.noreply.github.com"` (your GitHub noreply address, so no personal or work email is published).
2. In `~/.claude/settings.json`: `"attribution": { "commit": "", "pr": "" }` removes the Co-Authored-By trailer and PR footer. (The old key `includeCoAuthoredBy` is deprecated.)
3. In this repo's `AGENTS.md`: "Never add co-author trailers. Commit messages describe the change, not the tool."

Claude Code is still how you do the work. The history just shows you.

## 8. The migration, in order

Each step is one Claude Code session. The prompts in `prompts/` are written to be pasted as-is.

| Step | What happens | Prompt file |
|---|---|---|
| 0 | Create both private repos on GitHub. Push this scaffold. Run `scripts/install.sh` once so Claude Code sees the (still empty) marketplace. | `prompts/00-setup.md` |
| 1 | Collect everything. Your Claude Code project skills and CLAUDE.md files from every repo (one `find` command, in the prompt). Export the playbook and strategy docs from your Claude Projects, because the real prompt libraries live there, not in the skills. Drop all of it in the private inbox: `../agent-clients/_inbox/`, or the company config repo's `_inbox/` for company material. | `prompts/01-collect.md` |
| 2 | Build `core` first. Pull the 13 shared modules out of the raw skills. Each becomes a skill or a `references/*.md` file in `plugins/core`. | `prompts/02-build-core.md` |
| 3 | Decouple one skill at a time with the checklist. Generic skill into its toolkit, client values into `agent-clients/clients/<name>/`. Start with the ads loop (highest value, most tangled). Then the B2B social pipeline. Then the reel editor and the video studio router. | `prompts/03-decouple-skill.md` |
| 4 | Adopt third-party tools. Add each to `marketplace.json` or the toolkit README with the exact install line. Don't fork; pin. | `prompts/04-adopt-third-party.md` |
| 5 | Write the five `WORKFLOW.md` files: the start-to-finish way of working in each domain, naming which skill does which step. This is the "super clear tutorial" layer. | `prompts/05-write-workflow.md` |
| 6 | Fill the gaps. Write the new skills listed in section 5 (firefly-web-driver, functional-first-design, app-feature-extraction, and so on). One per session. Use skill-creator and test on a real job before merging. | `prompts/06-new-skill.md` |
| 7 | Validate and publish. `scripts/validate.sh`, package for the Claude app, upload, install on your second machine, confirm a skill runs there. | `prompts/07-publish.md` |

Steps 0 to 3 give you a working system. Steps 4 to 7 make it complete. Expect roughly: step 0 one hour, step 1 one evening, step 2 one session per 3–4 modules, step 3 one session per skill.

## 9. Keeping it alive

- **When a skill teaches you something** (a new Firefly gotcha, a better ffmpeg flag), the fix goes in the repo, not in the chat. Say "update the toolkit: ..." in Claude Code inside the repo and commit. `prompts/08-learn.md` is the pattern.
- **When you start a new client**, copy `templates/client-config/` into `agent-clients/clients/<name>/`, fill it, drop it into the product repo. No skill changes.
- **Monthly**, run `prompts/09-review.md`: it checks which third-party plugins have updates, which of your skills haven't been used, and which `_inbox` items are still waiting.
- **Version each plugin** in its `plugin.json`. Bump the patch number on fixes, minor on new skills. Tag the repo when you re-package for the Claude app so you know which version is uploaded.

## 10. What good looks like in six weeks

- A new laptop is productive in five minutes: clone nothing, run two commands.
- You start a new product: one config folder, and every toolkit works for it.
- Your GitHub profile shows one pinned repo with five clear projects inside, each readable by a stranger.
- The client-named skills no longer exist by those names. `static-ad-maker`, `canva-post-builder` and `kdenlive-reel-editor` do, and they run for anyone.
