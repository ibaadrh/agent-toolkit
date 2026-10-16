# Working with agents

How to get real work out of an AI agent on a real project. For the person, not the agent. Short on purpose.

## 1. Brief it like a peer
Give it what you would give a capable colleague on their first day on the task:
- **The goal**, and why it matters.
- **What done looks like.** "The tests pass and the README shows the new command", not "improve the docs".
- **Where things are:** the repo, the files, the doc with the decision in it.
- **Constraints:** what must not change, which account to use, deadlines.
- **What you already tried**, and the exact error text if there is one. Paste it; do not describe it.

Then let it work. Do not dictate every step unless the steps are the point.

## 2. One task per session
A session that does one thing stays sharp. A session that wanders across five things loses track of the first by the fourth. When a task is done, wrap up (`core/wrap-up-session`) and start the next one fresh (`core/resume-session`). Park side ideas instead of chasing them (`core/park-a-note`).

## 3. Plan before big changes
For anything that touches many files, changes structure, or is hard to undo, ask for a plan first: what it will change, in what order, what could go wrong. Read it, correct it, then say go. A five-minute plan review is cheaper than an hour of undoing.

## 4. The agent stops before irreversible actions
It must ask before it deletes, overwrites, force-pushes, rewrites history, sends a message, publishes, spends money, deploys, or changes accounts or permissions. An approval covers that one action, not the next one like it. If you want it to act without asking on a list of things, write the list down (in `AGENTS.md` or the client config), with a date.

## 5. Verify before "done"
"Done" means checked, not written. Ask for the evidence, and expect it unprompted:
- the test or check output, not "tests should pass";
- the file listing that shows the file landed;
- the commit hash and whether it is pushed;
- the screenshot or the rendered page.

Watch for the gap between "I wrote it" and "I ran it". Both are fine; only one is done.

## 6. Keep learnings in the repo, not the chat
The chat is forgotten; the repo is not. When the agent learns something (a gotcha, a better command, your preference), have it written into the skill, `AGENTS.md`, or the session notes, and committed. When you correct the agent, say the rule behind the correction ("never use stream copy for cuts"), so it can be saved as a rule and not repeated as a mistake.

## 7. Review what it hands back
- **Read the diff, not the summary.** Summaries are written to sound finished.
- **Check claims against the repo.** Do the commit, the file and the number it mentions exist?
- **Look for things it made up:** a number with no source, an API that does not exist, a name or incident that was not in the material.
- **Look for scope creep:** changes you did not ask for.
- **Run the riskiest part yourself** once.
- **Ask what it did not check.** A good answer names things.

## 8. Give it the least access that works
One account per repo, the narrowest token, no secrets in the chat. Let it read before it writes.

## Rules a project's AGENTS.md can copy
```
## Working rules
- Ask before anything irreversible: delete, overwrite, force-push, history rewrite, send, publish, spend, deploy, change accounts or permissions. One approval covers one action.
- Plan first for changes that touch many files or are hard to undo. Wait for a go-ahead.
- "Done" means checked. Report the evidence: check output, file listing, commit hash, pushed or not.
- Say what you did not verify. Never invent numbers, names, sources or incidents.
- Stay in scope. Note other ideas with park-a-note instead of acting on them.
- Write learnings into the repo (skill, AGENTS.md or session notes), not only into the chat.
- Start with resume-session and end with wrap-up-session.
```

## What goes wrong
- **Risk: "done" that was only written.** In this toolkit's own build, a test harness reported a failure that turned out to be a bug in the harness; only running it against the real shell showed which side was wrong. Fix: section 5.
- **Risk: confident text with invented details.** While writing this toolkit, early drafts listed "incidents" that the source material only described as rules; a re-read against the sources caught them. Fix: section 7, "look for things it made up".
- **Risk: a long session that drifts.** Fix: section 2.
- **Risk: an approval stretched to cover the next action.** Fix: section 4.
- **Risk: the same correction given every week.** Fix: section 6, write the rule down.
