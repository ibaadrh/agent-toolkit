# How to use the toolkit

## On a new machine
```bash
claude plugin marketplace add ibaadrh/agent-toolkit
claude plugin install core@ibaad-toolkit
claude plugin install digital-marketing@ibaad-toolkit     # and any other toolkit you need
```
Then in Claude Code: `/reload-plugins`. Skills appear as `/<toolkit>:<skill>` and also trigger on their own from what you say.

Third-party tools (MCPs, npm skills) are installed separately. Each toolkit README has the exact lines.

## In a product or client repo
1. Create `.claude/toolkit/` in the repo.
2. Copy the client's files from `agent-clients/clients/<client>/` into it. For a new client, copy `templates/client-config/` and fill it in.
3. Add the "Toolkit config" section to the repo's `AGENTS.md` (see `templates/project-AGENTS.md`). If the repo has no `CLAUDE.md`, copy `templates/project-CLAUDE.md` in too: it is one line pointing Claude at `AGENTS.md`.
4. Optional, so teammates get the plugins automatically: in the repo's `.claude/settings.json`
```json
{
  "extraKnownMarketplaces": { "ibaad-toolkit": { "source": { "source": "github", "repo": "ibaadrh/agent-toolkit" } } },
  "enabledPlugins": { "core@ibaad-toolkit": true, "digital-marketing@ibaad-toolkit": true }
}
```

## In other agents (Codex, Cursor, Gemini CLI)
The skills themselves are plain SKILL.md folders and work there too. Plugin packaging, hooks and slash commands do not. Install steps per agent: [PORTABILITY.md](PORTABILITY.md).

## In the Claude app (claude.ai or desktop)
1. `./scripts/package-for-claude-ai.sh` makes one zip per skill in `dist/claude-ai/`.
2. Upload the zips you need in Settings → Skills. The script tells you which ones changed since last time.
3. In the Project you are working in, add the client config files as docs named `toolkit/brand.yaml`, `toolkit/ads.yaml`, and so on. The skills look for those names.

## Claude app → GitHub
The Claude app is the sketchpad; GitHub is the record. Skills you start or change in the app live only in your account until you bring them home.

1. **Experiment in the app.** Write a new skill there, or tweak one mid-task. Don't worry about config keys or generic wording yet.
2. **Harvest.** `./scripts/harvest-claude-app.sh` reads the app's synced account skills (`~/.claude/skills/synced/`) and copies every new or changed one into a private inbox: the `<company>-agent-config` repo whose `forbidden-terms.txt` matches the skill's text, otherwise `agent-clients`. A skill that already has an inbox copy stays where that copy is. It skips Anthropic's built-in skills, skills marked done in an `INBOX.md`, and skills that match their inbox copy. It adds or updates the skill's row in that inbox's `INBOX.md` ("pending (harvested <date>, new)" or "changed"), then commits and pushes each repo with that repo's own identity and credentials. It never writes into agent-toolkit. Run it with `--dry-run` first to see the plan. The weekly job below runs it for you.
   - A skill whose inbox copy sits in one repo but whose text matches another company's terms (a multi-client skill that gained a company section) is not copied; the run prints a note. Move those lines, word for word, into that company repo's `_inbox/`, put the rest in the inbox copy, then run `./scripts/harvest-claude-app.sh --accept <skill>` and commit. `raw/<skill>/.harvested` records which app version was harvested, so a stripped or edited inbox copy doesn't count as changed.
3. **Decide.** Each harvested row in `INBOX.md` says "to decide". Most experiments stop there: leave them, or delete the folder and the row.
4. **Finish the keepers in the repo.** Migrate them as usual: generic mechanics into a toolkit skill (`docs/HOW-TO-ADD-A-SKILL.md`), client values into the client's config, then tick the row "✓ done". From then on the harvest skips that skill.
5. **Upload back.** Run `./scripts/package-for-claude-ai.sh` and upload the changed zips (see "In the Claude app" above). The app now runs the finished version, and the next experiment starts from it.

