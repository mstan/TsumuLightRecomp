# Tsumu adaptive renderer review, 2026-10-08

Enhanced native-wide rendering follows the live window aspect. Adaptive View
and Stable World Textures default on; OpenGL/1080p, exact projection transport,
English localization and locked digital reporting are retained. Guest projection,
simulation and audio remain native. The composed stage/battery strip anchors
at top left; the textured preview
(frame and spinning block together) anchors at top right through the shared
packet-guarded HUD API. Other screen UI retains its existing layout.

Original SLPS_022.53 world polygon rejection chains now use live horizontal
bounds: 34 signed right-edge comparisons, 25 left-edge keeps and 9 final
left-edge rejects across nine primitive paths in 8003D7FC..80041400. These
are X-only checks after GTE SXY packet stores; Y, depth and winding remain
architectural. At 4:3 the shared culling helpers are identity. The declaration
lives in game.toml; generated C is emitted, never patched by hand.

Interpolation is archived, uncompiled and unavailable. Older interpolation
receipts are historical. Generic CD/host timing controls remain retired; no
Tsumu-specific loader speedup is claimed.

Both BIOS backends are freshly emitted; the local launcher selects bundled
OpenBIOS. The release pins shared framework 95010e1a, including master cbfd24fd
and the shared Linux release-toolchain packaging correction.

Review: Play-Tsumu.ps1. Check a course at4:3,16:9 and a resized ultrawide window:
stage 3-1 blue goal side while rotating the view, wide attract-demo blocks,
English stage/battery at top left and the whole preview at top right, pause/retry.
At the name screen enter a character, then choose END. The owner accepted
the adaptive view, world culling and corner HUD candidate (beads-njks).
This approval does not establish complete course or measured audio coverage.

Owner repair check: Release incremental build and original-opcode/emitted-helper
audit pass for all 68 configured sites. Private OpenBIOS gameplay advances in
stages 1-1 and 2-1 across 4:3/16:9/32:9; English strip anchors left. The exact
owner stage 3-1 blue side, active preview and attract demo remain owner checks.
No audio or complete course coverage is claimed by the private check.

The v0.1.0 feature release uses production builds without developer tooling.
Windows ZIP and native Linux AppImage packaging delegate to the shared
framework through tools/package_release.sh and tools/package_native_appimage.sh.
Release checks cover embedded version/profile, package defaults, dependencies,
translation resources and bounded OpenGL startup with automatic OpenBIOS.
