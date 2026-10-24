# digital-marketing

Run paid and organic marketing on small budgets with Claude: research competitors and their ads, decide strategy from data instead of a content calendar, produce static and video ads that keep the product exact, operate Meta and Google accounts safely, and run newsletters. Built from a working ads loop that ran on a small daily budget.

Requires `core`. Ad production mechanics (Firefly, ffmpeg, Blender) come from `video-production`.

## Install
```
/plugin install digital-marketing --marketplace ibaadrh/agent-toolkit
```
Install `core` the same way first.

## Skills

| Skill | Use it when | Status |
|---|---|---|
| `paid-ads-strategist` | Start of every ads session: load state and fresh data, apply the owner's readability gates, walk the decision ladder (continue / refine / new test / kill), write the `## BRIEF`. Has a dry-run mode | done |
| `meta-campaigns-operator` | Build, test, scale, pause and diagnose on Meta: ABO per cell, launch sequence, thresholds, cheapest-first diagnosis, the authority envelope | migrate (raw skill in the private inbox) |
| `static-ad-maker` | Brief → static ad: AI hero with exact product, the client's own layouts and rubric from their config, upload to CDN and Meta | migrate (raw skill and playbook in the private inbox) |
| `ugc-video-ad-maker` (loop role) | Brief → UGC-style video; mechanics in video-production | migrate (raw skill in the private inbox) |
| `competitor-ad-research` | Meta Ads Library sweep of competitors: formats, hooks, offers, longevity; clustered into a one-page read | write new (Meta MCP `ads_library_search` + the Composio extractor pattern) |
| `social-content-research` | Research → dated post ideas, as many and as often as `content.yaml` sets | migrate (raw skill in the private inbox) |
| `b2b-social-copywriter` | Post copy in the client's own post format, from their config | migrate (raw skill in the private inbox) |
| `canva-post-builder` | New post page in a client's master Canva file from catalogued formats, with AI photo prompts | migrate (raw skill in the private inbox) |
| `low-budget-launch-plan` | New product or client with a small budget: what to run first, how much, what to measure, when to stop | write new from your doctrine |
| `newsletter-system` | Setting up and running a newsletter: list, cadence, template, send, measure (Mailchimp MCP) | write new |
| `free-tools-stack` | The current best free tool for each marketing job, re-checked monthly | write new |

## Install alongside

| Tool | Why | Install | Licence | In use |
|---|---|---|---|---|
| [marketing-skills](https://github.com/coreyhaines31/marketingskills) | About 50 skills: copywriting, CRO, launch, emails, competitor profiling, pricing. | `claude plugin install marketing-skills@ibaad-toolkit` | MIT | no |
| [claude-ads](https://github.com/AgriciDaniel/claude-ads) | `/ads` audit, plan, create and optimise with gated changes, for Google and Meta. | `claude plugin marketplace add AgriciDaniel/claude-ads` then `claude plugin install claude-ads@ai-marketing-hub-claude-ads` (its own marketplace; the name is reserved in ours) | MIT | no |
| [advertising-skills](https://github.com/realkimbarrett/advertising-skills) | Direct-response copy system: avatar, awareness mapping, headline matrix, angles. | `npx -y skills@1.7.2 add realkimbarrett/advertising-skills -g -a claude-code -y` | MIT (stated in README; no licence file) | no |
| [google-analytics-mcp](https://github.com/googleanalytics/google-analytics-mcp) | Official GA4 reporting. | `claude mcp add --scope user analytics -- pipx run analytics-mcp==0.7.0` after setting up credentials | Apache-2.0 | no |
| [Nano-Banana-MCP](https://github.com/ConechoAI/Nano-Banana-MCP) | Cheap static-ad image iteration with Gemini image models. | `claude mcp add --scope user nano-banana -e GEMINI_API_KEY=… -- npx -y nano-banana-mcp@1.0.3` | MIT | no |

Full list, versions and pins: [docs/THIRD-PARTY.md](../../docs/THIRD-PARTY.md).

## Config files used
`brand.yaml`, `ads.yaml`, `meta.yaml`, `product-spec.md`, `content.yaml`, `voice.yaml`, `canva.yaml`, `references.yaml`.
