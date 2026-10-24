# Rules for working in agent-toolkit

This repo holds generic agent skills. They work with any AI agent that reads SKILL.md files, not only Claude. Read `docs/SYSTEM.md` once before changing anything.

How to work with an agent on this repo, or any project (briefing, planning, stopping before irreversible actions, verifying, reviewing): `plugins/core/references/working-with-agents.md`.

## Hard rules
- No client data in any skill. No brand names, account IDs, pixel IDs, Drive paths, device paths, hex colours, product dimensions, people's names, invoice numbers, Jira keys. If a skill needs one, it reads it from a config file (see `templates/client-config/`) and the SKILL.md says which key.
- Skills name actions, not tools. Write 'run JavaScript in the browser page', 'deliver the file to the user', 'search the Meta Ads Library', never a platform tool name like javascript_tool or mcp__Meta_Ads__*. Tool names live only in plugins/core/skills/platform-adapters/.
- Shared mechanics go in `plugins/core`, once. Before writing a helper in a domain skill, check core.
- Every skill has the `## Config` block from `templates/skill/SKILL.md` at the top, even if the list is "none".
- Plain English. Short sentences. No em dashes. Describe steps a stranger can follow.
- Third-party skills are referenced with an install line in `docs/THIRD-PARTY.md` (and pinned in the marketplace when they are plugins), never copied into this repo.
- Commits: `git config user.email 88559161+ibaadrh@users.noreply.github.com`. Never add Co-Authored-By trailers or tool attribution. Messages describe the change.

## General use only: the author's defaults, never a client's style
- The toolkit carries the author's own methods and quality bars as defaults. It never carries a client's style, data or examples.
- agent-toolkit contains only general-use skills. Some skills are client-specific on purpose (a client's house video style, their post format, their ad layouts). Those stay private in `agent-clients` or the company config repo and are never generalised into the toolkit.
- When migrating any skill, sort every rule into (a) a neutral mechanic, or the author's own doctrine, method or quality bar (test gates and windows, copy rules, loudness target, check tolerances, prompting rules, the report format), or (b) one client's style, preference, format, data or example. (a) goes into the toolkit, written as a general rule and marked "default; a client's config can override" where it is a value. (b) stays private, as that client's settings or their own skill. If unsure, treat it as (b) and list it for the owner.
- General skills have no style defaults borrowed from a client: no client's caption looks, music timing, fade lengths, speeds, grades, video lengths, layouts, fonts, colours, formats, product sizes, prices or scene lines. A config key for one has no value in `templates/client-config/`; empty means ask, never a client's value. Keys for the author's defaults come filled in.
- Every migration report includes a "kept private" list: what was left out of the toolkit, where it went, and why.

## Protecting clients without knowing their names
- A lesson from client work goes in as a generic rule. Never include the client's names, products, numbers, dates, examples or incident stories.
- Toolkit changes only happen in sessions opened in agent-toolkit. A client-work session never edits this repo; it may suggest a generic change for the owner to apply here.
- Only one session works in agent-toolkit at a time.
- Never use `--no-verify`, and never weaken the guard, its scripts or its lists to get a push through. If the guard blocks, fix the content. Add to `scripts/allowed-names.txt`, `scripts/allowed-domains.txt` or the generic-example lines in `scripts/allowed-terms.txt` only for public tools, platforms, formats and plain generic examples, and list every addition in the report.
- The guard: `scripts/validate.sh` (forbidden terms, plus `scripts/check-allowlists.py`: unknown names, domains, emails, phone numbers, prices, measurements, long IDs and dates), `scripts/scan-history.sh` on every pushed commit, and a fresh-eyes review of the diff by a separate agent (`scripts/fresh-eyes-review.sh`) before any push that touches skills or docs. GitHub Actions runs `validate.sh` on every push to main.
- Run `scripts/validate.sh` before committing.

## Layout
- `plugins/<toolkit>/skills/<skill>/SKILL.md` plus optional `references/`, `scripts/`, `assets/`
- `plugins/<toolkit>/README.md` is the toolkit's front page; keep its skill table current
- `plugins/<toolkit>/WORKFLOW.md` is the start-to-finish playbook for that domain
- `AGENTS.md` holds these rules for every agent. `CLAUDE.md` only points here.
- `../agent-clients/_inbox/` (and the `_inbox/` of each company config repo) is raw material. Delete items from it as they are migrated and tick them in that inbox's `INBOX.md`

## When migrating a skill from an inbox
- If the inbox sources contradict each other (a raw export, a newer synced copy, a playbook, a CLAUDE.md), use the newest dated version. The date is the one in `INBOX.md`, in the file itself, or of the commit that added it.
- Don't stop to ask about each conflict. Decide, and keep going.
- List every choice in the report: what conflicted, which version you used and its date, and what you left out. The owner corrects it from that list later.
- End the report with the "kept private" list (see "General use only").

## When asked to "update the toolkit" with a learning
1. Find the one skill or core reference that owns that mechanic.
2. Edit it there. Do not duplicate into other skills.
3. Bump the patch version in that plugin's `plugin.json`.
4. Commit with a one-line message naming the skill.
