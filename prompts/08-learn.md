Update the toolkit with a learning.

What happened: <paste the gotcha, the fix, the command that worked, or the thing that failed>

1. Find the one skill or core reference that owns this mechanic. If two could own it, it belongs in core.
2. Add it there: to "Known failures" if it was a failure, to the steps if it changes the procedure. One place only.
3. If the learning is client-specific (their style, format, numbers), it goes in `agent-clients/clients/<client>/` instead, and the skill gets, at most, a generic note.
4. Write it as a generic rule. Never include the client's names, products, numbers, dates, examples or incident stories. Run this prompt only in a session opened in agent-toolkit; from a client session, write the generic suggestion down for the owner instead.
5. Bump the patch version in that plugin's `plugin.json`.
6. Commit as me: "<skill>: <one line>".
