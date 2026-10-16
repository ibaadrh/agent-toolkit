Read plugins/<toolkit>/README.md, section "Install alongside".

For each third-party tool listed:
1. Check the repo exists and note the current version or commit and licence. Flag anything with a non-commercial or copyleft licence.
2. Decide: (a) add it to `.claude-plugin/marketplace.json` as a github source so `install.sh` pulls it, or (b) keep it as a documented install line only (MCP servers, npm installs, things that need API keys). Prefer (b) when the tool needs credentials.
3. For (a), add the entry and test `claude plugin marketplace update ibaad-toolkit && claude plugin install <name>@ibaad-toolkit`.
4. For (b), make sure the install line in the README is complete, including which env vars or accounts it needs.
5. Write one paragraph in the toolkit README, "How these fit together", saying which tool is used at which workflow step and which overlapping tools we deliberately skip and why.

Never copy third-party code into this repo. Commit as me: "Document and pin third-party tools for <toolkit>".