### Weekly harvest (macOS)
`scripts/launchd/com.agent-toolkit.harvest.plist` runs the harvest every Sunday at 18:00, only when the volume that holds the repos is mounted, and logs to `~/Library/Logs/agent-harvest.log`. If the Mac is asleep at 18:00, it runs when it wakes. The plist is a template; install it from the agent-toolkit folder:
```bash
TK="$PWD"; VOL="$(df "$TK" | awk 'NR==2 {print $NF}')"
sed -e "s|__TOOLKIT_DIR__|$TK|g" -e "s|__VOLUME__|$VOL|g" scripts/launchd/com.agent-toolkit.harvest.plist \
  > ~/Library/LaunchAgents/com.agent-toolkit.harvest.plist
launchctl bootstrap "gui/$(id -u)" ~/Library/LaunchAgents/com.agent-toolkit.harvest.plist
```
- Run it once now, to test: `launchctl kickstart "gui/$(id -u)/com.agent-toolkit.harvest"`, then `tail ~/Library/Logs/agent-harvest.log`. If macOS asks whether `sh` may access a removable volume, allow it, or the job can't read the repos.
- See its state and last exit code: `launchctl print "gui/$(id -u)/com.agent-toolkit.harvest" | grep -E 'state|last exit'`.
- After moving the repos or editing the plist: uninstall, then install again.
- Uninstall:
```bash
launchctl bootout "gui/$(id -u)/com.agent-toolkit.harvest"
rm ~/Library/LaunchAgents/com.agent-toolkit.harvest.plist
```

## Day to day
- Say what you want. The skill triggers from its description. If it doesn't, name it: "use static-ad-maker".
- When a skill stops and asks for a config key, give the value and let it write the file. That's the system working.
- When something breaks or you learn a trick, open Claude Code in `agent-toolkit` and paste `prompts/08-learn.md`. Don't fix it only in the chat.

## Updating
- Claude Code: `claude plugin marketplace update ibaad-toolkit` then `claude plugin update <toolkit>@ibaad-toolkit`.
- Claude app: re-run the package script and re-upload the changed zips.

## Push guard
`./scripts/install.sh` turns on a pre-push hook in this checkout (`git config core.hooksPath scripts/hooks`). Before every push it runs `scripts/validate.sh` on the working tree and `scripts/scan-history.sh` on the commits being pushed: every file version (text and binary), commit message and author, against `scripts/forbidden-terms.txt` and every sibling repo's `forbidden-terms.txt`. It also runs `scripts/check-allowlists.py` on the pushed files (any name not in `scripts/allowed-names.txt`, any domain not in `scripts/allowed-domains.txt`, any email, phone number, price, measurement, long ID or date in a skill that is not a listed generic example line), and `scripts/fresh-eyes-review.sh`: a separate agent that has not seen your session reads only the diff and says whether anything could identify a client or borrows a client's style. If any of them finds something, the push is blocked and the hit is printed. These checks do not need to know a client's name, so they protect quick one-off clients too. GitHub Actions runs `validate.sh` on every push to main as well.
- Turn it on without running the whole install: `git config core.hooksPath scripts/hooks`.
- Scan the whole history by hand, for example before making the repo public: `./scripts/scan-history.sh`.
- A hit in a commit that is not pushed yet: fix the file and amend or rebase so the term is gone from every commit, not only from the latest one.
- A new client or company name: add it to that private repo's `forbidden-terms.txt`, never to this repo.
- `git push --no-verify` skips the guard. Never use it on this repo, and never loosen the guard or its lists to get a push through: fix the content.
- The fresh-eyes review needs the `claude` CLI signed in on this machine. Without it, the push is blocked.

## Giving someone else access
- Toolkit only: add them as a read collaborator on `agent-toolkit`. They run the install lines above.
- A client's config too: add them to `agent-clients` only if they work on that client.
