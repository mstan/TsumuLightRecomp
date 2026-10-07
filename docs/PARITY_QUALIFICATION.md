# Tsumu Light review candidate, 2026-10-07

The Windows enhanced candidate is built and the first puzzle has passed a
bounded native scene interpolation check. Owner gameplay acceptance and full
parity remain open (`beads-njks`). Start it with
`F:/Projects/psxrecomp/parity-review-20261006/Play-Tsumu.ps1`.

## Built behavior

- OpenGL with 1080p internal rendering, PGXP and world texture filtering.
- Real intermediate geometry through `src/tsumu_frame_interpolation.cpp`;
  temporal blending is not its interpolation mechanism.
- Two draw spans, `800182A4..8001847C` and `800184EC..800189F8`, stop before
  the audio/input work. The shared sandbox restores the draw-entry state,
  interpolates projections and preserves the current late ordering-table work.
- Double-buffer environments are retargeted to the displayed bank using the
  shared GPU command decoder, retaining the complete puzzle and current HUD.
- Both the stable-texture and interpolation packages now use the required
  `mods/preloaded/packages/<id>/<version>` catalog layout. The original direct
  children of `preloaded` were invisible to the catalog.
- Native interpolation is opt-in in source and enabled in the private review
  profile. The English localization and authentic 4:3 layout are preserved.

## Bounded evidence

The rebuilt executable is `build-native-review/Tsumu_Light_Recompiled.exe`,
SHA-256 `fa43ad43ffbcab7b34c2b956eb4c1c4e8b6222c3cdc1931b2db17233651c5189`.
The execution receipt binds the ENHANCED identity
`912c15019daf33d59e626d94681636da3f2ebdb172d224e60c7fad811c551b75` to that binary.

In a five-second movement sample in the first puzzle, 435 native passes and
435 restoration checks completed, with zero mismatches, watchdogs, device reads
or VRAM leaks. The complete enhanced puzzle/HUD screenshot was inspected.
There were 730 presentations in that sample; this correctness run is not a
clean throughput benchmark or all-course qualification. The requested phase
dump directory had not been created, so no individual phase-image comparison
is claimed. Evidence: `receipts/Tsumu.native-first-puzzle.json` and
`tsumu-native-final.png` in the review directory.

The primary disc has no overlay inventory. Its static game code was rebuilt
with CODEGEN18, configuration `54c7fad4`, PGXP flavor 2. This is distinct from
claiming a captured overlay set or a title-specific loading HLE.

## Owner check

Keep OpenGL/1080p, Stable Textures and Native Scene Interpolation enabled;
choose Display refresh. Start a course, move/rotate around a puzzle, check the
English prompts and HUD, then pause/resume, retry and load a course. Look for
missing puzzle geometry, double images, shimmer and altered input timing.
At the name screen enter at least one character, then select END to continue.

## Remaining parity

This candidate is still 4:3. Extended view through 32:9, wider activation and
HUD layout have no qualified title implementation. Extended distance,
subdivision changes and loader/decompression HLE are not implemented. The
shared CD/BIOS infrastructure is present but is not evidence of a title loader
speedup. REFERENCE remains separately configurable; a fresh reference build
and native Linux packaging were not run in this first pass. Broader course,
save/menu and owner gameplay validation remain required.
