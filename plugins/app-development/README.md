# app-development

Build and launch mobile apps with Claude Code: learn from competitor apps properly, apply mobile UI rules that fit app screens (not websites), build with a structure that stays maintainable, and get through Play Store and App Store review the first time.

Requires `core`.

## Install
```
/plugin install app-development --marketplace ibaadrh/agent-toolkit
```
Install `core` the same way first.

## Skills

| Skill | Use it when | Status |
|---|---|---|
| `app-feature-extraction` | Studying a competitor app: screenshots + APK decompile → feature list, flows, API shape, what to adopt and what to skip | write new (wraps `replica-recon` and the APK skill below) |
| `mobile-ui-taste` | Designing app screens: spacing, type, touch targets, platform conventions, no web-isms | write new |
| `app-build-structure` | Starting an app: stack choice (Flutter / Expo), folder layout, state, auth, analytics, crash reporting, from day one | write new, collect your Flutter app learnings |
| `app-release-checklist` | Shipping: keystores and signing, screenshots, store listing text, review-rejection patterns, staged rollout | write new |

## Install alongside

| Tool | Why | Install | Licence | In use |
|---|---|---|---|---|
| [replica-skill](https://github.com/Jakeschincariol/replica-skill) | The app reverse-engineering pack. `replica-recon` maps any app into screens, flows, a data model and a feature matrix; ten more skills cover architecture, design, build, backend, test, parity diff, brand, launch and deploy. | `claude plugin install replica-skill@ibaad-toolkit` | MIT | yes |
| [swift-lsp](https://github.com/anthropics/claude-plugins-official) | Swift code intelligence for iOS work. Needs Xcode's `sourcekit-lsp`. | `claude plugin install swift-lsp@claude-plugins-official` | Apache-2.0 | yes |
| [Figma MCP](https://developers.figma.com/docs/figma-mcp-server/) | Read Figma frames, variables and design context while building screens. | `claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp` (sign in on first use) | Figma service terms | yes |
| [android-reverse-engineering](https://github.com/SimoneAvogadro/android-reverse-engineering-skill) | APK decompile with jadx: endpoints, features, libraries. Pairs with replica-skill for Android apps. Needs JDK 17+ and jadx. | `claude plugin install android-reverse-engineering@ibaad-toolkit` | Apache-2.0 | no |
| [expo](https://github.com/expo/skills) | Official Expo skills: router, native UI, EAS builds and store submission. | `claude plugin install expo@ibaad-toolkit` | MIT | no |
| [android-skills](https://github.com/android/skills) | Official Google Android skills. | `claude plugin install android-skills@ibaad-toolkit` | Apache-2.0 | no |
| [aso-skills](https://github.com/appeeky/aso-skills) | App Store Optimisation: keywords, screenshots, listing tests, rejection recovery. | `claude plugin install aso-skills@ibaad-toolkit` | MIT | no |
| [app-store-preflight-skills](https://github.com/truongduy2611/app-store-preflight-skills) | Scan an app for App Review rejection patterns before submitting. | `npx -y skills@1.7.2 add truongduy2611/app-store-preflight-skills -g -a claude-code -y` | MIT | no |
| [flutter-all](https://github.com/cleydson/flutter-claude-code) | Flutter agents and patterns. Thin; expect to maintain your own notes on top. | `claude plugin install flutter-all@ibaad-toolkit` | no licence file | no |

Full list, versions and pins: [docs/THIRD-PARTY.md](../../docs/THIRD-PARTY.md).

`replica-recon` maps an app from its screens and public pages, and the APK skill reads Android builds. Nothing public joins them into one spec or handles iOS builds; `app-feature-extraction` is where your version lives.

## Config files used
`brand.yaml`, `app.yaml` (bundle IDs, store accounts, signing paths, analytics IDs).
