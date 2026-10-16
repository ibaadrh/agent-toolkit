---
name: park-a-note
description: Append one dated line to the project's session notes file so an idea, a to-do or a loose end is not lost, without stopping the current work or ending the session. Use it when the user says "park this", "note that for later", "remind me to", "add to the list", or mentions something worth keeping that is not part of the current task.
---

# Park a note

Ideas and loose ends come up mid-task. Acting on them derails the work; ignoring them loses them. This skill writes one line and goes straight back to the task. The result is a dated line in the notes file that the next `resume-session` will show.

## Config
This skill needs: `brand.yaml` (keys: `docs.session_notes`, optional).
Find the notes file in this order: `docs.session_notes` (see `core/client-config`); a line starting "Session notes:" in the project's `AGENTS.md` (or `CLAUDE.md`); `SESSION-NOTES.md` at the repository root (or the current folder). If the file does not exist, create it with the heading `# Session notes`.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the notes path

## Steps
1. **Write the note in one line**, in the user's words where possible, specific enough to act on later. Name the file or thing it is about.
2. **Append it** at the end of the notes file:
   `- <YYYY-MM-DD HH:MM> parked: <the note>`
   Never edit or reorder other lines.
3. **Confirm in one line** ("Parked: <the note>") and go back to the task that was running. Do not start on the parked item, even if it looks quick.
4. **Keep it clean:** no secrets; in a repository with a forbidden-terms check, the same rules apply.

## Output
One new line at the end of the notes file, and a one-line confirmation.

## Known failures
- **Risk: the parked item quietly becomes the current task.** Fix: step 3; it waits for the user or the next session.
- **Risk: a note too vague to act on** ("fix the thing"). Fix: name what it is about (step 1).

## References
- `core/resume-session` shows parked lines at the start of the next session.
