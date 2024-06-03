set(VDF_BASE_DIR "vdf")
string(REPLACE "{version}" ${PROJECT_VERSION} VDF_COMMENT ${VDF_COMMENT})
string(TIMESTAMP DATE "%Y-%m-%d")
string(TIMESTAMP TIME "%H:%M")
string(REPLACE "{date}" ${DATE} VDF_COMMENT ${VDF_COMMENT})
string(REPLACE "{time}" ${TIME} VDF_COMMENT ${VDF_COMMENT})
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/plugin.vs.in" "${CMAKE_BINARY_DIR}/plugin.vs" @ONLY)

add_custom_target(BuildVDF
        DEPENDS ${PLUGIN_LIBRARY}
        COMMAND powershell -file ${CMAKE_SOURCE_DIR}\\vdf\\Build-VDF.ps1 ${CMAKE_BINARY_DIR}
        VERBATIM)

if(${COPY_BUILD_VDF_DATA})
    if((${UNION_API_FETCH_TYPE} STREQUAL "BINARY") AND (${UNION_API_LINK_TYPE} STREQUAL "SHARED"))
        file(COPY ${CMAKE_BINARY_DIR}/union-api/bin/${CMAKE_BUILD_TYPE}/UnionAPI.dll DESTINATION ${CMAKE_BINARY_DIR})
    endif()

    string(REPLACE "/" "\\" DATA_SOURCE_DIR ${CMAKE_BINARY_DIR})
    string(REPLACE "/" "\\" DATA_DIR ${COPY_BUILD_VDF_DATA_DIRECTORY})
    add_custom_target(CopyVDFData
            DEPENDS BuildVDF
            COMMAND copy /y /b ${DATA_SOURCE_DIR}\\*.vdf ${DATA_DIR})
endif()

