cmake_minimum_required(VERSION 3.21)

function(putils_copy_dlls exe_name)
    # Copy DLLs next to executable
    # See https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html?highlight=target_file_dir#genex:TARGET_RUNTIME_DLLS
    #
    # We also copy $<TARGET_FILE:${exe_name}> (which will be a no-op, copying the file to its current location)
    # This to ensure "cmake -E copy" receives at least two arguments,
    # in the case where $<TARGET_RUNTIME_DLLS:${exe_name}> expands to an empty string
    add_custom_command(TARGET ${exe_name} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${exe_name}> $<TARGET_RUNTIME_DLLS:${exe_name}> $<TARGET_FILE_DIR:${exe_name}>
            COMMAND_EXPAND_LISTS
            COMMENT "Copied DLLs for ${exe_name}"
    )
endfunction()