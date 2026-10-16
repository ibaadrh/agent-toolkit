# Third-party tools

Every third-party skill, plugin and MCP server the toolkits rely on or recommend. Nothing here is copied into this repo. Each one installs from its own upstream, pinned to the commit below.

- **Plugins** are listed in this repo's marketplace (`.claude-plugin/marketplace.json`) with a pinned commit, so `claude plugin install <name>@ibaad-toolkit` works on any machine.
- **Skills without a plugin** install with the `skills` CLI (`npx skills`) into `~/.claude/skills`.
- **Clones and MCP servers** are handled by `scripts/install-third-party.sh`.

The script skips anything already there: a plugin installed from any marketplace, a plugin synced from your Claude app account (taste-skill, wix and brightdata-plugin arrive that way), or a skill already in `~/.claude/skills`.

Install the tools in use with `./scripts/install.sh --with-third-party`, or run `./scripts/install-third-party.sh` on its own. Add `--recommended` for the second table too, and `--dry-run` to see the commands first.

"My changes" says whether you edited the tool. If you ever do, keep the change as a patch or a note in the owning toolkit, and update this column.

## In use

Found on this machine on 2026-10-16.

| Name | Toolkit | What it's for | Install | Version · commit | Licence | My changes |
|---|---|---|---|---|---|---|
| [replica-skill](https://github.com/Jakeschincariol/replica-skill) | app | The app reverse-engineering pack. `replica-recon` maps any app into screens, flows, a data model and a feature matrix; ten more skills cover architecture, design, build, backend, test, parity diff, brand, launch and deploy. | `claude plugin install replica-skill@ibaad-toolkit` | 1.0.0 · 77c9436 | MIT | no |
| [ai-website-cloner-template](https://github.com/JCodesMore/ai-website-cloner-template) | website | The website cloner. A project template, not a plugin: `/clone-website <url>` runs recon, writes specs, builds sections in parallel and checks a visual diff. | `gh repo create <name> --private --template JCodesMore/ai-website-cloner-template --clone` (Node 24+), then `/clone-website <url>` | your copy: v0.5.1 · f50066d; upstream ee3f5a2 | MIT | no (your only commits are one site build on a local branch, not changes to the tool) |
| [taste-skill](https://github.com/Leonxlnx/taste-skill) | website | Anti-slop art direction for landing pages: researched directions, real pictures, a browser inspector and a critique loop. | `claude plugin install taste-skill@ibaad-toolkit` | 2.0.0 · f624f37 | MIT | packaging only: your Claude app upload keeps just `design-taste-frontend` (unchanged) with your own plugin.json and README. This entry installs the full upstream plugin, which has more skills |
| [ui-ux-pro-max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | website | Searchable UI/UX data: styles, palettes, font pairings, UX guidelines, chart types. Overlaps with taste-skill; useful for its palette and font data. | `claude plugin install ui-ux-pro-max@ibaad-toolkit` | 2.15.0 · 56ea9cf (installed copy from 2026-10-13) | MIT | no |
| [wix](https://github.com/wix/skills) | website | Official Wix skills (headless, CLI apps, design system, site management) plus the Wix MCP server (OAuth, no key). | `claude plugin install wix@ibaad-toolkit` | 1.31.2 · 4d287ed (the Claude app has 1.19.1) | MIT | no |
| [brightdata-plugin](https://github.com/brightdata/skills) | core | Web data for any toolkit: scrape pages, search, structured data from big platforms, competitor intel, brand listening, SEO audits. Its CLI and MCP need a Bright Data API key. | `claude plugin install brightdata-plugin@ibaad-toolkit` | 1.9.0 · 37503c1 | MIT | no |
| [clangd-lsp](https://github.com/anthropics/claude-plugins-official) | engineering | C and C++ code intelligence (go to definition, diagnostics) for firmware work. Needs `clangd` on the PATH. | `claude plugin install clangd-lsp@claude-plugins-official` | 1.0.0 · fbe07fb | Apache-2.0 | no |
| [swift-lsp](https://github.com/anthropics/claude-plugins-official) | app | Swift code intelligence for iOS work. Needs Xcode's `sourcekit-lsp`. | `claude plugin install swift-lsp@claude-plugins-official` | 1.0.0 · ad30d62 | Apache-2.0 | no |
| [Figma MCP](https://developers.figma.com/docs/figma-mcp-server/) | app | Read Figma frames, variables and design context while building screens. | `claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp` (sign in on first use) | hosted | Figma service terms | no |

## Recommended, not installed yet

From the research in `docs/RESEARCH-2026-10-16.md`. Try one before adding it to your daily set, then move its row up.

| Name | Toolkit | What it's for | Install | Version · commit | Licence | My changes |
|---|---|---|---|---|---|---|
| [blender-mcp](https://github.com/ahujasid/mcp-for-blender) | video | Drive Blender from Claude: scenes, materials, bpy. | `claude mcp add --scope user blender -- uvx blender-mcp==2.0.0`, then install the Blender addon from the repo | 2.0.0 (PyPI) · 7a0373e | MIT | no |
| [remotion skills](https://github.com/remotion-dev/skills) | video | Programmatic video with Remotion: captions, motion graphics, renders. | `npx -y skills@1.7.2 add remotion-dev/skills -g -a claude-code -y` | 1441a11 | no licence file | no |
| [claude-code-video-toolkit](https://github.com/digitalsamba/claude-code-video-toolkit) | video | ffmpeg, ElevenLabs voice, Playwright screen recording and image models in one project. | clone, `uv sync`, then `/setup` inside it (ElevenLabs and image-model keys are optional) | 959e0fc | MIT | no |
| [claude-ffmpeg-skill](https://github.com/ychoi-kr/claude-ffmpeg-skill) | video | Tested ffmpeg recipes and platform presets. | `npx -y skills@1.7.2 add ychoi-kr/claude-ffmpeg-skill -g -a claude-code -y` | b88cb5c | MIT | no |
| [runway-api](https://github.com/runwayml/skills) | video | Runway video and image generation. Only worth it with a paid Runway account; calls need `RUNWAYML_API_SECRET`. | `claude plugin install runway-api@ibaad-toolkit` | 4.0.0 · 4d6c53d | MIT | no |
| [impeccable](https://github.com/pbakaus/impeccable) | website | Deterministic design anti-pattern detector with a hook on UI edits. Run `/impeccable init` once per project. | `claude plugin install impeccable@ibaad-toolkit` | 4.6.0 · 6af45ac | Apache-2.0 | no |
| [claude-seo](https://github.com/AgriciDaniel/claude-seo) | website | `/seo` commands: audit, schema, programmatic pages, GEO, PageSpeed. | `claude plugin marketplace add AgriciDaniel/claude-seo` then `claude plugin install claude-seo@agricidaniel-claude-seo` (its own marketplace; the name is reserved in ours) | 2.4.2 · 4b99de2 | MIT | no |
| [geo-seo-claude](https://github.com/zubair-trabzada/geo-seo-claude) | website | AI-search citability: llms.txt, crawler access, citation checks. | clone, then run its `./install.sh` | 989cae0 | MIT | no |
| [ui-craft](https://github.com/educlopez/ui-craft) | website | Accessibility and responsive audit agent. | `claude plugin marketplace add educlopez/ui-craft` then `claude plugin install ui-craft@ui-craft` (Claude Code only, from its own marketplace, not ours: its `hooks/hooks.json` spells the event `preToolUse`, so Claude Desktop skips the whole plugin from a marketplace; that hook is written for Cursor and does not run in Claude Code either) | 1.0.0 · unpinned (upstream main; eb88d0a last checked) | MIT | no |
| [shopify-plugin](https://github.com/Shopify/Shopify-AI-Toolkit) | website | Official Shopify AI Toolkit: Liquid themes, Admin and Storefront APIs, app development. | `claude plugin install shopify-plugin@ibaad-toolkit` | 2.2.0 · a788f6a | MIT | no |
| [Shopify dev MCP](https://www.npmjs.com/package/@shopify/dev-mcp) | website | Shopify docs search and GraphQL validation. No key. | `claude mcp add --scope user shopify-dev-mcp -- npx -y @shopify/dev-mcp@1.17.0` | 1.17.0 (npm) | ISC | no |
| [android-reverse-engineering](https://github.com/SimoneAvogadro/android-reverse-engineering-skill) | app | APK decompile with jadx: endpoints, features, libraries. Pairs with replica-skill for Android apps. Needs JDK 17+ and jadx. | `claude plugin install android-reverse-engineering@ibaad-toolkit` | 1.5.0 · 0c7cf89 | Apache-2.0 | no |
| [expo](https://github.com/expo/skills) | app | Official Expo skills: router, native UI, EAS builds and store submission. | `claude plugin install expo@ibaad-toolkit` | 927dd7c | MIT | no |
| [android-skills](https://github.com/android/skills) | app | Official Google Android skills. | `claude plugin install android-skills@ibaad-toolkit` | 1.0.15 · 5bda39f | Apache-2.0 | no |
| [aso-skills](https://github.com/appeeky/aso-skills) | app | App Store Optimisation: keywords, screenshots, listing tests, rejection recovery. | `claude plugin install aso-skills@ibaad-toolkit` | 1.0.0 · 3919d7c | MIT | no |
| [app-store-preflight-skills](https://github.com/truongduy2611/app-store-preflight-skills) | app | Scan an app for App Review rejection patterns before submitting. | `npx -y skills@1.7.2 add truongduy2611/app-store-preflight-skills -g -a claude-code -y` | e52e007 | MIT | no |
| [flutter-all](https://github.com/cleydson/flutter-claude-code) | app | Flutter agents and patterns. Thin; expect to maintain your own notes on top. | `claude plugin install flutter-all@ibaad-toolkit` | 4319e00 | no licence file | no |
| [text-to-cad](https://github.com/earthtojake/text-to-cad) | engineering | CAD from text, STEP/STL/3MF, printability check, OrcaSlicer G-code, send to Bambu printers. Turn telemetry off: `uvx cadgen telemetry off`. | `claude plugin install text-to-cad@ibaad-toolkit` | 0.7.21 · 2457312 | MIT | no |
| [freecad-mcp](https://github.com/neka-nat/freecad-mcp) | engineering | FreeCAD GUI and FEM from Claude. | install the FreeCAD addon from the repo, then `claude mcp add --scope user freecad -- uvx freecad-mcp==0.1.27` | 0.1.27 (PyPI) · 78bf023 | MIT | no |
| [KiCAD-MCP-Server](https://github.com/mixelpixx/KiCAD-MCP-Server) | engineering | PCB design in KiCad 9. | clone, run `./setup-macos.sh`, then add it to the MCP config as its README says | cbb59a6 | MIT | no |
| [bambu-printer-mcp](https://github.com/DMontgomery40/bambu-printer-mcp) | engineering | Printer control over the local network. | `claude mcp add --scope user bambu -e BAMBU_HOST=… -e BAMBU_SERIAL=… -e BAMBU_TOKEN=… -- npx -y @rowbotik/bambu-printer-mcp@1.1.1` | 1.1.1 (npm) · e86498d | GPL-2.0 | no |
| [superpowers](https://github.com/obra/superpowers) | engineering | Brainstorming, planning, systematic debugging. | `claude plugin install superpowers@ibaad-toolkit` | 7.0.0 · bb92a77 | MIT | no |
| [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | engineering | Think before coding, simplicity first, surgical changes: the anti-over-engineering layer. | `claude plugin install andrej-karpathy-skills@ibaad-toolkit` | 1.0.0 · 2c60614 | MIT (stated in README; no licence file) | no |
| [marketing-skills](https://github.com/coreyhaines31/marketingskills) | marketing | About 50 skills: copywriting, CRO, launch, emails, competitor profiling, pricing. | `claude plugin install marketing-skills@ibaad-toolkit` | 2.11.37 · 365b412 | MIT | no |
| [claude-ads](https://github.com/AgriciDaniel/claude-ads) | marketing | `/ads` audit, plan, create and optimise with gated changes, for Google and Meta. | `claude plugin marketplace add AgriciDaniel/claude-ads` then `claude plugin install claude-ads@ai-marketing-hub-claude-ads` (its own marketplace; the name is reserved in ours) | 2.0.2 · ac21644 | MIT | no |
| [advertising-skills](https://github.com/realkimbarrett/advertising-skills) | marketing | Direct-response copy system: avatar, awareness mapping, headline matrix, angles. | `npx -y skills@1.7.2 add realkimbarrett/advertising-skills -g -a claude-code -y` | 45f4a4a | MIT (stated in README; no licence file) | no |
| [google-analytics-mcp](https://github.com/googleanalytics/google-analytics-mcp) | marketing | Official GA4 reporting. | `claude mcp add --scope user analytics -- pipx run analytics-mcp==0.7.0` after setting up credentials | 0.7.0 (PyPI) · 75c0e1b | Apache-2.0 | no |
| [Nano-Banana-MCP](https://github.com/ConechoAI/Nano-Banana-MCP) | marketing | Cheap static-ad image iteration with Gemini image models. | `claude mcp add --scope user nano-banana -e GEMINI_API_KEY=… -- npx -y nano-banana-mcp@1.0.3` | 1.0.3 (npm) · 6ccf50a | MIT | no |

## Needs a key: not installed by the script

Install these by hand once you have the key.

- **bambu-printer-mcp**: printer IP address, serial number and LAN access code.
- **google-analytics-mcp**: Google Application Default Credentials with the `analytics.readonly` scope (`gcloud auth application-default login --scopes ...`) and `GOOGLE_PROJECT_ID`.
- **Nano-Banana-MCP**: `GEMINI_API_KEY`.
- **brightdata-plugin**: the plugin installs without a key, but its CLI and MCP tools need `BRIGHTDATA_API_KEY` (or `bdata login`).
- **runway-api**: the plugin installs without a key, but every call needs `RUNWAYML_API_SECRET`.

## Connected in the Claude app, not installable from here

Connectors you sign in to under Settings → Connectors: Meta Ads, Mailchimp, Shopify, Wix, Canva, Gmail, Google Calendar, Drive, Docs, Sheets and Slides, Atlassian, Zoho Mail. They reach Claude Code through your claude.ai account. Nothing to install.

## Built in, nothing to install

Anthropic's own skills (docx, pdf, pptx, xlsx, skill-creator and the rest) come with the Claude app and Claude Code. Skills bundled with SDKs and editors (the Flutter SDK's agent skills, Pylance's) belong to those tools.

## Keeping it current

Monthly (`prompts/09-review.md`): for each row, compare the pinned commit with upstream, read the changes, and bump the `sha` in `marketplace.json` and the commit here together.
