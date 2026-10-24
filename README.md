# Agent Toolkit

> **Status: work in progress.** Some toolkits are still being filled in, and skills may change without notice. MIT licensed, see [LICENSE](LICENSE).

My AI agent workflows, packaged as five toolkits that work for any client or product, and with any agent that reads SKILL.md files: Claude Code, the Claude app, Codex, Cursor and Gemini CLI.

Every skill here is generic. Client details (brand, accounts, paths) live in a separate config folder, never inside a skill. Skills name actions, not a platform's tool names; `core/platform-adapters` maps each action to the tools of the agent you use. One install command puts the whole set on any machine.

## The five toolkits

| Toolkit | What it's for | Start here |
|---|---|---|
| [video-production](plugins/video-production/) | Adobe Firefly and Veo generation, Blender product renders, Kdenlive and ffmpeg editing, the studio folder system | [README](plugins/video-production/README.md) · [WORKFLOW](plugins/video-production/WORKFLOW.md) |
| [website-development](plugins/website-development/) | Site cloning, taste-level UI/UX, Wix headless and Shopify builds, SEO and AI-search readiness | [README](plugins/website-development/README.md) · [WORKFLOW](plugins/website-development/WORKFLOW.md) |
| [app-development](plugins/app-development/) | Feature extraction from competitor apps, mobile UI rules, building with Claude Code, Play Store and App Store release | [README](plugins/app-development/README.md) · [WORKFLOW](plugins/app-development/WORKFLOW.md) |
| [engineering-3d-printing](plugins/engineering-3d-printing/) | Functional-first design thinking, CAD, design for printing, Bambu Lab print workflow, ESP32 firmware | [README](plugins/engineering-3d-printing/README.md) · [WORKFLOW](plugins/engineering-3d-printing/WORKFLOW.md) |
| [digital-marketing](plugins/digital-marketing/) | Competitor and ad-library research, low-budget strategy, Meta and Google ads operations, static and video ad production, newsletters | [README](plugins/digital-marketing/README.md) · [WORKFLOW](plugins/digital-marketing/WORKFLOW.md) |

Plus [core](plugins/core/): the shared building blocks every toolkit uses (report format, brief contract, AI image prompting rules, Firefly driver, ffmpeg recipes, delivery, browser hygiene, llm-council).

## Install (Claude Code, any machine)

Inside Claude Code, one line per toolkit:
```
/plugin install core --marketplace ibaadrh/agent-toolkit
/plugin install digital-marketing --marketplace ibaadrh/agent-toolkit
```

Or run everything at once:

```bash
git clone git@github.com:ibaadrh/agent-toolkit.git && cd agent-toolkit && ./scripts/install.sh
```

Add `--with-third-party` to also install the community tools the toolkits rely on. The list, with licences and pinned versions, is in [docs/THIRD-PARTY.md](docs/THIRD-PARTY.md).

## Other agents (Codex, Cursor, Gemini CLI)

The skills are plain [Agent Skills](https://agentskills.io) folders. Copy or link them into the agent's skills folder. Exact steps, and what does not carry over (plugin packaging, hooks, slash commands), are in [docs/PORTABILITY.md](docs/PORTABILITY.md).

## Use it for a product or client

1. Copy a client folder (from the private `agent-clients` repo, or start from `templates/client-config/`) into `<your-project>/.claude/toolkit/`.
2. Open Claude Code in that project. Every skill now knows the brand, accounts and paths.
3. In the Claude app: upload the packaged skills (`scripts/package-for-claude-ai.sh`) and add the config files to the Project as docs named `toolkit/<file>`.

## Read next

- [docs/SYSTEM.md](docs/SYSTEM.md): why it's built this way and the migration plan
- [docs/HOW-TO-USE.md](docs/HOW-TO-USE.md): day-to-day use
- [docs/HOW-TO-ADD-A-SKILL.md](docs/HOW-TO-ADD-A-SKILL.md): adding or changing a skill
- [docs/DECOUPLING-CHECKLIST.md](docs/DECOUPLING-CHECKLIST.md): how to make a client-specific skill generic
- [docs/PORTABILITY.md](docs/PORTABILITY.md): what works in which agent, and how to install it there

## Status

Migration in progress. `../agent-clients/_inbox/INBOX.md` tracks what has moved and what hasn't.
