# video-production

Make videos and product visuals with Claude: AI generation in Adobe Firefly (Veo, Nano Banana Pro, Firefly Speech), exact product renders from CAD in Blender, editing in Kdenlive and ffmpeg, and a studio folder system that keeps every client's footage, projects and finals in order.

Requires `core`.

## Install
```
/plugin install video-production --marketplace ibaadrh/agent-toolkit
```
Install `core` the same way first.

## Skills

| Skill | Use it when | Status |
|---|---|---|
| `video-studio-router` | Starting any client video job: finds the client's studio, applies the folder layout from `studio.folders`, onboards a new client | migrate from `video-studio` (the neutral routing only) |
| `kdenlive-project-builder` | Any edit plan → an editable `.kdenlive` project: clips, cuts, tracks and audio placed as the plan says, a preview render, and a check that the project opens in Kdenlive. No style of its own: lengths, speeds, grades, overlays, captions and music come from the plan or the client's private settings | write new (only the neutral Kdenlive mechanics from the private inbox; a client's reel style stays private) |
| `ugc-video-ad-maker` | Brief → script → AI presenter clip → voice-over → footage → ffmpeg edit with captions, in the structure and look the client's `video.yaml` sets | migrate the neutral mechanics (raw skill in the private inbox; the ads-loop role stays in digital-marketing) |
| `blender-reference-render-pack` | You have a CAD file and need exact product renders (the views and angles the product needs) for ads or print checks | extract from the static ad skill in the private inbox |
| `firefly-generation-recipes` | Prompt and settings recipes per job: presenter clip, product still, lifestyle hero, voice-over. Builds on `core/firefly-web-driver` | extract from both ad makers and their playbooks in the private inbox |

## Install alongside

| Tool | Why | Install | Licence | In use |
|---|---|---|---|---|
| [blender-mcp](https://github.com/ahujasid/mcp-for-blender) | Drive Blender from Claude: scenes, materials, bpy. | `claude mcp add --scope user blender -- uvx blender-mcp==2.0.0`, then install the Blender addon from the repo | MIT | no |
| [remotion skills](https://github.com/remotion-dev/skills) | Programmatic video with Remotion: captions, motion graphics, renders. | `npx -y skills@1.7.2 add remotion-dev/skills -g -a claude-code -y` | no licence file | no |
| [claude-code-video-toolkit](https://github.com/digitalsamba/claude-code-video-toolkit) | ffmpeg, ElevenLabs voice, Playwright screen recording and image models in one project. | clone, `uv sync`, then `/setup` inside it (ElevenLabs and image-model keys are optional) | MIT | no |
| [claude-ffmpeg-skill](https://github.com/ychoi-kr/claude-ffmpeg-skill) | Tested ffmpeg recipes and platform presets. | `npx -y skills@1.7.2 add ychoi-kr/claude-ffmpeg-skill -g -a claude-code -y` | MIT | no |
| [runway-api](https://github.com/runwayml/skills) | Runway video and image generation. Only worth it with a paid Runway account; calls need `RUNWAYML_API_SECRET`. | `claude plugin install runway-api@ibaad-toolkit` | MIT | no |

Full list, versions and pins: [docs/THIRD-PARTY.md](../../docs/THIRD-PARTY.md).

No public tool automates Kdenlive or consumer Firefly. The skills above are the only ones that do, which is why they are worth keeping in good shape.

## Config files used
`brand.yaml`, `video.yaml`, `reel-style.yaml`, `studio.yaml` (see `templates/client-config/`).
