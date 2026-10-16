Read AGENTS.md, docs/SYSTEM.md section 5 "core", and plugins/core/README.md.

Build these core modules now: <list 3–4, e.g. house-report, brief-contract, ai-image-prompting, file-delivery>.

For each module:
1. Read every raw skill in `../agent-clients/_inbox/raw/` that contains that mechanic (the core README says which).
2. Write it once under `plugins/core/skills/<module>/` using `templates/skill/SKILL.md`. Keep every concrete detail that makes it work: exact selectors, commands, numbers, failure cases. Move anything over ~80 lines into `references/`.
3. Replace all client specifics with config keys and say which key in the Config block. Check against `scripts/forbidden-terms.txt`.
4. Add a row to plugins/core/README.md if it isn't there.
5. In `../agent-clients/_inbox/INBOX.md`, note which raw skill sections are now covered by this module.

Then run `./scripts/validate.sh`, fix anything it flags, and commit as me: "Add core: <modules>".
Do not touch the domain plugins in this session.
