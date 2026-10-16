Release checklist. Do each step and report what you did.

1. `./scripts/validate.sh` passes.
2. Bump `version` in every `plugin.json` whose folder changed since the last tag (`git diff --stat <last-tag> -- plugins/`). Patch for fixes, minor for new skills.
3. Update the skill tables in each toolkit README (status column) and the Status line in the root README.
4. Commit as me and tag: `git tag v<date>` (for example v2026.10.16), push with tags.
5. `./scripts/package-for-claude-ai.sh` and tell me which zips changed so I can upload them in the Claude app.
6. On the second machine, remind me: `claude plugin marketplace update ibaad-toolkit && claude plugin update core@ibaad-toolkit` (repeat per toolkit), then run one skill to confirm.
