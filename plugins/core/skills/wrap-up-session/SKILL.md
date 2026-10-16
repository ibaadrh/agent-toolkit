---
name: wrap-up-session
description: End a session by appending a short note to the project's session notes file, saying what was done, what is still open and the one next step, written so a cold session (or another person or agent) can pick it up. Use it when the user says "wrap up", "let's stop here", "write it down for next time", "end of session", or before a long break in the work.
---

# Wrap up a session

The value of a session is lost if the next one cannot tell what happened. This skill writes it down in one short, checked entry in the project's notes file. The result is an entry that someone with no context can act on.

## Config
This skill needs: `brand.yaml` (keys: `docs.session_notes`, optional).
Find the notes file in this order: `docs.session_notes` (see `core/client-config`); a line starting "Session notes:" in the project's `AGENTS.md` (or `CLAUDE.md`); `SESSION-NOTES.md` at the repository root (or the current folder). If the file does not exist, create it with the heading `# Session notes`.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the notes path
- `core/house-report` for check-before-claim and exact identifiers

## Steps
1. **Collect what was done**, from this session: the changes made, the commits (with their short hashes), files delivered, decisions taken.
2. **Check it before writing it.** Look at the repo: are the commits there, are they pushed, are there uncommitted changes? Write only what you checked. "Pushed" only if the branch matches its remote.
3. **Collect what is open:** unfinished items, uncommitted changes, failing checks, questions waiting for the user, anything parked in this session.
4. **Pick one next step.** Concrete enough to start without asking ("Run the decoupling checklist on the static ad maker"), not a theme ("continue migration").
5. **Append the entry** at the end of the file. Never rewrite or delete earlier entries.
   ```
   ## <YYYY-MM-DD HH:MM> <short title>
   **Done:** <what was done, with commit hashes and file paths>
   **Open:** <numbered list, or "nothing">
   **Next:** <one step>
   ```
   Ten lines at most. Write for a reader with no context: no "as discussed", no "the thing from earlier"; name the files and commits.
6. **Keep it clean.** No secrets, tokens or passwords. In a repository with a forbidden-terms check (like this toolkit), the notes follow the same rules; run the check after writing.
7. **Do not commit unless asked.** Leave the notes file as a change and say so, or commit it if the user asks.
8. **Report** the path of the notes file and the entry you wrote.

## Output
One new entry at the end of the notes file, and a two-line report: where it is and what it says is next.

## Known failures
- **Risk: an entry that only makes sense with the conversation open.** Fix: name files, commits and decisions (step 5).
- **Risk: claiming work is pushed or finished when it is not.** Fix: check the repo first (step 2).
- **Risk: a vague next step**, so the next session spends its first half hour working out what to do. Fix: one concrete step (step 4).
- **Risk: client data in a notes file inside a generic repo.** Fix: the forbidden-terms check (step 6).
- **Risk: rewriting history.** Editing old entries hides what was true then. Fix: append only.

## References
- `core/resume-session` reads these entries; `core/park-a-note` adds single dated lines between them.
