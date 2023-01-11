function(putils_export_symbols target)
    include(GenerateExportHeader)
    generate_export_header(${target} ${ARGN})

    # Get the same EXPORT_FILE_NAME as generate_export_header (see GenerateExportHeader.cmake)
    set(options)
    set(oneValueArgs EXPORT_FILE_NAME)
    set(multiValueArgs)
    cmake_parse_arguments(_GEH "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    set(BASE_NAME ${target})
    string(TOLOWER ${BASE_NAME} BASE_NAME_LOWER)
    set(EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/${BASE_NAME_LOWER}_export.h")
    if(_GEH_EXPORT_FILE_NAME)
        if(IS_ABSOLUTE ${_GEH_EXPORT_FILE_NAME})
            set(EXPORT_FILE_NAME ${_GEH_EXPORT_FILE_NAME})
        else()
            set(EXPORT_FILE_NAME "${CMAKE_CURRENT_BINARY_DIR}/${_GEH_EXPORT_FILE_NAME}")
        endif()
    endif()

    set_target_properties(${target} PROPERTIES PUTILS_EXPORT_FILE_NAME ${EXPORT_FILE_NAME})

    # The header will be generated here, so add it to the include directories
    target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_BINARY_DIR})

    # Force include the header
    if (MSVC)
        target_compile_options(${target} PUBLIC /FI${EXPORT_FILE_NAME})
    else()
        target_compile_options(${target} PUBLIC "SHELL:-include ${EXPORT_FILE_NAME}")
    endif()

    if (MSVC)
        # Disable warning "'...' needs to have dll-interface to be used by clients of class '...'"
        # which warned about STL types used in exported types
        target_compile_options(${target} PUBLIC /wd4251)
    endif()
endfunction()