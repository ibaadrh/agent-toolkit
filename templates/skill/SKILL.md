---
name: skill-name-here
description: One or two sentences. Say exactly when the agent should use this (the trigger) and what it produces. Max 1024 characters. No client names.
---

# Skill name

One paragraph: what this skill does and the result it hands back.

## Config
This skill needs: `brand.yaml` (keys: `brand.name`, `brand.colors.primary`), `ads.yaml` (keys: `thresholds.*`).
Look in this order (full rules in `core/client-config`):
1. `.claude/toolkit/` in the current project.
2. The path under "Toolkit config" in the project's AGENTS.md (or CLAUDE.md).
3. Claude app: Project docs named `toolkit/brand.yaml`, `toolkit/ads.yaml`.
4. Missing a file or a key: stop, say which one, ask for the value, offer to write the file. Never guess.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/house-report` for the final report
- (list the core skills or references this depends on)

## Inputs
What the user gives you, or what you read (a brief, a folder, a URL).

## Steps
1. Numbered. One action per step. Name the action ("run JavaScript in the browser page"), never a platform tool name.
2. Quality gates in bold: **stop if X**.
3. ...

## Output
Exactly what is handed back (files, IDs, text) and where it goes.

## Known failures
- Symptom → cause → fix. Add to this list every time the skill breaks.

## References
- `references/<file>.md` for long material (prompt libraries, layout specs, rubrics). Keep SKILL.md under 500 lines.
