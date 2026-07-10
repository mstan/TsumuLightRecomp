param(
    [string]$Version = "v0.0.2",
    [string]$BuildDir = "build-release"
)

# Tsumu Light (SLPS-02253) release packager. Adapted from ApeEscapeRecomp.
#
# v0.0.1 was hand-staged and shipped loose MinGW DLLs (libgcc/libstdc++/SDL2 --
# the 0xc000007b footgun) with no game.toml or translations. This packager
# builds the static self-contained exe and stages the full player layout.
#
# NOTE: this intentionally does NOT regenerate the game C; it builds the
# validated generated/ as-is against the pinned framework.

$ErrorActionPreference = "Stop"

$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
$BuildPath = Join-Path $Root $BuildDir
$StageRoot = Join-Path $Root "release-stage"
$Stage = Join-Path $StageRoot "TsumuLightRecomp-windows-x64"
$ZipPath = Join-Path $Root ("TsumuLightRecomp-{0}-windows-x64.zip" -f $Version)
$MingwBin = "C:\msys64\mingw64\bin"

$env:PATH = "$MingwBin;$env:PATH"

# cmake writes benign warnings to STDERR; under Stop preference PS 5.1 would
# abort the release for a non-error. Gate on $LASTEXITCODE instead.
function Invoke-Native {
    param([scriptblock]$Cmd, [string]$What)
    $old = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    & $Cmd
    $code = $LASTEXITCODE
    $ErrorActionPreference = $old
    if ($code -ne 0) { throw "$What failed (exit $code)" }
}

# Build: Release, debug tools OFF, launcher ON. PSX_STATIC_RUNTIME defaults ON
# for MinGW Release so the exe imports only system DLLs (self-contained).
Invoke-Native { cmake -S $Root -B $BuildPath -G Ninja -DCMAKE_BUILD_TYPE=Release -DPSX_DEBUG_TOOLS=OFF -DPSX_LAUNCHER=ON } "cmake configure"
Invoke-Native { cmake --build $BuildPath -j $env:NUMBER_OF_PROCESSORS } "cmake build"

if (Test-Path $StageRoot) { Remove-Item -Recurse -Force $StageRoot }
New-Item -ItemType Directory -Force $Stage | Out-Null
New-Item -ItemType Directory -Force (Join-Path $Stage "saves") | Out-Null

# The runtime target's OUTPUT_NAME is derived from window_title -> the built
# exe is Tsumu_Light_Recompiled.exe, NOT psx-runtime.exe.
$DevExe = Join-Path $BuildPath "Tsumu_Light_Recompiled.exe"
if (-not (Test-Path $DevExe)) { $DevExe = Join-Path $BuildPath "psx-runtime.exe" }
Copy-Item $DevExe (Join-Path $Stage "Tsumu_Light_Recompiled.exe")
if (Test-Path (Join-Path $Root "README.md"))         { Copy-Item (Join-Path $Root "README.md") $Stage }
if (Test-Path (Join-Path $Root "LICENSE"))           { Copy-Item (Join-Path $Root "LICENSE") $Stage }
if (Test-Path (Join-Path $Root "RELEASE_NOTES.md"))  { Copy-Item (Join-Path $Root "RELEASE_NOTES.md") $Stage }

# Launcher assets (staged next to the exe by the PSX_LAUNCHER build).
$LauncherRml = Join-Path $BuildPath "launcher.rml"
if (-not (Test-Path $LauncherRml)) {
    throw "Launcher assets missing at $BuildPath (no launcher.rml) -- was -DPSX_LAUNCHER=ON honored?"
}
Copy-Item $LauncherRml $Stage
foreach ($dir in @("fonts","img")) {
    $src = Join-Path $BuildPath $dir
    if (-not (Test-Path $src)) { throw "Launcher asset dir missing: $src" }
    Copy-Item -Recurse -Force $src (Join-Path $Stage $dir)
}
$fontCount = (Get-ChildItem (Join-Path $Stage "fonts") -Filter *.ttf -ErrorAction SilentlyContinue).Count
$imgCount  = (Get-ChildItem (Join-Path $Stage "img") -Filter *.png -ErrorAction SilentlyContinue).Count
Write-Host "Bundled launcher assets: launcher.rml + $fontCount font(s) + $imgCount image(s)"

