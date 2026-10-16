# website-development

Build public-facing websites that look designed, not generated: clone a reference site when that's the brief, apply strict taste rules, build on Wix headless or Shopify when business features are needed, and ship with SEO and AI-search readiness done.

Requires `core`.

## Install
```
/plugin install website-development --marketplace ibaadrh/agent-toolkit
```
Install `core` the same way first.

## Skills

| Skill | Use it when | Status |
|---|---|---|
| `wix-headless-launch` | Building a site that needs Wix business features (forms, store, bookings, CMS) with a custom frontend; the setup, build and release order that works | write new (collect your notes from past Wix projects first) |
| `shopify-storefront-launch` | Building or reworking a Shopify storefront; theme vs headless decision, CDN use, speed | write new |
| `site-seo-baseline` | Before launch: your own checklist on top of `claude-seo` (metadata, schema, llms.txt, Core Web Vitals, hreflang for every language) | write new |
| `site-cloning-brief` | Turning "make it like this site" into a build brief: what to copy (structure, rhythm) and what never to copy (copy, brand assets) | write new, thin wrapper around the cloner template |

## Install alongside

| Tool | Why | Install | Licence | In use |
|---|---|---|---|---|
| [ai-website-cloner-template](https://github.com/JCodesMore/ai-website-cloner-template) | The website cloner. A project template, not a plugin: `/clone-website <url>` runs recon, writes specs, builds sections in parallel and checks a visual diff. | `gh repo create <name> --private --template JCodesMore/ai-website-cloner-template --clone` (Node 24+), then `/clone-website <url>` | MIT | yes |
| [taste-skill](https://github.com/Leonxlnx/taste-skill) | Anti-slop art direction for landing pages: researched directions, real pictures, a browser inspector and a critique loop. | `claude plugin install taste-skill@ibaad-toolkit` | MIT | yes |
| [ui-ux-pro-max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | Searchable UI/UX data: styles, palettes, font pairings, UX guidelines, chart types. Overlaps with taste-skill; useful for its palette and font data. | `claude plugin install ui-ux-pro-max@ibaad-toolkit` | MIT | yes |
| [wix](https://github.com/wix/skills) | Official Wix skills (headless, CLI apps, design system, site management) plus the Wix MCP server (OAuth, no key). | `claude plugin install wix@ibaad-toolkit` | MIT | yes |
| [impeccable](https://github.com/pbakaus/impeccable) | Deterministic design anti-pattern detector with a hook on UI edits. Run `/impeccable init` once per project. | `claude plugin install impeccable@ibaad-toolkit` | Apache-2.0 | no |
| [claude-seo](https://github.com/AgriciDaniel/claude-seo) | `/seo` commands: audit, schema, programmatic pages, GEO, PageSpeed. | `claude plugin marketplace add AgriciDaniel/claude-seo` then `claude plugin install claude-seo@agricidaniel-claude-seo` (its own marketplace; the name is reserved in ours) | MIT | no |
| [geo-seo-claude](https://github.com/zubair-trabzada/geo-seo-claude) | AI-search citability: llms.txt, crawler access, citation checks. | clone, then run its `./install.sh` | MIT | no |
| [ui-craft](https://github.com/educlopez/ui-craft) | Accessibility and responsive audit agent. | `claude plugin marketplace add educlopez/ui-craft` then `claude plugin install ui-craft@ui-craft` (Claude Code only, from its own marketplace, not ours: its `hooks/hooks.json` spells the event `preToolUse`, so Claude Desktop skips the whole plugin from a marketplace; that hook is written for Cursor and does not run in Claude Code either) | MIT | no |
| [shopify-plugin](https://github.com/Shopify/Shopify-AI-Toolkit) | Official Shopify AI Toolkit: Liquid themes, Admin and Storefront APIs, app development. | `claude plugin install shopify-plugin@ibaad-toolkit` | MIT | no |
| [Shopify dev MCP](https://www.npmjs.com/package/@shopify/dev-mcp) | Shopify docs search and GraphQL validation. No key. | `claude mcp add --scope user shopify-dev-mcp -- npx -y @shopify/dev-mcp@1.17.0` | ISC | no |

Full list, versions and pins: [docs/THIRD-PARTY.md](../../docs/THIRD-PARTY.md).

## Config files used
`brand.yaml`, `site.yaml`.
