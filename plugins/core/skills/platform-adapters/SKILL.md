---
name: platform-adapters
description: Maps the actions that toolkit skills name (run JavaScript in the browser page, deliver the file to the user, search the Meta Ads Library, ask the user a question) to the tool names of the agent you are running in. Read it whenever a skill step names an action and you do not know which of your tools performs it, or when you add a skill to a new agent platform.
---

# Platform adapters

Toolkit skills never name a platform's tools. A step says what to do ("run JavaScript in the browser page"), not which tool to call. This skill holds the one place where actions meet tool names, one file per agent platform.

## Config
This skill needs: none.

Tools: this skill is the tool-name table. No other skill names a tool.

## When to read it
- A skill step names an action and you are not sure which of your tools does it.
- You are writing or decoupling a skill and want the action wording for a tool you know.
- You are adding the toolkit to a new agent platform.

## Steps
1. Work out which agent you are running in.
2. Open the matching file in `references/`:
   - Claude (Claude Code, the Claude app, Claude Desktop): `references/claude-tools.md`
   - OpenAI Codex: `references/codex-tools.md`
   - Cursor: `references/cursor-tools.md`
   - Gemini CLI: `references/gemini-tools.md`
3. Find the action in the first column. Use the tool in the second column.
4. **Stop if the tool cell is empty.** Look at the tools you do have. If one clearly does the action, use it and fill in the cell in the repo. If none does, tell the user which action the skill needs and that this platform has no tool for it. Do not pretend the step ran.
5. A tool can need loading first (some agents only list deferred tools by name). The "load a tool that is not loaded yet" row says how.

## Adding an action
1. Name it as a plain verb phrase a stranger understands. No tool names, no platform words.
2. Add the row to every file in `references/`, in the same place. Fill the tool cell only where you have checked it.
3. Write the action, word for word, in the skill that needs it.

## Known failures
- A skill names a tool directly → it breaks on every other agent. Replace the name with the action and add the row here. `scripts/validate.sh` fails on the common tool names outside this folder.
- A connector is not connected in this session → the tool is missing even though the table names it. Ask the user to connect it, then continue.

## References
- `references/claude-tools.md`, `references/codex-tools.md`, `references/cursor-tools.md`, `references/gemini-tools.md`
