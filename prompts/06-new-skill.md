Use the skill-creator skill. Create `plugins/<toolkit>/skills/<name>/` for: <one sentence: when it triggers and what it produces>.

Before writing:
1. Check `plugins/core` and the other toolkits for anything already covering part of this. Reference it, don't repeat it.
2. Check the third-party tools in the toolkit README. If one already does 80% of this, the skill should wrap it (say when to call it, what to do with its output), not re-implement it.
3. Research the current best practice online for this job and list 3–5 sources in `references/sources.md` with dates. Prefer official docs.

Write with `templates/skill/SKILL.md`. Include a Config block even if empty. Write at least three "Known failures" from the research or from my experience (ask me).

Then test it on a real job: <describe the job>. Fix the skill from what breaks. Add a README row. `./scripts/validate.sh`. Commit as me: "Add <name>".
