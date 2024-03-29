function(putils_get_subdirectories directory result)
    file(GLOB children RELATIVE ${directory} ${directory}/*)
    set(dirlist "")
    foreach(child ${children})
        if(IS_DIRECTORY ${directory}/${child})
            list(APPEND dirlist ${child})
        endif()
    endforeach()

    set(${result} ${dirlist} PARENT_SCOPE)
endfunction()