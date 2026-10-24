# Decoupling checklist

Use this to turn a client-specific skill into a generic one plus a config file. Go line by line.

## 1. Sort every line of the old skill into one of five buckets
| Bucket | Example | Goes to |
|---|---|---|
| Mechanic | "create the ad paused, then preview, then activate with explicit object_ids" | generic skill |
| Shared mechanic | the ffmpeg crop recipe, the report format | `core` (reference it from the skill) |
| Client value | an ad account ID, a hex colour, the product's name, a Drive path, "<the owner> approves" | config file |
| Client history | "on <date> we agreed <budget> a day", the hero bank names, the test log | `agent-clients/clients/<client>/docs/` |
| Client style | a house video style (lengths, speeds, grade, fades, music timing, caption look), a post format, ad layouts, fonts, colours, product sizes, scene lines | that client's private config or their own private skill; never the toolkit |

Only the first two buckets go into the toolkit, plus the author's own doctrine and quality bars (section 5). If you are unsure whether a line is a mechanic or the client's style, treat it as the client's and list it in the report.

## 2. Replace values with keys
Write the key where the value was: `{{meta.ad_account_id}}`, `{{brand.colors.primary}}`, `{{drive.outputs}}`. Add every key to the Config block. If the key doesn't exist in `templates/client-config/`, add it there too (never rename existing keys).

## 3. Generalise the nouns
The product's name → "the product". The brand's name → "the brand". "Kdenlive project for <client>" → "Kdenlive project for the client". The owner's first name → "the owner" (`owner.name`). A budget figure → `ads.spend_cap_per_day` (with `ads.currency`).

## 4. Replace every tool name with an action
A tool name only works on one platform. Swap each one for the action it performs: "run JavaScript in the browser page", "deliver the file to the user", "search the Meta Ads Library". The old name and its action are in `plugins/core/skills/platform-adapters/references/claude-tools.md`. If the action is not in that table yet, add a row there (and an empty row in the other platform files). `scripts/validate.sh` fails on the common tool names anywhere outside that folder.

## 5. Keep the author's doctrine as defaults, move the client's numbers
The author's own doctrine and quality bars stay in the toolkit as defaults a client's config can override: 300 impressions, 25 clicks, 40/60, +25% steps, frequency 3, -14 LUFS, the product-check tolerances, the copy rules. Mark each one "default" in the skill and fill it in the template.
A client's own numbers and style move to that client's config: the break-even cost per sale, the product's exact dimensions, the credit balance, their caption look, music timing and layouts. The template key for those stays empty, and the skill asks.

## 6. Check the empty-config test
Read the new skill imagining a brand-new client with no config filled in. At every step ask: does the skill know what to do, or does it stop and ask for a named key? Both are fine. Guessing is not.

## 7. Keep the gold
The parts that make the old skill good are usually: exact selectors, exact commands, the failure list. These are generic. Do not shorten them. Move them to `references/` if long. A client's own rubric values and style go to the client's config.

## 8. Done when
- `scripts/validate.sh` passes (including the forbidden-terms scan)
- the skill's Config block lists every key it reads
- the skill names actions, not tools, and every action it uses has a row in the platform-adapters tables
- the client's config file has every key with a real value
- the old skill is in `../agent-clients/_inbox/_migrated/` and `INBOX.md` says done
- the report has a "kept private" list: every rule left out of the toolkit, where it went, and why
