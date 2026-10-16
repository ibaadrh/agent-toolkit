# Decoupling checklist

Use this to turn a client-specific skill into a generic one plus a config file. Go line by line.

## 1. Sort every line of the old skill into one of four buckets
| Bucket | Example | Goes to |
|---|---|---|
| Mechanic | "create the ad paused, then preview, then activate with explicit object_ids" | generic skill |
| Shared mechanic | the ffmpeg crop recipe, the report format | `core` (reference it from the skill) |
| Client value | ad account ID, #1A6B5C, "Acme Hub", a Drive path, "Sam approves" | config file |
| Client history | "on <date> we agreed <budget> a day", the hero bank names, the test log | `agent-clients/clients/<client>/docs/` |

## 2. Replace values with keys
Write the key where the value was: `{{meta.ad_account_id}}`, `{{brand.colors.primary}}`, `{{drive.outputs}}`. Add every key to the Config block. If the key doesn't exist in `templates/client-config/`, add it there too (never rename existing keys).

## 3. Generalise the nouns
"Acme Hub" → "the product". "Acme" → "the brand". "Kdenlive project for Acme" → "Kdenlive project for the client". "Sam" → "the owner" (`owner.name`). A budget figure → `ads.spend_cap_per_day_eur`.

## 4. Replace every tool name with an action
A tool name only works on one platform. Swap each one for the action it performs: "run JavaScript in the browser page", "deliver the file to the user", "search the Meta Ads Library". The old name and its action are in `plugins/core/skills/platform-adapters/references/claude-tools.md`. If the action is not in that table yet, add a row there (and an empty row in the other platform files). `scripts/validate.sh` fails on the common tool names anywhere outside that folder.

## 5. Keep the numbers that are doctrine, move the numbers that are the client's
Doctrine (keep, but as defaults in config): 300 impressions, 25 clicks, 40/60, +25% steps, frequency 3.
Client (move): the break-even cost per sale, the product's exact dimensions, the credit cost per clip at the current balance.

## 6. Check the empty-config test
Read the new skill imagining a brand-new client with no config filled in. At every step ask: does the skill know what to do, or does it stop and ask for a named key? Both are fine. Guessing is not.

## 7. Keep the gold
The parts that make the old skill good are usually: exact selectors, exact commands, exact thresholds, the failure list, the rubric. These are generic. Do not shorten them. Move them to `references/` if long.

## 8. Done when
- `scripts/validate.sh` passes (including the forbidden-terms scan)
- the skill's Config block lists every key it reads
- the skill names actions, not tools, and every action it uses has a row in the platform-adapters tables
- the client's config file has every key with a real value
- the old skill is in `../agent-clients/_inbox/_migrated/` and `INBOX.md` says done
