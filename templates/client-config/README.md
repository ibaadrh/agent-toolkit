# Client config templates

Copy this folder to `agent-clients/clients/<client>/`, fill it in, then drop it into `<product-repo>/.claude/toolkit/`.
In the Claude app, add each file to the Project as a doc named `toolkit/<file>`.

| File | Who reads it |
|---|---|
| `brand.yaml` | every toolkit |
| `voice.yaml` | all copy skills |
| `ads.yaml` | paid-ads-strategist, meta-campaigns-operator |
| `meta.yaml` | meta-campaigns-operator, static-ad-maker, ugc-video-ad-maker |
| `product-spec.md` | static-ad-maker, product-accuracy-check, cad-reference-renders |
| `references.yaml` | static-ad-maker (reference image pack, hero bank) |
| `video.yaml` | ugc-video-ad-maker |
| `reel-style.yaml` | kdenlive-reel-editor |
| `content.yaml` | social-content-research, b2b-social-copywriter |
| `canva.yaml` | canva-post-builder |
| `site.yaml` | website-development |
| `app.yaml` | app-development |
| `printer.yaml` | engineering-3d-printing |
| `studio.yaml` | video-studio-router (one per machine, not per client) |

Keys are fixed. Skills read them by name. Add keys, never rename them.
