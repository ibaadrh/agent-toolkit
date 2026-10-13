---
name: readable-test-doctrine
description: The rules that decide whether a paid-ads test can be read at all, and how to build one that can. Covers the readability gates (impressions per cell, leader link clicks), one ABO ad set per cell and never a split test inside CBO, the spend-share check, the decision-metric order, the rule-of-three table for zero conversions, culling, and the don't-fool-yourself list. Use it before declaring any ad a winner or loser, when building an A/B test, and when someone asks "is this ad working?".
---

# Readable test doctrine

Most ad "tests" at small budgets cannot be read. Cells get unequal money, samples are too small, and a zero-purchase week gets treated as a verdict. This skill holds the rules that keep a test fair and the gates a result must pass before anyone acts on it. Every number here is a default; `ads.yaml` can override it, and the report says which applied.

## Config
This skill needs: `ads.yaml` (keys: `ads.thresholds.min_impressions_per_cell`, `ads.thresholds.min_leader_link_clicks`, `ads.thresholds.spend_share_band`, `ads.thresholds.cells_per_test`, `ads.thresholds.cull_cost_multiple`, `ads.thresholds.decision_metric_order`, `ads.objective`).
Look in this order: see `core/client-config`. These keys come filled in with the defaults below. If a key is absent from an older file, use the default and say so.

| Key | Default |
|---|---|
| `min_impressions_per_cell` | 300 |
| `min_leader_link_clicks` | 25 |
| `spend_share_band` | [40, 60] |
| `cells_per_test` | 2 |
| `cull_cost_multiple` | 2 |
| `decision_metric_order` | cost per link click, cost per landing page view, cost per add to cart, purchases |

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the thresholds
- `core/brief-contract`: a brief's `Decision date` comes from the gate here
- `core/house-report`: every verdict states which thresholds it used and where they came from

## Inputs
The test's cells, and per cell for the test window: spend, impressions, link clicks, landing page views, adds to cart, purchases. Plus the store's orders for the same window, from all channels.

## Steps: building a test that can be read
1. **Two cells.** `cells_per_test` ads, usually two. Never six: a six-ad set once gave nearly all of the spend to half the ads and almost nothing to the rest.
2. **Never run a creative split test inside a CBO campaign.** A platform split test inside CBO only fixes the test's own small budget; CBO moves the rest freely. One such test sent most of the money to one cell and bought more than a week of nothing readable.
3. **One ABO ad set per cell**, each with the same fixed daily budget. One ad per ad set.
4. **Only the tested variable differs.** Same targeting, placements, schedule and destination in every cell.
5. **A distinct `utm_content` per cell**, so the store can attribute each cell on its own.
6. **Test cells are bound to ad IDs.** A platform A/B study cannot be repointed to a new ad. Replacing an ad means cancelling the study and creating a new one.
7. **Never change budget, creative and targeting in the same move.** Nobody can tell which one moved the number.

## Steps: reading a result
1. **Check the store first.** Pull the store's orders for the window with no channel filter. If the store sold nothing on any channel, the ad numbers say nothing about the creative. Report that first and conclude nothing.
2. **Check the split held.** Compute each cell's share of spend. Outside `spend_share_band` (40/60), the test did not run. Rebuild it; do not report a winner. A starved cell is not a losing cell.
3. **Apply the creative gate.** Readable only when every cell has at least `min_impressions_per_cell` impressions and the leader has at least `min_leader_link_clicks` link clicks. Below either: the answer is CONTINUE. Say how far off each number is.
4. **Never decide a creative test on purchases.** With zero conversions, the highest true conversion rate still plausible (rule of three, 95%) is about 3 divided by the visits:

   | Visits with 0 conversions | Max plausible true rate |
   |---|---|
   | 100 | 3.0% |
   | 300 | 1.0% |
   | 500 | 0.60% |
   | 1,000 | 0.30% |

   At small volume a zero-purchase week is not evidence that a creative failed. Purchases answer one slower question: does paid advertising pay at all. Ask it monthly, not weekly.
5. **Decide on the metric order.** Use `decision_metric_order`: cost per link click first, then cost per landing page view, then cost per add to cart. Purchases only confirm. For a leads objective, cost per lead takes the place of purchases.
6. **"Inconclusive" is a valid result.** Say it when the cells were not funded alike or the sample was thin.
7. **Cull only past the gate.** Pause a creative only when it has at least `min_impressions_per_cell` impressions and costs more than `cull_cost_multiple` times the leader per landing page view. Below the impression gate, take no action at all.
8. **State the source of every threshold** in the verdict: the client's `ads.yaml` or the default here.

## Don't fool yourself
- A starved cell is not a losing cell. Check spend share before naming a winner.
- Cheap CPM is a warning, not a win. It usually means low-intent inventory.
- High CTR with no sales means the ad attracts the wrong people efficiently. That is a hook and offer mismatch, not a creative success.
- Zero conversions does not prove broken tracking. A working pixel and a broken one look the same when nobody buys. Cross-check the store.
- Configured budgets lie. Pull actual daily spend before judging pace or scaling; delivery often runs over the set budget.
- At small budgets no optimisation event reaches the platform's learning threshold (on Meta, about 50 conversions a week), not even link clicks. Stop treating the learning phase as something to fix. Gains come from creative, offer and placement.
- A number with no source is a guess.

## Output
A verdict per test: readable or not (with the gap), winner, loser or inconclusive, the metric it rests on, and the thresholds used with their source.

## Known failures
- **More than a week and a full test budget bought no answer.** Cause: a split test inside CBO; most of the spend went to one cell. Fix: one ABO ad set per cell (building step 2 and 3).
- **A "test" of six ads gave almost all the money to three.** Fix: two cells (building step 1).
- **Risk: judging a creative on a zero-purchase week.** At small volume it proves nothing. Fix: the purchase rule and the rule-of-three table (reading step 4).
- **Risk: blaming the ads in a week the whole store sold nothing.** Fix: check the store first, all channels (reading step 1).
- **A new ad could not be swapped into a running A/B study.** Cause: study cells are bound to ad IDs. Fix: cancel the study and create a new one (building step 6).
- **A campaign spent about a quarter more than its daily budget in one day.** Fix: read actual daily spend, never the setting.

## References
- None. The tables above are the whole doctrine.
