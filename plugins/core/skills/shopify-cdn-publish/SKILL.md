---
name: shopify-cdn-publish
description: Host a file at a public URL when the agent cannot put it on the web directly, using a Shopify store's Files as the host. The four-step staged upload (ask for an upload slot, POST the file, register it, wait until it is ready) and why it is needed. Use it when an ad platform, an image generator in a browser page, or any other service needs a public URL for a file that only exists in the agent's working area.
---

# Public file hosting through Shopify Files

Many services only take files by public URL: Meta's ad image upload, a reference image slot in a browser-based image generator, a link in a message. The agent's working area often cannot serve files to the web, the browser page cannot read the local disk, and Drive links are blocked inside other sites. A Shopify store's Files section solves this: the staged upload works from the working area, and the result is a public CDN URL. The result of this skill is that URL.

## Config
This skill needs: `meta.yaml` (keys: `shopify.store_domain`, `shopify.cdn_base`, `shopify.upload_approved`, `shopify.file_naming`).
Look in this order: see `core/client-config`. No store: stop, and say the file needs another public host. **Files uploaded here are public to anyone with the link.** Upload only what `shopify.upload_approved` allows. If it is empty, ask the owner before the first upload and record their answer there.

Tools: read core/platform-adapters for this platform's tool names.

## Uses from core
- `core/client-config` for the store and the approval
- `core/platform-adapters` for "run a Shopify GraphQL mutation", "run a Shopify GraphQL query" and "run a shell command in the working area"
- `core/meta-creative-publish`, which usually needs the URL next

## Inputs
The file in the working area, its MIME type, and its size in bytes.

## Steps
1. **Check the approval.** The file must be a kind the owner approved for public hosting (`shopify.upload_approved`). Never upload private material: invoices, personal photos, unreleased work outside the approved kinds.
2. **Name it** by `shopify.file_naming` (empty: ask). Whatever the pattern, the name and the alt text say what the file is and that it is for internal use, because anyone with the link can open it.
3. **Ask for an upload slot** ("run a Shopify GraphQL mutation"):
   ```graphql
   mutation stageIt($input: [StagedUploadInput!]!) { stagedUploadsCreate(input: $input) { stagedTargets { url resourceUrl parameters { name value } } userErrors { field message } } }
   ```
   Variables: `{"input":[{"resource":"IMAGE","filename":"<name>","mimeType":"<mime>","httpMethod":"POST","fileSize":"<bytes>"}]}`. `fileSize` is a string. Use `"resource":"FILE"` for anything that is not an image (not yet tested in a real run).
4. **POST the file** from the working area ("run a shell command in the working area"):
   ```bash
   curl -sS -o /dev/null -w '%{http_code}\n' "<url>" \
     -F "<name 1>=<value 1>" -F "<name 2>=<value 2>" ... \
     -F "file=@<path>"
   ```
   Every returned parameter goes in as a `-F` field, in the order returned, with the file last. Expect `201`. The staged-upload host is reachable from sandboxes that cannot reach the store's CDN.
5. **Register the file** ("run a Shopify GraphQL mutation"):
   ```graphql
   mutation makeFile($files: [FileCreateInput!]!) { fileCreate(files: $files) { files { id fileStatus } userErrors { field message } } }
   ```
   Variables: `{"files":[{"originalSource":"<resourceUrl>","contentType":"IMAGE","alt":"<alt text>"}]}`.
6. **Wait until it is ready** ("run a Shopify GraphQL query"), every few seconds:
   ```graphql
   query { node(id: "<file id>") { ... on MediaImage { fileStatus image { url } } } }
   ```
   Stop when `fileStatus` is `READY`. The `url` is the public link (it starts with `shopify.cdn_base`). For a non-image file, query `... on GenericFile { fileStatus url }` (not yet tested in a real run).
7. **Record the URL** where the calling skill keeps it (for reference images: `references.yaml`).

## Output
The public URL of the file, and its Shopify file ID.

## Known failures
- **An upload was blocked because nobody had asked for it.** Cause: uploading to a public store without the owner's go-ahead. Fix: the approval check (step 1), recorded in config once given.
- **The working area could not fetch the CDN URL after upload.** Cause: the sandbox blocks the CDN host. This is expected; Meta and the browser page can fetch it. Do not treat it as a failed upload.
- **A Drive link would not load inside another site.** Cause: Drive links are blocked by CORS there, and the browser is not signed in to Google. Fix: host the file here and use the CDN URL.
- **The browser page could not open a local file.** Cause: a browser page cannot read the disk, and a site's "choose file" window is a native dialog outside the page that agent tools cannot operate. Fix: host the file here and fetch it inside the page by URL.
- **Risk: the POST does not return 201.** Likely cause: a parameter missing or out of order, or the file not last. Fix: send every returned parameter, in order, then the file.

## References
- None.
