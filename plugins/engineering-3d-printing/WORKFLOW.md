# Engineering and 3D printing: the workflow

1. **Define the job** (`functional-first-design`). One sentence: what the part must do, where it lives, what it touches. Loads, fits, tolerances, environment. Write it down before CAD.
2. **Simplest shape that does the job.** Count features. If a feature doesn't serve the job, remove it. Prefer one part over an assembly. Prefer a print-friendly orientation over a pretty one.
3. **Model** (`text-to-cad` or your CAD). Parametric. Tolerances for your printer and material, not nominal.
4. **Check for printing** (text-to-cad DfAM check + `bambulab-print-tutorial`). Overhangs, bridges, wall thickness, orientation, supports only where needed.
5. **Slice and print** (`bambulab-print-tutorial`). Profile per material. First layer watched. One test print of the critical fit before the full part.
6. **Firmware, if any** (`embedded-esp32-platformio`). Same rule: simplest code that does the job, tested on hardware.
7. **Document.** Renders (`cad-reference-renders`), the print settings that worked, and what you'd change. Into the repo.
