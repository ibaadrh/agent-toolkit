# Claude: action → tool

Two Claude surfaces, two columns:
- **Claude Code**: the CLI, the IDE extensions and Claude Code on the web.
- **Claude app**: claude.ai and Claude Desktop, with the built-in browser and the remote-devices bridge.

How names are built:
- Claude Code shows claude.ai connectors as `mcp__claude_ai_<Connector>__<tool>`, for example `mcp__claude_ai_Meta_Ads__ads_library_search`. An MCP server you added yourself shows as `mcp__<server-name>__<tool>`. The tables below give the `<tool>` part for connectors and say the prefix once per section.
- The Claude app shows connector tools by their bare name (`ads_library_search`).
- Browser tools in the Claude app come from the built-in browser: `mcp__Claude_Browser__<tool>`, or `mcp__remote-devices__Claude_Browser__<tool>` when the browser runs on a connected device. In Claude Code they come from the Claude in Chrome extension: `mcp__claude-in-chrome__<tool>`.

"(not verified)" means the name has not been checked in a live session yet. Check it the first time and remove the mark.

## Agent basics

| Action | Claude Code | Claude app |
|---|---|---|
| ask the user a question (with choices) | `AskUserQuestion` | none; ask in a normal reply (not verified) |
| spawn a sub-agent | `Agent` (older versions: `Task`) | none; do the work in sequence |
| run another skill | `Skill` | none; skills load from their description (not verified) |
| find files in the workspace | `Glob` (names) or `Grep` (contents) | none; use the shell (`find`, `grep`) |
| load a tool that is not loaded yet | `ToolSearch` (`select:<name>` or a name prefix) | `ToolSearch` |
| search the web | `WebSearch` | `web_search` |
| fetch a web page | `WebFetch` | `web_fetch` |
| read a project doc | none; project docs are files in the repo, read them directly | the Projects tool (name not verified) |
| write a project doc | none; write the file in the repo | `project_write` (seen in raw skills; not verified live) |

## Files and the user's machine

| Action | Claude Code | Claude app |
|---|---|---|
| run a shell command in the working area | `Bash` (the working area is the project folder) | the sandbox shell (name not verified) |
| run a shell command on the user's machine | `Bash` | `device_bash` (calls end when they return; nothing runs in the background) |
| list a folder on the user's machine | `Bash` (`ls`) | `device_list_dir` |
| ask for access to a folder on the user's machine | none; ask the user | `device_request_folder_access` |
| copy a file from the user's machine into the working area | `Read` or `Bash` (`cp`) | `device_stage_files` |
| write file to device | `Write` (or `Bash` `mv`) | `device_commit_files` (needs the file's fileUuid from "deliver the file to the user"; at most 30 MB per file) |
| deliver the file to the user | none; write it to the agreed folder and print the absolute path | copy the file into `/mnt/user-data/outputs` first, then `SendUserFile` (returns a fileUuid) |

## Browser

| Action | Claude Code (`mcp__claude-in-chrome__` prefix) | Claude app (`mcp__Claude_Browser__` prefix) |
|---|---|---|
| open a URL in the browser | `navigate` | `navigate` |
| resize the browser window | `resize_window` (not verified in Claude Code) | `resize_window` with `width`/`height`; `preset: "desktop"` to restore |
| run JavaScript in the browser page | `javascript_tool` | `javascript_tool` (about 45 s per call) |
| take a screenshot of the browser page | `computer` with `action: "screenshot"` | `computer` with `action: "screenshot"` |
| click, type or scroll in the browser page | `computer` | `computer` |
| find an element on the page | `find` | `find` |
| fill a form field | `form_input` | `form_input` |

## Google Drive (connector prefix in Claude Code: `mcp__claude_ai_Google_Drive__`)

| Action | Tool |
|---|---|
| search Drive | `search_files` |
| read a Drive file as text | `read_file_content` |
| download a Drive file (binary, base64) | `download_file_content` |
| read a Drive file's metadata (title, link) | `get_file_metadata` |
| create a Drive file | `create_file` |

## Meta Ads (connector prefix in Claude Code: `mcp__claude_ai_Meta_Ads__`)

| Action | Tool |
|---|---|
| search the Meta Ads Library | `ads_library_search` |
| list ad accounts | `ads_get_ad_accounts` |
| read campaigns, ad sets and ads | `ads_get_ad_entities` |
| read performance over time | `ads_insights_performance_trend` |
| create a campaign | `ads_create_campaign` |
| create an ad set | `ads_create_ad_set` |
| upload ad media | `ads_creative_upload_media` |
| create an ad creative | `ads_create_creative` |
| create an ad | `ads_create_ad` |
| preview an ad | `ads_get_ad_preview` |
| activate an ad, ad set or campaign | `ads_activate_entity` |
| change an ad, ad set or campaign | `ads_update_entity` |
| read delivery errors | `ads_get_errors` |
| read the account activity log | `ads_account_get_activity_logs` |

## Shopify (connector prefix in Claude Code: `mcp__claude_ai_Shopify__`)

| Action | Tool |
|---|---|
| look up the Shopify GraphQL schema | `graphql_schema` |
| run a Shopify GraphQL query | `graphql_query` |
| run a Shopify GraphQL mutation | `graphql_mutation` (staged uploads are mutations: `stagedUploadsCreate`, then `fileCreate`) |

## Canva (connector prefix in Claude Code: `mcp__claude_ai_Canva__`)

| Action | Tool |
|---|---|
| resolve a Canva share link to a design | `resolve-shortlink` |
| search Canva designs | `search-designs` |
| read a Canva design (pages, elements, geometry) | `read-design` |
| edit a Canva design (add a page, add or format text) | `edit-design` |
| upload an asset to Canva from a URL | `upload-asset-from-url` |
| list Canva assets | `get-assets` |
| create a Canva design from a brand template | `create-design-from-brand-template` |
| export a Canva design | `export-design` |

## Email

| Action | Claude Code | Claude app |
|---|---|---|
| draft an email (Gmail) | `mcp__claude_ai_Gmail__create_draft` | `create_draft` |
| send an email (Zoho Mail) | `mcp__claude_ai_ZohoMCP__ZohoMail_sendEmail` | `ZohoMail_sendEmail` |
