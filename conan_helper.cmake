include(conan.cmake)

# Downloads the specified conan packages and links them against ${target} with the specified ${visibility}
# Usage:
#       add_executable(my_executable main.cpp)
#       putils_conan_download_and_link_packages(my_executable PRIVATE glm/0.9.9.8)
# If you need to pass additional arguments to conan_cmake_configure, you can do it like so:
#       putils_conan_download_and_link_packages(my_executable PRIVATE glm/0.9.9.8 OPTIONS glm:some_option=True)
function(putils_conan_download_and_link_packages target visibility)
    putils_conan_download_packages(${ARGN})
    putils_conan_link_packages(${ARGV})
endfunction()

# Similar to putils_conan_download_and_link_packages, but allows you to specify custom names to be used for each package
# when calling find_package or when linking against the library, for instance:
#       add_executable(my_executable main.cpp)
#       set(customFindPackageNames bullet3:Bullet)
#       set(customLibraryNames bullet3:Bullet)
#       putils_conan_download_and_link_packages_with_names(
#       	${name} PRIVATE
#       	"${customFindPackageNames}"
#       	"${customLibraryNames}"
#       	bullet3/3.21
#       	glm/0.9.9.8
#       )
function(putils_conan_download_and_link_packages_with_names target visibility customFindPackageNames customLibraryNames)
    putils_conan_download_packages(${ARGN})
    putils_conan_link_packages_with_names(${target} ${visibility} "${customFindPackageNames}" "${customLibraryNames}" ${ARGN})
endfunction()

# Downloads the specified conan packages
# Usage:
#       putils_conan_download_packages(glm/0.9.9.8)
# If you need to pass additional arguments to conan_cmake_configure, you can do it like so:
#       putils_conan_download_packages(glm/0.9.9.8 OPTIONS glm:some_option=True)
function(putils_conan_download_packages)
    conan_cmake_configure(
        REQUIRES
            ${ARGN}
        IMPORTS
            "bin, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
            "bin, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}"
            "bin, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}"
            "bin, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO}"
            "bin, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL}"

            "lib, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}"
            "lib, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG}"
            "lib, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE}"
            "lib, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO}"
            "lib, *.dll -> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL}"
        GENERATORS
            CMakeDeps
            CMakeToolchain
    )
    if(CMAKE_BUILD_TYPE)
        conan_cmake_autodetect(settings)
        conan_cmake_install(
            PATH_OR_REFERENCE .
            BUILD missing
            SETTINGS ${settings}
        )
    elseif(CMAKE_CONFIGURATION_TYPES)
        foreach(type ${CMAKE_CONFIGURATION_TYPES})
            conan_cmake_autodetect(settings BUILD_TYPE ${type})
            conan_cmake_install(
                PATH_OR_REFERENCE .
                BUILD missing
                SETTINGS ${settings}
            )
        endforeach()
    else()
        message(FATAL_ERROR "Please specify a configuration type or use a multi-config gerenator")
    endif()
endfunction()

# Links the specified packages against ${target} with the specified ${visibility}
# The packages need to have been previously downloaded
# Usage:
#       add_executable(my_executable main.cpp)
#       putils_conan_link_packages(my_executable PRIVATE glm/0.9.9.8)
function(putils_conan_link_packages target visibility)
    set(customFindPackageNames)
    set(customLibraryNames)
    putils_conan_link_packages_with_names(${target} ${visibility} "${customFindPackageNames}" "${customLibraryNames}" ${ARGN})
endfunction()

# Appends ${CMAKE_CURRENT_BINARY_DIR} to the required variables so that find_package can detect the files generated by conan
macro(putils_conan_prepare_find_package)
    # Find<PKG-NAME>.cmake will be looked for in CMAKE_MODULE_PATH
    list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_BINARY_DIR})
    list(REMOVE_DUPLICATES CMAKE_MODULE_PATH)

    # <PKG-NAME>-config.cmake will be looked for in CMAKE_PREFIX_PATH
    list(APPEND CMAKE_PREFIX_PATH ${CMAKE_CURRENT_BINARY_DIR})
    list(REMOVE_DUPLICATES CMAKE_PREFIX_PATH)
endmacro()

# Similar to putils_conan_link_packages, but allows you to specify custom names to be used for each package
# when calling find_package or when linking against the library, for instance:
#       add_executable(my_executable main.cpp)
#       set(customFindPackageNames bullet3:Bullet)
#       set(customLibraryNames bullet3:Bullet)
#       putils_conan_link_packages_with_names(
#       	${name} PRIVATE
#       	"${customFindPackageNames}"
#       	"${customLibraryNames}"
#       	bullet3/3.21
#       	glm/0.9.9.8
#       )
function(putils_conan_link_packages_with_names target visibility customFindPackageNames customLibraryNames)
    conan_parse_arguments(REQUIRES ${ARGN})
    putils_conan_prepare_find_package()

    foreach(packageAndVersion ${ARGUMENTS_REQUIRES})
        # Extract the package name
        string(FIND ${packageAndVersion} "/" slashIndex)
        string(SUBSTRING ${packageAndVersion} 0 ${slashIndex} packageName)

        # The argument to find_package defaults to the package name
        set(findPackageName ${packageName})

        # Try to find a custom find package name
        foreach(pair ${customFindPackageNames})
            string(FIND ${pair} ":" index)
            string(SUBSTRING ${pair} 0 ${index} pairPackageName)

            math(EXPR index "${index} + 1") # Increment index to skip past the ':'
            string(SUBSTRING ${pair} ${index} -1 pairFindPackageName)

            if(${packageName} STREQUAL ${pairPackageName})
                set(findPackageName ${pairFindPackageName})
                break()
            endif()
        endforeach()

        # The CMake library defaults to the package name
        set(libraryName ${packageName})

        # Try to find a custom library name
        foreach(pair ${customLibraryNames})
            string(FIND ${pair} ":" index)
            string(SUBSTRING ${pair} 0 ${index} pairPackageName)

            math(EXPR index "${index} + 1") # Increment index to skip past the ':'
            string(SUBSTRING ${pair} ${index} -1 pairLibraryName)

            if(${packageName} STREQUAL ${pairPackageName})
                set(libraryName ${pairLibraryName})
                break()
            endif()
        endforeach()

        find_package(${findPackageName} CONFIG REQUIRED)
        target_link_libraries(${target} ${visibility} "${libraryName}::${libraryName}")
    endforeach()
endfunction()

# Generates an outOption variable containing Conan options specifying if libraries should be shared or not based on BUILD_SHARED_LIBS
#   Usage:
#       putils_conan_set_shared_options(options somePackage)
#       putils_conan_download_and_link_packages(
#               myTarget PRIVATE
#               somePackage
#               ${options}
#       )
function(putils_conan_set_shared_options outOptions)
    set(options OPTIONS)

    if (BUILD_SHARED_LIBS)
        set(buildShared True)
    else()
        set(buildShared False)
    endif()

    foreach (package ${ARGN})
        list(APPEND options ${package}*:shared=${buildShared})
    endforeach()

    set(${outOptions} ${options} PARENT_SCOPE)
endfunction()