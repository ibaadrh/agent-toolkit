# Portability

The toolkit is built for Claude Code first, but the skills themselves work in any agent that reads Agent Skills. This page says what carries over, what does not, and how to install the skills into OpenAI Codex, Cursor and Gemini CLI.

Facts below were checked against each vendor's own docs on 2026-10-16. Sources are listed at the end. Anything marked **(not verified)** could not be confirmed from an official source.

## What is portable

| Part | Why it carries over |
|---|---|
| `SKILL.md` folders (`plugins/<toolkit>/skills/<skill>/`) | They follow the open Agent Skills format from [agentskills.io](https://agentskills.io/specification): a folder with a `SKILL.md` that starts with YAML frontmatter. Required keys: `name` (lowercase letters, digits and hyphens, at most 64 characters, same as the folder name) and `description` (at most 1024 characters). Optional keys: `license`, `compatibility`, `metadata`, `allowed-tools` (experimental). Optional folders: `scripts/`, `references/`, `assets/`. Codex, Cursor and Gemini CLI all read this format natively, with no flag. |
| Client config (YAML in `templates/client-config/`) | Plain files. Any agent can read `.claude/toolkit/brand.yaml`; the folder name is only a convention. |
| `scripts/` inside skills | Plain shell and Python. They run wherever the agent can run a shell command. |
| MCP servers | MCP is an open protocol. The same server (Meta Ads, Shopify, Canva, Drive, Blender) works in every agent. Only the config file differs (table below). |
| `AGENTS.md` | Codex and Cursor read it as is. Gemini CLI reads it once you add it to `context.fileName` (see below). `CLAUDE.md` is a one-line pointer to it. |
| Action names in skills | Skills name actions ("run JavaScript in the browser page"), never tool names. `plugins/core/skills/platform-adapters/` maps each action to each agent's tool. Claude is filled in; the Codex, Cursor and Gemini files are templates to fill as you use them. |

## What is Claude-only

| Part | What to do elsewhere |
|---|---|
| Plugin packaging: `.claude-plugin/marketplace.json`, each `plugin.json`, `claude plugin install` | Install the skill folders directly (below). Cursor and Codex have their own plugin formats; this repo does not ship them yet. |
| Hooks (for example the impeccable hook on UI edits, and the core zsh guard hook) | No equivalent installed. Run the check by hand; the zsh guard has an instruction-based form (see "Using the zsh guard"). |
| Slash commands (`commands/` in a plugin) | Invoke the skill by name instead. Codex: `$skill-name` or `/skills`. Cursor: the `/` menu. Gemini CLI: ask for it by name, or `/skills list`. |
| Sub-agent definitions (`agents/` in a plugin) | Not portable. The skill steps still work run in sequence. |
| The Claude app zip upload (`scripts/package-for-claude-ai.sh`) and Claude app Project docs as config | Claude app only. |
| The attribution setting in `scripts/install.sh` | Claude Code only. Other agents: check their own commit settings. |
| Third-party plugins pinned in the marketplace | Many are plain skills repos. Install them with `npx skills add <owner/repo> -a <agent>` instead, one by one. |

## Install into another agent

All three agents read `~/.agents/skills/` at user level and `.agents/skills/` at project level. That makes one install work for all of them. Symlink each skill folder from a clone of this repo, so a `git pull` updates every agent at once:

```bash
git clone https://github.com/ibaadrh/agent-toolkit.git ~/agent-toolkit
mkdir -p ~/.agents/skills
for d in ~/agent-toolkit/plugins/*/skills/*/; do
  ln -sfn "${d%/}" ~/.agents/skills/"$(basename "$d")"
done
```

Then copy the client config into the project as usual (`<project>/.claude/toolkit/`), and add the "Toolkit config" section from `templates/project-AGENTS.md` to the project's `AGENTS.md`.

### OpenAI Codex (CLI)
- Skills on by default since 0.76.0. `.agents/skills` loading since 0.94.0, `~/.agents/skills` since 0.95.0 (the old `~/.codex/skills` still works).
- Folders: user `~/.agents/skills`; project `.agents/skills` in every folder from the working directory up to the repo root; admin `/etc/codex/skills`. Symlinks are followed.
- Install: the symlink loop above. To install from GitHub instead: `npx skills add ibaadrh/agent-toolkit -a codex -g` **(not verified for this repo: the repo is private, and the skills CLI has not been tested against the `plugins/*/skills/*` layout)**.
- Use: `$skill-name`, or `/skills` to pick one.
- `AGENTS.md`: read by default, from the git root down to the working directory.
- MCP: `[mcp_servers.<name>]` tables in `~/.codex/config.toml`, or `codex mcp add <name> -- <command>`.

### Cursor (editor and the `agent` CLI)
- Skills in the editor and CLI since Cursor 2.4.
- Folders: user `~/.agents/skills/` and `~/.cursor/skills/`; project `.agents/skills/` and `.cursor/skills/`. Cursor also reads `~/.claude/skills/` and `.claude/skills/`.
- Cloud Agents only get `~/.cursor/skills/`. If you use them, run the symlink loop with `~/.cursor/skills` as the target as well.
- Install: the symlink loop above. There is no documented command to install a skill from GitHub; plugins with a `.cursor-plugin/marketplace.json` are the other route.
- `AGENTS.md`: read in the project root and subfolders. The CLI also reads `CLAUDE.md`.
- MCP: `mcpServers` in `~/.cursor/mcp.json` (global) or `.cursor/mcp.json` (project). The CLI uses the same file.

### Gemini CLI
- Skills on by default since v0.25.0.
- Note: Google says Gemini CLI was replaced by Antigravity CLI on 18 June 2026 for unpaid-tier and Google One users. Antigravity's skills folder is **(not verified)** from Google's docs.
- Folders: user `~/.gemini/skills/` or `~/.agents/skills/`; workspace `.gemini/skills/` or `.agents/skills/`. Workspace skills need a trusted workspace (`/trust`).
- Install: the symlink loop above, or one skill at a time: `gemini skills install <git-url-or-folder> --scope user --path <subfolder>`. `gemini skills list --all` shows what loaded; `/skills reload` picks up changes in a session.
- `AGENTS.md`: not read by default (Gemini reads `GEMINI.md`). Add it in `~/.gemini/settings.json`:
  ```json
  { "context": { "fileName": ["AGENTS.md", "GEMINI.md"] } }
  ```
- MCP: `mcpServers` in `~/.gemini/settings.json` or `.gemini/settings.json`, or `gemini mcp add <name> <command>`.

## After installing
1. Open `plugins/core/skills/platform-adapters/references/<agent>-tools.md` and fill in tool names as you meet them. A skill that reaches an empty cell stops and says which action it needs.
2. Add the MCP servers the toolkit uses (Meta Ads, Shopify, Canva, Drive) to the agent's MCP config. They need the same keys or logins as in Claude.

## Using the zsh guard
The guard is a plain script, `plugins/core/skills/shell-safety-guard/scripts/zsh-guard.py` (Python 3.8+, standard library only). Only its Claude Code hook (`plugins/core/hooks/`) is Claude-only.

- **Any agent, by instruction.** Add this line to the project's `AGENTS.md`: "On a machine whose shell is zsh, check every shell command with `python3 <toolkit>/plugins/core/skills/shell-safety-guard/scripts/zsh-guard.py -` (command on standard input) before running it. Exit 1 means rewrite it with the printed fix." This works in any agent that reads `AGENTS.md`, but it relies on the agent following the rule.
- **Any agent with a pre-command hook.** Call the script with the command on standard input and refuse the command when it exits 1. Codex, Cursor and Gemini CLI hook support was not checked for this page **(not verified)**; check the agent's own docs.
- **By hand or in CI.** `python3 zsh-guard.py '<command>'`, exit 0 or 1. `python3 test_zsh_guard.py` checks the guard against a real zsh.

## Not verified
- Installing this repo with `npx skills add` (private repo, nested `plugins/*/skills/*` layout).
- Antigravity CLI skills folders.
- Whether Gemini CLI still accepts the old top-level `contextFileName` setting (the docs only show `context.fileName`).
- The Cursor version that added `~/.agents/skills/` and the `.claude/skills/` compatibility folders.
- A Cursor CLI command to install a skill (none is documented).

## Sources
- Agent Skills spec and supported agents: https://agentskills.io/specification, https://agentskills.io/
- Codex skills: https://learn.chatgpt.com/docs/build-skills (formerly developers.openai.com/codex). Releases: https://github.com/openai/codex/releases/tag/rust-v0.76.0, https://github.com/openai/codex/releases/tag/rust-v0.94.0, https://github.com/openai/codex/releases/tag/rust-v0.95.0
- Codex AGENTS.md and MCP: https://learn.chatgpt.com/docs/agent-configuration/agents-md, https://learn.chatgpt.com/docs/extend/mcp?surface=cli
- Cursor skills: https://cursor.com/docs/context/skills, https://cursor.com/changelog/2-4. Rules and AGENTS.md: https://cursor.com/docs/context/rules. CLI: https://cursor.com/docs/cli/using.md. MCP: https://cursor.com/docs/context/mcp
- Gemini CLI skills: https://geminicli.com/docs/cli/skills/, https://geminicli.com/docs/cli/tutorials/skills-getting-started. Context files: https://geminicli.com/docs/cli/gemini-md/. MCP: https://geminicli.com/docs/tools/mcp-server/. Changelog: https://geminicli.com/docs/changelogs/
- skills CLI agent IDs and folders: https://github.com/vercel-labs/skills (src/agents.ts)
