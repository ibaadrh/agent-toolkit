---
name: resume-session
description: Start a session on an existing project by reading its state and the last session notes, then saying in a few lines where things stand and what the next step is, before doing any work. Use it when the user says "resume", "where were we", "pick up where we left off", "what's next on this", or opens a new session on a project that has a session notes file.
---

# Resume a session

A new session starts cold. This skill rebuilds the picture from what is written down (the session notes, the repo, the live documents) instead of from memory, checks the notes against the repo, and proposes the next step. The result is a short status the user can confirm or correct before any work starts.

## Config
This skill needs: `brand.yaml` (keys: `docs.session_notes`, `docs.live_state`, both optional).
Find the notes file in this order:
1. `docs.session_notes` (see `core/client-config`).
2. A line starting "Session notes:" in the project's `AGENTS.md` (or `CLAUDE.md`).
3. `SESSION-NOTES.md` at the repository root (or the current folder outside a repository).

No notes file: say so, rebuild the status from the repo alone (step 3), and mention that `wrap-up-session` will start one.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the notes path
- `core/house-report` for the shape of the status

## Steps
1. **Find and read the notes file.** Read the last wrap-up entry and every parked line after it. Older entries only if the last one points to them.
2. **Read the project's rules.** `AGENTS.md` (or `CLAUDE.md`), and the live state document if `docs.live_state` is set.
3. **Read the repo's actual state.** The current branch, uncommitted changes, the last few commits, and whether the branch is ahead of or behind its remote.
4. **Check the notes against the repo.** The repo wins on facts. If the notes say "next: commit the fix" and the fix is already committed, say so. If there are uncommitted changes the notes do not mention, say so; someone may have worked since.
5. **Say where things stand**, in this shape:
   1. One sentence: where the work is.
   2. What is open: unfinished items, parked notes, uncommitted changes, failing checks. Numbered.
   3. The proposed next step: one step, concrete.
   4. Anything that disagrees between the notes and the repo.
6. **Stop and wait.** Ask whether to go ahead with the proposed step. Do not start work, and do not change anything, until the user says so.

## Output
A status of a few lines and one proposed next step. Nothing written, nothing changed.

## Known failures
- **Risk: resuming from memory.** An earlier conversation or a summary can be out of date. Fix: the notes and the repo only (steps 1 to 3).
- **Risk: trusting stale notes.** Work can happen between sessions (another person, another agent, a manual commit). Fix: step 4; the repo wins.
- **Risk: starting work straight away.** The user may have changed their mind since the last session. Fix: step 6.
- **Risk: reading the whole notes history.** It wastes time and buries the current state. Fix: the last entry and what came after it.

## References
- `core/wrap-up-session` writes the entries this skill reads; `core/park-a-note` adds the dated lines.
