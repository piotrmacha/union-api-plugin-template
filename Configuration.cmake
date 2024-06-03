set(PROJECT_NAME "MyPlugin"
        CACHE STRING "The name of the project" FORCE)
set(PROJECT_VERSION "0.0.1"
        CACHE STRING "Project version. It's automatically override by GitHub Actions on Release" FORCE)
set(PROJECT_VERSION_CMAKE "0.0.1"
        CACHE STRING "Project version for CMake, because it requires strictly up to 4 numbers, no letters allowed" FORCE)
set(PLUGIN_LIBRARY ${PROJECT_NAME}
        CACHE STRING "The name of plugin library target" FORCE)
set(OUTPUT_BINARY_NAME ${PLUGIN_LIBRARY}
        CACHE STRING "The name of output DLL file with the plugin (name without .dll)" FORCE)
set(VDF_NAME "${PROJECT_NAME}.vdf"
        CACHE STRING "The name of VDF archive" FORCE)
set(VDF_COMMENT "${PROJECT_NAME} {version} build: {date} {time}"
        CACHE STRING "The comment in VDF. Use replacements: {version}, {date}, {time}" FORCE)
set(LINK_UNION_API ON
        CACHE BOOL "Option if we should link Union API. In 100% cases it should be ON. If it's not, why are you using Union template exactly?" FORCE)
set(UNION_API_LINK_TYPE SHARED
        CACHE STRING "The linking method of Union API. STATIC = static linking of .lib, SHARED = DLL" FORCE)
set(UNION_API_FETCH_TYPE "BINARY"
        CACHE STRING "How to fetch Union API: SOURCE = download source and build locally, BINARY = download prebuilt artifacts" FORCE)
set(UNION_API_ENABLE_SIGNATURE ON
        CACHE BOOL "Enable the dynamic loading of Gothic function signatures. The signatures files are added to the build artifacts" FORCE)
set(LINK_GOTHIC_API ON
        CACHE BOOL "Option if we should link Gothic API." FORCE)
set(GOTHIC_API_G1 ON
        CACHE BOOL "Enable Gothic API for Gothic 1" FORCE)
set(GOTHIC_API_G1A ON
        CACHE BOOL "Enable Gothic API for Gothic Sequel" FORCE)
set(GOTHIC_API_G2 ON
        CACHE BOOL "Enable Gothic API for Gothic 2 Classic" FORCE)
set(GOTHIC_API_G2A ON
        CACHE BOOL "Enable Gothic API for Gothic 2 Night of the Raven" FORCE)
set(COPY_BUILD_DLL_AUTORUN OFF
        CACHE BOOL "Copy files on build to Autorun directory" FORCE)
set(COPY_BUILD_DLL_AUTORUN_DIRECTORY "System/Autorun/"
        CACHE STRING "Autorun directory path to copy the files" FORCE)
set(COPY_BUILD_VDF_DATA OFF
        CACHE BOOL "Copy build VDF to Data directory" FORCE)
set(COPY_BUILD_VDF_DATA_DIRECTORY "Data"
        CACHE STRING "Autorun directory path to copy the files" FORCE)

if(${UNION_API_FETCH_TYPE} STREQUAL "SOURCE")
    set(UNION_API_URL "https://github.com/piotrmacha/union-api.cmake"
            CACHE STRING "The URL to Git repository with CMake targets of Union API" FORCE)
    set(UNION_API_COMMIT_REF "tags/20240603.1019"
            CACHE STRING "The Git branch or commit ref to download" FORCE)

elseif(${UNION_API_FETCH_TYPE} STREQUAL "BINARY")
    set(UNION_API_URL "https://github.com/piotrmacha/union-api.cmake/releases/download/{version}/{package}.zip"
            CACHE STRING "The URL to download the Union API release. Use {version} and {package} replacements" FORCE)
    set(UNION_API_VERSION "20240603.1019"
            CACHE STRING "The version of Union API build from https://github.com/piotrmacha/union-api.cmake/releases/" FORCE)
    set(UNION_API_PACKAGE "UnionAPI-v143-windows-2022"
            CACHE STRING "The name of a release artifact to download from repository" FORCE)

else()
    message(FATAL_ERROR "Invalid UNION_API_FETCH_TYPE value (${UNION_FETCH_API_VALUE}). Use either SOURCE or BINARY")
endif()

# You can add your own config here. Remember to use CACHE {TYPE} "docs" FORCE to setup a global variable.
if(EXISTS ${CMAKE_SOURCE_DIR}/Configuration.override.cmake)
    include(${CMAKE_SOURCE_DIR}/Configuration.override.cmake)
endif()
