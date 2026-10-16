# Prompts

Each file is a prompt you paste into Claude Code, in order. Open Claude Code inside the `agent-toolkit` repo first (`cd agent-toolkit && claude`), unless the prompt says otherwise.

| # | Prompt | When |
|---|---|---|
| 00 | setup | Once. Creates the GitHub repos and installs the marketplace. |
| 01 | collect | Once. Gathers every skill, CLAUDE.md and playbook you have into `../agent-clients/_inbox/`. |
| 02 | build-core | Once per batch of 3–4 core modules. |
| 03 | decouple-skill | Once per skill. The main migration step. |
| 04 | adopt-third-party | Once per toolkit. |
| 05 | write-workflow | Once per toolkit. |
| 06 | new-skill | Whenever you write a skill that didn't exist before. |
| 07 | publish | Each release. |
| 08 | learn | Any time a skill teaches you something. |
| 09 | review | Monthly. |
