# engineering-3d-printing

Design functional parts and small devices with Claude without over-engineering them: think first, model in CAD, design for the printer, slice and print on Bambu Lab, and write firmware when there's a microcontroller in it.

Requires `core`.

## Install
```
/plugin install engineering-3d-printing --marketplace ibaadrh/agent-toolkit
```
Install `core` the same way first.

## Skills

| Skill | Use it when | Status |
|---|---|---|
| `functional-first-design` | Any new physical part: define the job, loads, fit, tolerances, print orientation and material before opening CAD; the "simplest thing that works" rules | write new (the thinking skill; the heart of this toolkit) |
| `bambulab-print-tutorial` | Taking a model to a finished print: slicer settings per material, supports, first layer, orientation, common failures, the easy-to-follow print guide | write new |
| `cad-reference-renders` | Need exact renders of a CAD part (ortho views, exploded, hero) for docs or ads; shares the Blender pipeline with video-production | extract from the static ad skill in the private inbox |
| `embedded-esp32-platformio` | Firmware for ESP32/Arduino with PlatformIO: project layout, libraries, OTA, power, debugging | write new (nothing good exists publicly) |

## Install alongside

| Tool | Why | Install | Licence | In use |
|---|---|---|---|---|
| [clangd-lsp](https://github.com/anthropics/claude-plugins-official) | C and C++ code intelligence (go to definition, diagnostics) for firmware work. Needs `clangd` on the PATH. | `claude plugin install clangd-lsp@claude-plugins-official` | Apache-2.0 | yes |
| [text-to-cad](https://github.com/earthtojake/text-to-cad) | CAD from text, STEP/STL/3MF, printability check, OrcaSlicer G-code, send to Bambu printers. Turn telemetry off: `uvx cadgen telemetry off`. | `claude plugin install text-to-cad@ibaad-toolkit` | MIT | no |
| [freecad-mcp](https://github.com/neka-nat/freecad-mcp) | FreeCAD GUI and FEM from Claude. | install the FreeCAD addon from the repo, then `claude mcp add --scope user freecad -- uvx freecad-mcp==0.1.27` | MIT | no |
| [KiCAD-MCP-Server](https://github.com/mixelpixx/KiCAD-MCP-Server) | PCB design in KiCad 9. | clone, run `./setup-macos.sh`, then add it to the MCP config as its README says | MIT | no |
| [bambu-printer-mcp](https://github.com/DMontgomery40/bambu-printer-mcp) | Printer control over the local network. | `claude mcp add --scope user bambu -e BAMBU_HOST=… -e BAMBU_SERIAL=… -e BAMBU_TOKEN=… -- npx -y @rowbotik/bambu-printer-mcp@1.1.1` | GPL-2.0 | no |
| [superpowers](https://github.com/obra/superpowers) | Brainstorming, planning, systematic debugging. | `claude plugin install superpowers@ibaad-toolkit` | MIT | no |
| [andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) | Think before coding, simplicity first, surgical changes: the anti-over-engineering layer. | `claude plugin install andrej-karpathy-skills@ibaad-toolkit` | MIT (stated in README; no licence file) | no |

Full list, versions and pins: [docs/THIRD-PARTY.md](../../docs/THIRD-PARTY.md).

Avoid `flowful-ai/cad-skill`: non-commercial licence.

## Config files used
`printer.yaml` (printer model, nozzle, filaments on hand, slicer profiles), optional `brand.yaml` for renders.
