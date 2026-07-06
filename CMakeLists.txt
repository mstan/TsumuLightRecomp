cmake_minimum_required(VERSION 3.20)
project(TsumuRecomp C CXX)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)

set(PSXRECOMP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/psxrecomp-v4" CACHE PATH
    "Path to psxrecomp")

include("${PSXRECOMP_ROOT}/runtime/runtime.cmake")

set(GAME_GENERATED_FULL
    "${CMAKE_CURRENT_SOURCE_DIR}/generated/SLPS_022.53_full.c")
set(GAME_GENERATED_DISPATCH
    "${CMAKE_CURRENT_SOURCE_DIR}/generated/SLPS_022.53_dispatch.c")

psxrecomp_add_runtime_target(psx-runtime
    GAME_GENERATED_FULL_C "${GAME_GENERATED_FULL}"
    GAME_GENERATED_DISPATCH_C "${GAME_GENERATED_DISPATCH}"
    DEBUG_PORT 4510
    WINDOW_TITLE "Tsumu Light Recompiled"
    DEFAULT_BIOS_PATH "${PSXRECOMP_ROOT}/bios/SCPH1001.BIN"
    DEFAULT_GAME_CONFIG_PATH "game.toml"
)

# Per-game launcher art override. The framework copies its shared launcher assets
# (img/disc.png etc.) next to the exe; this copies this repo's launcher_art/ on
# top AFTERWARD so the launcher shows Tsumu's cover. POST_BUILD commands run in
# add order and the framework's copy is added inside the runtime target above, so
# this override wins. launcher_art/ is gitignored (copyrighted cover art —
# supplied locally, never committed to the public repo).
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/launcher_art")
    add_custom_command(TARGET psx-runtime POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            "${CMAKE_CURRENT_SOURCE_DIR}/launcher_art"
            "$<TARGET_FILE_DIR:psx-runtime>"
        COMMENT "Overriding launcher art with TsumuRecomp/launcher_art")
endif()
