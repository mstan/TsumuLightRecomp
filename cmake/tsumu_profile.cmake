# The runtime creates/stamps the selected profile once. Keep presentation and
# boot defaults on the same build choice, without adding runtime HLE knobs.
if(NOT PSX_EXECUTION_PROFILE MATCHES "^(ENHANCED|REFERENCE)$")
    message(FATAL_ERROR "Tsumu needs the shared ENHANCED or REFERENCE profile")
endif()
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/game.toml" _tsumu_config)
string(FIND "${_tsumu_config}" "[audit]" _tsumu_audit)
if(_tsumu_audit GREATER_EQUAL 0)
    string(SUBSTRING "${_tsumu_config}" 0 ${_tsumu_audit} _tsumu_config)
endif()
set(_tsumu_pgxp PGXP)
set(_tsumu_mods "${CMAKE_CURRENT_SOURCE_DIR}/mods/preloaded")
if(PSX_EXECUTION_PROFILE STREQUAL "REFERENCE")
    set(_tsumu_pgxp "")
    set(_tsumu_mods NONE)
    foreach(_pair
        "bios_hle = true|bios_hle = false"
        "internal_resolution = \"1080p\"|internal_resolution = \"native\""
        "geometry_correction = true|geometry_correction = false"
        "perspective_texturing = true|perspective_texturing = false")
        string(REPLACE "|" ";" _settings "${_pair}")
        list(GET _settings 0 _before)
        list(GET _settings 1 _after)
        string(FIND "${_tsumu_config}" "${_before}" _found)
        if(_found LESS 0)
            message(FATAL_ERROR "REFERENCE default no longer matches source: ${_before}")
        endif()
        string(REPLACE "${_before}" "${_after}" _tsumu_config "${_tsumu_config}")
    endforeach()
endif()
set(_tsumu_player_config "${CMAKE_CURRENT_BINARY_DIR}/profiles/${PSX_EXECUTION_PROFILE}/game.toml")
file(CONFIGURE OUTPUT "${_tsumu_player_config}" CONTENT "${_tsumu_config}" @ONLY)
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/game.toml")
