# OpenAI Codex: action → tool

Template. The action column matches `claude-tools.md` row for row. Fill a tool cell only after checking the name in a live Codex session, and put the check date in the notes column.

An empty cell means: not mapped yet. A skill that reaches an empty cell stops and tells the user (see the platform-adapters SKILL.md, step 4).

## Agent basics

| Action | Tool | Notes |
|---|---|---|
| ask the user a question (with choices) |  |  |
| spawn a sub-agent |  |  |
| run another skill |  |  |
| find files in the workspace |  |  |
| load a tool that is not loaded yet |  |  |
| search the web |  |  |
| fetch a web page |  |  |
| read a project doc |  |  |
| write a project doc |  |  |

## Files and the user's machine

| Action | Tool | Notes |
|---|---|---|
| run a shell command in the working area |  |  |
| run a shell command on the user's machine |  |  |
| list a folder on the user's machine |  |  |
| ask for access to a folder on the user's machine |  |  |
| copy a file from the user's machine into the working area |  |  |
| write file to device |  |  |
| deliver the file to the user |  |  |

## Browser

| Action | Tool | Notes |
|---|---|---|
| open a URL in the browser |  |  |
| resize the browser window |  |  |
| run JavaScript in the browser page |  |  |
| take a screenshot of the browser page |  |  |
| click, type or scroll in the browser page |  |  |
| find an element on the page |  |  |
| fill a form field |  |  |

## Google Drive

| Action | Tool | Notes |
|---|---|---|
| search Drive |  |  |
| read a Drive file as text |  |  |
| download a Drive file (binary, base64) |  |  |
| read a Drive file's metadata (title, link) |  |  |
| create a Drive file |  |  |

## Meta Ads

| Action | Tool | Notes |
|---|---|---|
| search the Meta Ads Library |  |  |
| list ad accounts |  |  |
| read campaigns, ad sets and ads |  |  |
| read performance over time |  |  |
| create a campaign |  |  |
| create an ad set |  |  |
| upload ad media |  |  |
| create an ad creative |  |  |
| create an ad |  |  |
| preview an ad |  |  |
| activate an ad, ad set or campaign |  |  |
| change an ad, ad set or campaign |  |  |
| read delivery errors |  |  |
| read the account activity log |  |  |

## Shopify

| Action | Tool | Notes |
|---|---|---|
| look up the Shopify GraphQL schema |  |  |
| run a Shopify GraphQL query |  |  |
| run a Shopify GraphQL mutation |  |  |

## Canva

| Action | Tool | Notes |
|---|---|---|
| resolve a Canva share link to a design |  |  |
| search Canva designs |  |  |
| read a Canva design (pages, elements, geometry) |  |  |
| edit a Canva design (add a page, add or format text) |  |  |
| upload an asset to Canva from a URL |  |  |
| list Canva assets |  |  |
| create a Canva design from a brand template |  |  |
| export a Canva design |  |  |

## Email

| Action | Tool | Notes |
|---|---|---|
| draft an email (Gmail) |  |  |
| send an email (Zoho Mail) |  |  |
