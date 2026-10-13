---
name: client-config
description: How every toolkit skill finds and reads the client's config files (brand.yaml, ads.yaml, meta.yaml, voice.yaml, product-spec.md and the rest), what counts as missing, and what to do then. Read it at the start of any skill run that needs client details, whenever a config file or key cannot be found, and before writing or changing a config file.
---

# Client config

Skills never hold client details. They read them from small config files, one set per client or product. This skill is the one set of rules for finding those files, reading them, and stopping cleanly when something is missing. The result is a list of the values the calling skill asked for, or a clear stop that names the missing file and key.

## Config
This skill needs: none itself. It serves the files and keys that the calling skill lists in its own Config block.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/platform-adapters` for "ask the user a question", "read a project doc" and "write a project doc"
- `core/house-report` to list missing keys at the end of a run

## Inputs
The calling skill's Config block: the files it needs and the keys it reads from each. The file schemas are in `templates/client-config/` in the toolkit repo. Keys are fixed: skills read them by name, and keys are added, never renamed.

## Steps
1. **Find the folder.** Look in this order and use the first place that has the file:
   1. `.claude/toolkit/` in the current project folder. Any agent can read it; the name is only a convention.
   2. The path written under "Toolkit config" in the project's `AGENTS.md` (or `CLAUDE.md`).
   3. In the Claude app: Project docs named `toolkit/<file>`, for example `toolkit/brand.yaml`. Read them with "read a project doc".
2. **Say which copy you used** when a file exists in more than one place. The first place in the order wins. Never merge two copies.
3. **Read the files fresh every run.** Never take an ID, path or value from memory or from an earlier conversation. If you remember a different value than the file holds, the file wins.
4. **Read only the keys the calling skill lists.** Do not go looking for extra values to use.
5. **Treat placeholders as missing.** An empty string, `0` for an amount or an ID, `[]` and `{}` are the template's "not filled in". A spend cap of `0` is not a cap of zero; it is a missing value.
6. **Treat filled-in defaults as defaults.** Numeric doctrine in the templates (for example `min_impressions_per_cell: 300`) is a working default. Use it, and when a decision rests on it, say it is the template default rather than a value the client set.
7. **Check paths before you use them.** For every path key (`drive.root`, `drive.outputs`, `studio.*`, any `*_dir`), check that the folder exists. External drives get unmounted and folders get moved. If it is not there, stop that step and name the key and the path.
8. **Follow the route the config gives.** If `drive.route` says the folder is reached through the user's machine, do not search the Drive connector for it, and the other way round. A connector signed in to a different account will never find it. If `drive.route` is empty, ask which route to use before searching either one.
9. **Resolve handles every run.** Some keys hold a stable handle that points to something that changes, such as a share link to a design file. Resolve the handle at the start of each run. Never write the resolved ID back into the config.
10. **Keep live state out of config.** Config holds facts that rarely change (account IDs, brand colours, paths, thresholds). The live documents named under `docs.*` hold what changes run to run (current campaign IDs, the active test). Read those documents for current state. Never copy their values into a config file.
11. **When a file or key is missing:**
    1. Say which file and which key, and in one line what it is for.
    2. Ask the user for the value ("ask the user a question").
    3. Offer to write it into the file (see step 12).
    4. If nobody can answer (a scheduled or unattended run): skip only the steps that need the value, finish the rest, and list every missing key in the report.
    5. Never guess. Never borrow a value from another client's config, from an example, or from a past run.
12. **When writing a config file:**
    1. Write only the keys the user gave you. Keep every other key, its value and its comment.
    2. Use the key names from `templates/client-config/`. If a skill needs a key the template does not have, add it to the template in the toolkit repo as well.
    3. Never write secrets (passwords, tokens, API keys, keystore passwords). A config holds the path to a secret at most.
    4. In the Claude app, file tools cannot write into a `.claude/` folder. Show the user the YAML block and say where it goes: the project folder, or a Project doc named `toolkit/<file>` ("write a project doc").

## Output
Either the values the calling skill asked for, with the file each came from, or a stop that names every missing file and key. For a brand-new client: copy `templates/client-config/` into the private config repo under `clients/<client>/`, fill it in, then copy it into `<project>/.claude/toolkit/`.

## Known failures
- **An ID taken from memory pointed at the wrong object.** Cause: working from a remembered ID instead of the live file. Fix: read the config and the live documents fresh at the start of every run (step 3).
- **A design ID copied from a past run stopped working.** Cause: the design file behind a share link changed. Fix: keep the share link in config and resolve it every run (step 9).
- **A path in config no longer existed.** Cause: the folder was moved to another drive, or the external drive was unmounted. Fix: check the path first and stop with the key name (step 7). Update the config only once the user confirms the new place.
- **A search for a client folder found nothing and wasted the run.** Cause: the Drive connector was signed in to a different account than the one that owns the folder. Fix: follow `drive.route` and never search the other route (step 8).
- **A config change was lost in the Claude app.** Cause: file tools there cannot write into `.claude/`. Fix: hand the user the YAML block to paste (step 12.4).
- **A `0` was read as a real limit.** Cause: a template placeholder was left in place. Fix: treat `""`, `0`, `[]` and `{}` as missing (step 5).
- **Two copies of a file disagreed.** Cause: one in the project folder and one as a Project doc. Fix: the first in the lookup order wins, and the report says which file was used (step 2).

## References
- `templates/client-config/README.md` in the toolkit repo: which skill reads which file.
- `docs/SYSTEM.md` section 4: why skills read config instead of holding values.
