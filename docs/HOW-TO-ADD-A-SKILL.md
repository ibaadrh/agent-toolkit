# How to add or change a skill

## Where does it go?
- Needed by two or more toolkits → `plugins/core`.
- About one domain → that toolkit.
- About one client or about you personally → `agent-clients`, never here.

## New skill
1. `./scripts/new-skill.sh <toolkit> <name>` (lowercase, hyphens, same as the folder).
2. Fill `SKILL.md` using the template sections. The description is what makes it trigger: say when, not what. Under 1024 characters.
3. Long material (prompt libraries, rubrics, layout specs) goes in `references/`. Scripts in `scripts/`. SKILL.md stays under 500 lines.
4. Config block: list every file and key the skill reads. Never a literal client value.
5. Add a row to the toolkit README. Mention it in WORKFLOW.md at the step where it's used.
6. `./scripts/validate.sh`. Commit as you.

The paste-ready version of this is `prompts/06-new-skill.md`. Use skill-creator to draft, then test on a real job before merging.

## Changing a skill
- Fix in one place. If the same fix is needed in two skills, the mechanic belongs in core; move it.
- Add what broke to "Known failures" with symptom → cause → fix.
- Bump the patch version in the plugin's `plugin.json`.

## Writing style
Plain English. Short sentences. One action per step. Name commands exactly. Name actions, never platform tool names: "run JavaScript in the browser page", not the browser tool's name. The action wording is in `plugins/core/skills/platform-adapters/references/claude-tools.md`. No em dashes. Write for a stranger with no context. Numbers and exact strings beat adjectives.

## What never goes in
Secrets, tokens, passwords, keystores, client IDs, personal names, Drive paths, device paths, invoice numbers, Jira keys. `scripts/forbidden-terms.txt` catches the common ones; add to it when you find a new leak.
