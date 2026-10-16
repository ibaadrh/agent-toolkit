Open plugins/<toolkit>/WORKFLOW.md. It is an outline. Turn it into the real playbook.

Write it for someone who has never done this with Claude before. For each step:
- what you are trying to find out or produce
- which skill or tool does it (ours or third-party), with the exact phrase to say to Claude to start it
- what good output looks like (a short example)
- the one mistake people make at this step
- when to stop and ask a human

Pull the concrete details from the migrated skills in this toolkit; don't invent new mechanics. Keep it under 300 lines; longer material goes into `docs/` inside the plugin. Plain English, short sentences, no em dashes. Add a 10-line "Quick start" at the top for the common case.

Commit as me: "Write <toolkit> workflow".
