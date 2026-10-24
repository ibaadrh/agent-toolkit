# Video production: the workflow

Start to finish. Each step names the skill that does it.

1. **Find or create the studio** (`video-studio-router`). Every client has one folder tree, by default `1 Drop Footage Here`, `2 Review`, `3 Projects`, `4 Final`, `Brand Kit` (`studio.folders` can override). Code and caches never live on the media drive.
2. **Decide the kind of video.** Real footage edit → step 3. AI presenter or product ad → step 4. Product-only visuals → step 5.
3. **Footage edit** (`kdenlive-project-builder`). Survey with contact sheets. Write the edit plan; its style (length, speeds, grade, overlays, captions, music) comes from the brief or the client's private settings, never from the toolkit. Build the editable Kdenlive project from the plan. Render a preview into the review folder and check the project opens in Kdenlive. Never overwrite a version the client has seen.
4. **AI ad** (`ugc-video-ad-maker`). Check credits first. Script in every language needed. Presenter clip from a fixed first frame; never re-edit a face with an image model. Structure and look from the client's `video.yaml`. Edit in ffmpeg with the vertical toolkit. Verify with frame strips before delivery.
5. **Exact product visuals** (`blender-reference-render-pack` + `core/product-accuracy-check`). Renders come from CAD, never from AI 3D. Keep an `index.csv` of renders so other skills can pick the closest angle.
6. **Deliver** (`core/file-delivery`). Named files, version bumped, Drive link verified, short report in the house format.
7. **Capture learnings.** Anything that went wrong goes into the owning skill in this repo, not into a chat.

To be expanded with the real prompts, settings and gotchas during migration (see `prompts/05-write-workflow.md`).
