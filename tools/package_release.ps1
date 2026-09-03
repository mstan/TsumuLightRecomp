param(
    [string]$Version = "v0.0.2",
    [string]$BuildDir = "build-release",
    [string]$CacheBuildDir = "build-release"
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
$FrameworkRoot = Join-Path $Root "psxrecomp-v4"

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

function Get-TomlScalar {
    param(
        [Parameter(Mandatory)][string]$GameToml,
        [Parameter(Mandatory)][string]$Table,
        [Parameter(Mandatory)][string]$Key
    )
    $section = ""
    foreach ($raw in (Get-Content -LiteralPath $GameToml)) {
        $line = $raw.Trim()
        if (-not $line -or $line.StartsWith("#")) { continue }
        if ($line -match '^\[\[?([^\]]+)\]\]?$') { $section = $Matches[1].Trim(); continue }
        if ($section -ne $Table) { continue }
        if ($line -match ('^' + [regex]::Escape($Key) + '\s*=\s*(.+?)\s*(?:#.*)?$')) {
            return $Matches[1].Trim().Trim('"').Trim("'")
        }
    }
    return $null
}

. (Join-Path $FrameworkRoot "tools\release_overlay_stage.ps1")

$RecompSourceDir = Join-Path $FrameworkRoot "recompiler"
$RecompDir = Join-Path $RecompSourceDir "build"
if (-not (Test-Path -LiteralPath (Join-Path $RecompDir "build.ninja"))) {
    Invoke-Native {
        cmake -S $RecompSourceDir -B $RecompDir -G Ninja -DCMAKE_BUILD_TYPE=Release
    } "recompiler configure"
}
Invoke-Native { cmake --build $RecompDir --target psxrecomp-game -j $env:NUMBER_OF_PROCESSORS } "recompiler build"

# Build: Release, debug tools OFF, launcher ON. PSX_STATIC_RUNTIME defaults ON
# for MinGW Release so the exe imports only system DLLs (self-contained).
Invoke-Native { cmake -S $Root -B $BuildPath -G Ninja -DCMAKE_BUILD_TYPE=Release -DPSX_DEBUG_TOOLS=OFF } "cmake configure"
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

# Launcher assets: this build ships the shared recomp-ui Dear ImGui launcher
# (RECOMP_LAUNCHER; see main.cpp + recomp-ui/recomp_ui.cmake), which loads from
# <exe>/assets/ (fonts + img TGAs, including this repo's boxart baked in by
# recomp_target_launcher_ui's POST_BUILD).
$AssetsSrc = Join-Path $BuildPath "assets"
if (-not (Test-Path (Join-Path $AssetsSrc "img"))) {
    throw "recomp-ui launcher assets missing at $AssetsSrc -- was the recomp-ui launcher built (recomp-ui junction present)?"
}
Copy-Item -Recurse -Force $AssetsSrc (Join-Path $Stage "assets")
$fontCount = (Get-ChildItem (Join-Path $Stage "assets/fonts") -Filter *.ttf -ErrorAction SilentlyContinue).Count
$imgCount  = (Get-ChildItem (Join-Path $Stage "assets/img")   -Filter *.tga -ErrorAction SilentlyContinue).Count
Write-Host "Bundled recomp-ui launcher assets: $fontCount font(s) + $imgCount image(s)"

Add-ModCatalog -BuildPath $BuildPath -Stage $Stage `
               -FrameworkModSource (Join-Path $FrameworkRoot "mods\builtin") | Out-Null

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

$RecompTools = (Resolve-Path (Join-Path $FrameworkRoot "tools")).Path
$RecompInc   = (Resolve-Path (Join-Path $FrameworkRoot "runtime\include")).Path
$StagedGameToml = Join-Path $Stage "game.toml"
$CacheGameId = Get-TomlScalar -GameToml $StagedGameToml -Table "game" -Key "id"
if (-not $CacheGameId) { throw "Could not read [game] id from $StagedGameToml" }
$CgTag = Get-OverlayCgTag -RecompTools $RecompTools -RecompInc $RecompInc `
                          -GameExe (Join-Path $RecompDir "psxrecomp-game.exe") `
                          -GameToml $StagedGameToml `
                          -BuildPath $BuildPath -RuntimeTarget "psx-runtime"
Write-Host "Release codegen tag: $CgTag (only this cache namespace is shipped)"

$OverlayCacheDeclared =
    ((Get-TomlScalar -GameToml $StagedGameToml -Table "runtime" -Key "overlay_cache") -eq "true")
if ($OverlayCacheDeclared) {
    $CacheSrcRoot = if ([System.IO.Path]::IsPathRooted($CacheBuildDir)) {
        $CacheBuildDir
    } else {
        Join-Path $Root $CacheBuildDir
    }
    foreach ($p in @($CacheSrcRoot, (Resolve-Path -LiteralPath $CacheSrcRoot -ErrorAction SilentlyContinue).Path)) {
        if ($p -and $p -match 'QUARANTINE') { throw "Refusing quarantined overlay cache source: $p" }
    }
    Add-OverlayCache -GameId $CacheGameId -CacheSrcRoot (Join-Path $CacheSrcRoot "cache") `
                     -Stage $Stage -CgTag $CgTag | Out-Null
} else {
    Write-Host "Staged game.toml does not declare overlay_cache; staging no shard cache"
}
Add-OverlayToolchain -Stage $Stage -RecompDir $RecompDir -RecompTools $RecompTools `
                     -RecompInc $RecompInc -MingwBin $MingwBin `
                     -DlCache (Join-Path $Root "tools\_toolchain_cache") | Out-Null

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
