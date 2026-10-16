We are migrating all my Claude skills into this repo. Read AGENTS.md and docs/SYSTEM.md first.

Step 1: find every Claude Code skill and CLAUDE.md on this machine and copy them into `../agent-clients/_inbox/claude-code/`, keeping a folder per source repo. Run:

```bash
find ~ -maxdepth 6 \( -path '*/node_modules' -o -path '*/Library' -o -path '*/.Trash' \) -prune -o \
  \( -name SKILL.md -o -name CLAUDE.md -o -name AGENTS.md \) -print 2>/dev/null
ls ~/.claude/skills ~/.claude/commands ~/.claude/agents 2>/dev/null
```

If your repos live outside your home folder (an external drive, for example), run the same `find` there too, with no depth limit for `.claude/skills` and `.agents/skills` folders.

For each hit outside this repo: copy it to `../agent-clients/_inbox/claude-code/<repo-name>/<original relative path>`. Do not edit anything. Do not copy secrets (.env, keystores, tokens).

Step 2: the account skills from the Claude app are already in `../agent-clients/_inbox/raw/`. The real prompt libraries for the ad and content skills live in Claude Project docs, not in the skills. I will export them from the Claude app and drop them in `_inbox/playbooks/` of the right config repo (company material goes in that company's config repo, never in agent-clients). The list of docs to export is in that repo's `_inbox/INBOX.md`.
Remind me if they are missing when a later step needs them.

Step 3: update `../agent-clients/_inbox/INBOX.md`: one row per item found, with columns: source, kind (skill / CLAUDE.md / playbook / script), proposed destination (toolkit/skill or agent-clients path), status = pending.

Step 4: commit as me (no co-author trailer): "Collect raw skills and docs into inbox".
