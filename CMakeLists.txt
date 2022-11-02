list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/CMakeModules)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} PARENT_SCOPE)

include(conan_helper)
include(putils_src_files)
include(putils_copy_dlls)
include(putils_add_test_executable)