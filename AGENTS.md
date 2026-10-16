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

## When asked to "update the toolkit" with a learning
1. Find the one skill or core reference that owns that mechanic.
2. Edit it there. Do not duplicate into other skills.
3. Bump the patch version in that plugin's `plugin.json`.
4. Commit with a one-line message naming the skill.
