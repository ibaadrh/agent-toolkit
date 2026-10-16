Run this on your Mac in a terminal, not in Claude Code (it needs your GitHub login).

```bash
# 1. Make sure gh is logged in to your PERSONAL account
gh auth status || gh auth login
gh api user --jq .login        # must print your personal username
gh auth setup-git              # git pushes then use whichever account `gh auth switch` made active

# 2. Create the two private repos
cd ~/code                      # or wherever you keep your repos
unzip -q ~/Downloads/agent-toolkit.zip   # the scaffold you downloaded (skip if already unzipped here)
cd agent-toolkit
git init -b main
git config user.name "Ibaad Rahman"
git config user.email "88559161+ibaadrh@users.noreply.github.com"
git add -A && git commit -m "Scaffold the toolkit"
gh repo create ibaadrh/agent-toolkit --private --source=. --push

cd ..
mkdir agent-clients && cd agent-clients && git init -b main
git config user.name "Ibaad Rahman"; git config user.email "88559161+ibaadrh@users.noreply.github.com"
mkdir -p clients personal
cp -r ../agent-toolkit/templates/client-config clients/_template
printf "# agent-clients\n\nPrivate. Client configs and personal skills for agent-toolkit. Never public.\n" > README.md
git add -A && git commit -m "Start client configs"
gh repo create ibaadrh/agent-clients --private --source=. --push

# 3. Install the toolkit into Claude Code on this machine
cd ../agent-toolkit && ./scripts/install.sh
```

Then open Claude Code inside `agent-toolkit` and paste `01-collect.md`.
