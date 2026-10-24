---
name: brief-contract
description: The exact `## BRIEF` block that the ads strategist writes and the ad makers and campaign operator parse, plus how each maker uses every field and what each one hands back. Use it when writing a brief, when a skill receives a `## BRIEF` block, when checking a brief before hand-off, or when building a new skill that consumes briefs.
---

# Brief contract

The paid-ads loop is a chain: the strategist decides, a maker builds, the campaign operator ships. The `## BRIEF` block is the only thing that passes between them, so its shape is fixed. This skill holds that shape, the checks a brief must pass, how each maker reads it, and what comes back.

## Config
This skill needs:
- `brand.yaml` (keys: `brand.languages`, `docs.live_state`, `docs.run_log`)
- `ads.yaml` (keys: `ads.destination_url`, `ads.spend_cap_per_day`, `ads.thresholds.min_impressions_per_cell`, `ads.thresholds.min_leader_link_clicks`, `angle_bank`)
- `voice.yaml` (keys: `voice.approved_claims`, `voice.claim_rules`)

Look in this order: see `core/client-config`. A missing key stops the check that needs it, and the report names it.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` to read the keys above
- `core/house-report` for the hand-off report
- `core/readable-test-doctrine` for the gate behind `Decision date`

## The block
One brief per decision. Write it exactly like this; the makers parse it line by line.

```
## BRIEF <YYYY-MM-DD>-<n>
Decision: NEW TEST | REFINE | CONTINUE | KILL   (rung <n> of the ladder)
Hypothesis: <one falsifiable sentence>
Format: static | video
Language: <one code from brand.languages, upper case, e.g. EN>
Angle: <which angle from the angle bank>
Headline: <exact text on the visual>
Subhead: <exact text, or none>
Primary text: <the ad body copy>
Destination: <URL>
utm_content: <unique slug; this is how the store attributes sales>
Tested against: <control ad ID, or "new baseline">
Success metric: <cost per link click | cost per LPV | cost per lead>
Budget: <amount per day per cell, in the ad account's currency>
Decision date: <when this becomes readable, per the readability gate>
```

A field that does not apply says `none`. Never leave a line out.

## Steps: writing a brief
1. Fill every field. The `<n>` in the heading counts briefs written that day, from 1.
2. **Hypothesis** is one sentence that the test can prove wrong.
3. **Angle** comes from the angle bank: the live state document's, or `angle_bank` in ads.yaml when the live state has none. A REFINE keeps the winner's angle and format and changes only the execution. If the angle bank is empty (always true for a new client until the owner fills it), write no NEW TEST brief: tell the owner and ask for angles.
4. **Never change format and angle in the same brief.** If both move, nobody can tell which one moved the number.
5. **utm_content is unique.** Check it against every slug in the live state's test history. A reused slug destroys attribution.
6. **Destination** is `ads.destination_url`. A different destination is a stop-and-ask change for the owner, never a brief decision.
7. **Budget** per cell, times the number of cells, stays inside `ads.spend_cap_per_day`.
8. **Decision date** is when both cells should pass the readability gate (`min_impressions_per_cell` in each cell and `min_leader_link_clicks` for the leader) at the planned budget.
9. **Copy** in Headline, Subhead and Primary text follows `voice.claim_rules` and uses only `voice.approved_claims`. All of it is in the brief's language.
10. Write the brief and the decision into the live state document, and one line into the run log.

## Steps: receiving a brief
1. **Take everything from the brief and ask nothing.** A maker that has a brief does not ask the user about angle, language or copy.
2. **The headline belongs to the strategist.** Use Headline and Subhead character for character. If the copy breaks a design or length rule, build it as written anyway, and put a shorter alternative in the report.
3. Read each field as the table below says.
4. No brief and no direct request from the user: stop. Do not invent a creative.

| Field | Static maker | Video maker | Campaign operator |
|---|---|---|---|
| `Decision` | which rung; REFINE means same angle and format, new execution | which rung; same rule | what to build, pause or keep |
| `Format` | must say `static` | must say `video` | which asset to expect back |
| `Language` | the language of every word in the image | the language of speech, captions and end card | the ad's copy language |
| `Angle` / `Hypothesis` | the scene and the layout | the concept and the hook | the test name and history entry |
| `Headline` / `Subhead` | the exact text on the image | the exact end-card text | the ad's headline field |
| `Primary text` | tone reference, and the only claims allowed as proof points | tone and claims for the voice-over script | the ad's body copy, as written |
| `Destination` | not used | the end-card call to action | the ad's link |
| `utm_content` | goes in the file name | goes in the file name | the ad's URL parameter |
| `Tested against` | not used | not used | the control in the test |
| `Success metric`, `Budget`, `Decision date` | not used | not used | the cell budgets and when to read the result |

## Hand-off
- `Format: static` → the static ad maker. `Format: video` → the video ad maker.
- After the maker, always → the campaign operator, to build and ship.
- `CONTINUE` or `KILL` → no maker. The campaign operator acts only if something needs pausing.

What comes back from the maker to the campaign operator:
- **Static:** for each ratio, the image's ad-platform hash and its public URL; the exact headline and primary text used; the `utm_content`; the AI disclosure setting.
- **Video:** the video file, the ad platform's video ID, the end-card image, the `utm_content`, the AI disclosure setting.

## Output
A brief that passes every check above, written to the live state document, or a stop that names the check that failed.

## Known failures
- **Attribution broke between two tests.** Cause: two briefs shared one `utm_content`. Fix: check the slug against the whole test history (writing step 5).
- **A test result could not be read.** Cause: the brief changed format and angle at once. Fix: one variable per brief (writing step 4).
- **One English word in a non-English image.** Cause: copy came from somewhere other than the brief, or a label was left in the template language. Fix: every word in the brief's language, checked before upload.
- **The maker rewrote the headline to fit the layout.** Cause: treating the headline as a suggestion. Fix: use it as written and offer a shorter one in the report (receiving step 2).
- **A brief spent above the cap.** Cause: budget set per cell without multiplying by the number of cells. Fix: writing step 7.
- **A maker invented a creative on a quiet week.** Cause: running with neither a brief nor a request. Fix: stop (receiving step 4). A winner that is still winning needs nothing built.

## References
- None. The block above is the whole contract.
