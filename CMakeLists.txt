cmake_minimum_required(VERSION 3.20)
project(TsumuRecomp C CXX)
include(CTest)

set(CMAKE_C_STANDARD 99)
set(CMAKE_CXX_STANDARD 17)

set(PSXRECOMP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/psxrecomp-v4" CACHE PATH
    "Path to psxrecomp")

include("${PSXRECOMP_ROOT}/runtime/runtime.cmake")

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/tsumu_profile.cmake")

file(GLOB GAME_GENERATED_FULL CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/generated/SLPS_022.53_full_*.c")
if(NOT GAME_GENERATED_FULL)
    set(GAME_GENERATED_FULL
        "${CMAKE_CURRENT_SOURCE_DIR}/generated/SLPS_022.53_full.c")
endif()
set(GAME_GENERATED_DISPATCH
    "${CMAKE_CURRENT_SOURCE_DIR}/generated/SLPS_022.53_dispatch.c")

psxrecomp_add_runtime_target(psx-runtime
    ${_tsumu_pgxp}
    GAME_GENERATED_FULL_C "${GAME_GENERATED_FULL}"
    GAME_GENERATED_DISPATCH_C "${GAME_GENERATED_DISPATCH}"
    DEBUG_PORT 4510
    WINDOW_TITLE "Tsumu Light Recompiled"
    GAME_VERSION "0.0.2"
    DEFAULT_GAME_CONFIG_PATH "game.toml"
    LAUNCHER_BOXART "${CMAKE_SOURCE_DIR}/recomp/launcher/boxart.tga"
    PRELOADED_MODS_DIR "${_tsumu_mods}"
    # Loading policy belongs to this title; generic acceleration is retired.
    EXCLUDE_BUILTIN_MODS
        psx.enhancement.fast-loading
        psx.enhancement.cd-speed
    EXTRAS_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/tsumu_presentation.c"
)

# Add title policy bytes to the existing shared-core contract and refresh the
# stamp; a second profile call would discard new CONTRACT_FILES on early return.
# No unimplemented HLE family is registered.
foreach(_target psx-runtime psx-runtime-pgxp)
    if(TARGET ${_target})
        set_property(TARGET ${_target} APPEND PROPERTY PSX_EXECUTION_CONTRACT_FILES
            "${CMAKE_CURRENT_SOURCE_DIR}/src/tsumu_presentation.c"
            "${CMAKE_CURRENT_SOURCE_DIR}/game.toml"
            "${CMAKE_CURRENT_SOURCE_DIR}/CMakeLists.txt"
            "${CMAKE_CURRENT_SOURCE_DIR}/cmake/tsumu_profile.cmake"
            "${CMAKE_CURRENT_SOURCE_DIR}/mods/preloaded/packages/tsumu.presentation.stable-textures/1.0.0/manifest.toml"
            "${CMAKE_CURRENT_SOURCE_DIR}/mods/preloaded/packages/tsumu.enhancement.widescreen/1.0.0/manifest.toml")
        _psx_execution_stamp(${_target})
        add_custom_command(TARGET ${_target} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different "${_tsumu_player_config}"
                "$<TARGET_FILE_DIR:${_target}>/game.toml"
            COMMAND ${CMAKE_COMMAND} -E copy_directory "${CMAKE_CURRENT_SOURCE_DIR}/translations"
                "$<TARGET_FILE_DIR:${_target}>/translations"
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${CMAKE_CURRENT_SOURCE_DIR}/packaging/release/input.ini"
                "${CMAKE_CURRENT_SOURCE_DIR}/packaging/release/START_HERE.txt"
                "$<TARGET_FILE_DIR:${_target}>"
            VERBATIM)
    endif()
endforeach()