# English translation tables: the runtime loads translations/*.toml under the
# project root (= the exe dir for an extracted install). Without these the
# launcher's Localization dropdown has nothing to apply.
Copy-Item -Recurse -Force (Join-Path $Root "translations") (Join-Path $Stage "translations")
Write-Host "Bundled translations/ ($((Get-ChildItem (Join-Path $Stage 'translations')).Count) file(s))"

# Player-facing game.toml: the REAL game.toml minus the dev-only [audit] block.
$realToml = Get-Content (Join-Path $Root "game.toml") -Raw
$idx = $realToml.IndexOf("Audit-specific")
if ($idx -ge 0) {
    $ls = $realToml.LastIndexOf("`n", $idx)
    $cut = if ($ls -ge 0) { $ls } else { 0 }
} else {
    $cut = $realToml.IndexOf("[audit]")
}
$playerToml = if ($cut -ge 0) { $realToml.Substring(0, $cut).TrimEnd() + "`n" } else { $realToml }
$playerToml | Set-Content -Encoding ASCII (Join-Path $Stage "game.toml")
Write-Host "Staged player game.toml from real game.toml (audit section stripped)"

# Verify self-containment: imports must be system DLLs only.
$objdump = Join-Path $MingwBin "objdump.exe"
$imports = & $objdump -p (Join-Path $Stage "Tsumu_Light_Recompiled.exe") |
    Select-String "DLL Name: (.+)" | ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() }
$systemDlls = @("kernel32.dll","user32.dll","gdi32.dll","shell32.dll","msvcrt.dll",
                "advapi32.dll","ws2_32.dll","comdlg32.dll","dbghelp.dll","ole32.dll",
                "oleaut32.dll","winmm.dll","imm32.dll","version.dll","setupapi.dll",
                "dinput8.dll","rpcrt4.dll","hid.dll","cfgmgr32.dll","opengl32.dll")
$nonSystem = $imports | Where-Object { $systemDlls -notcontains $_.ToLower() }
if ($nonSystem) {
    throw "Release exe is NOT self-contained -- imports non-system DLL(s): $($nonSystem -join ', ')"
}
Write-Host "Verified self-contained: imports only system DLLs ($($imports.Count) total)"

@"
TsumuLightRecomp $Version

Tsumu Light boots and plays as a native Windows program with no emulator
behind it. This is an early preview -- a full playthrough has not been
verified, so expect rough edges.

This package does not include the Tsumu Light disc, the PlayStation BIOS, or
any game assets -- you supply those from your own collection, and the launcher
asks for them one at a time. The executable contains a statically recompiled
(machine-translated) build of the game's code, the same distribution model
used by other static recompilation projects such as N64: Recompiled.

First launch:
1. Run Tsumu_Light_Recompiled.exe. A launcher window opens.
2. Set your PlayStation BIOS: a legally obtained SCPH1001.BIN (512 KB).
   Tsumu Light is a Japanese (NTSC-J) title but the standard US SCPH1001
   works: the default instant boot skips the console's region check.
3. Set the game disc: your legally obtained Tsumu Light (Japan, SLPS-02253)
   image.
4. Pick a language in Localization (English is pre-selected), adjust options,
   then press Launch.

Disc image formats: .cue + .bin (pick the .cue) or .bin. Do NOT convert to a
2048-byte "cooked" .iso.

Memory cards are stored in the saves directory.
"@ | Set-Content -Encoding ASCII (Join-Path $Stage "START_HERE.txt")

if (Test-Path $ZipPath) { Remove-Item -Force $ZipPath }
Compress-Archive -Path (Join-Path $Stage "*") -DestinationPath $ZipPath -Force

Write-Host "Wrote $ZipPath"
