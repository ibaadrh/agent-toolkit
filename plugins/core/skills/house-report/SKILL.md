---
name: house-report
description: The one report format every toolkit skill ends with. One sentence on what was decided or built, two or three metrics, what changed, then numbered points for the owner or the line "Nothing needed from your side." Use it at the end of every run, when writing a run-log line, and whenever a skill says "report in the house format".
---

# House report

Every run ends with the same short report, so the owner can read any skill's result in ten seconds. This skill holds that format, the rules that keep it honest, and the three-strikes rule. A good run can be a three-line report.

## Config
This skill needs: `brand.yaml` (keys: `owner.name`, optional), and the live documents the calling skill uses (keys: `docs.run_log`, optional).
Look in this order: see `core/client-config`. If `owner.name` is missing, address the points to "you". If `docs.run_log` is missing, skip the log line and say so once.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` to find `owner.name` and `docs.run_log`
- `core/platform-adapters` for "write a project doc" (the run-log line)

## Inputs
What the run did, the numbers behind it, and anything the owner has to do. The calling skill says which two or three metrics matter for it.

## Steps
1. **Check before you claim.** Before reporting anything as done, confirm it from the result itself, not from a tool's success message. A file is in the folder (list it). An ad shows the expected status. A link opens the file with the right title and version. A tool result saying "success" is a claim, not evidence.
2. **Write the report in this shape, in this order:**
   1. **One sentence:** what you decided, did or built.
   2. **Two or three metrics:** only the ones behind the decision or the result. Nothing else. Each skill names its own (for example: cost per link click and spend share; candidates made and passed; credits spent, runtime and file size).
   3. **What changed:** what you changed and where the files or IDs are. Or that you changed nothing, and why.
   4. **For the owner:** numbered points (`1.` `2.`), each one thing the owner must do or decide. Or exactly this line: **Nothing needed from your side.**
3. **Keep it plain.** Simple English. No jargon, no essay, no headings for a short report. If the honest answer is "the current one is still the best, I changed nothing", that is a good result and a three-line report.
4. **Give the source of every number you acted on.** A threshold with no source is a guess. Say where it came from: the client's config, the template default, or the data window you pulled.
5. **Flag every assumption you made instead of asking.** In an unattended run, say plainly what you assumed and what the owner should check. Say what you could not verify (for example, "the font still needs setting by hand; I could not set it").
6. **Report exact identifiers.** Give the real number, ID, file name or link that was used, so the owner can check it in one step.
7. **List missing config.** If a step was skipped for a missing key, name the file and key in the numbered points.
8. **Apply the three-strikes rule.** Before writing a numbered point, check the run log. If you flagged the same issue twice before and fixing it is inside your authority, the third time fix it instead of flagging it again, and report the fix. With no run log, check the live documents the skill reads; if there is no history at all, flag as normal.
9. **Log one line.** If `docs.run_log` is set, append one line: the date, the skill, and the one-sentence summary. Append only; never rewrite earlier lines.

## Output
The report, in chat, in the shape above. One run-log line if a run log is configured.

Example:
> Kept the current ad live; it is still beating its own two-week baseline.
> Cost per link click 0.41 (baseline 0.44), frequency 2.1.
> Changed nothing.
> Nothing needed from your side.

## Known failures
- **A report said "done" and it wasn't.** Cause: trusting a tool's success message. One delivery call wrote 2 of 3 files. Fix: check the result itself before reporting (step 1).
- **The same problem was flagged week after week.** Cause: logging a recommendation instead of acting on it. Fix: the three-strikes rule (step 8).
- **Risk: the owner cannot check a result.** Cause: the report says "the invoice" or "the new ad" instead of the number or ID. The invoice skill always reports the exact number because its numbering can collide. Fix: exact identifiers (step 6).
- **A finishing step was claimed as complete.** Cause: the tool could not do it (for example, no way to set a font family), and the report did not say so. Fix: name what you could not do as a numbered point (step 5).

## References
- None. The format is short on purpose.
