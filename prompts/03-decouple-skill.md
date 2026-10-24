Read AGENTS.md and docs/DECOUPLING-CHECKLIST.md.

Decouple `../agent-clients/_inbox/raw/<skill-name>` into:
- a generic skill at `plugins/<toolkit>/skills/<generic-name>/` (names per docs/SYSTEM.md section 5)
- client config at `../agent-clients/clients/<client>/` (create or extend the YAML files from templates/client-config/)

Rules:
1. Every mechanic that core already owns becomes one line: "Use core/<module>." Do not duplicate it.
2. Every value that is about this client (names, IDs, paths, colours, dimensions, docs, people, dates) moves to the config file. The skill reads it by key. Say the key in the Config block.
3. Sort every rule into (a) a neutral mechanic, or the author's own doctrine, method or quality bar (goes into the toolkit, values marked "default; a client's config can override"), or (b) this client's style, preference, format, data or example (stays private, as the client's settings or their own skill). If unsure, treat it as (b) and list it.
4. If the raw skill depends on a playbook doc in `../agent-clients/_inbox/playbooks/`, split that doc the same way: generic parts into `references/`, client parts into config or `agent-clients/clients/<client>/docs/`.
5. Write the "Known failures" section from the raw skill's gotchas. These are the most valuable lines.
6. Test on paper: read the new SKILL.md as if for a brand-new client with an empty config. Does every step still make sense? If a step only works for the old client, fix it.
7. Update the toolkit README skill table (status → done) and `../agent-clients/_inbox/INBOX.md`. Move the raw skill to `../agent-clients/_inbox/_migrated/`.
8. `./scripts/validate.sh` must pass. Commit in both repos as me: "Add <generic-name>" in the toolkit (no client or skill names in the message) and "Add <client> config for <generic-name>" in the private repo.
9. The report ends with a "kept private" list: what was left out of the toolkit, where it went, and why.

Start with: <skill-name>.
