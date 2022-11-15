function(putils_export_symbols target)
    include(GenerateExportHeader)
    generate_export_header(${target} ${ARGN})
    target_include_directories(${target} PUBLIC ${CMAKE_CURRENT_BINARY_DIR})

    if (MSVC)
        # Disable warning "'...' needs to have dll-interface to be used by clients of class '...'"
        # which warned about STL types used in exported types
        target_compile_options(${target} PUBLIC /wd4251)
    endif()
endfunction()