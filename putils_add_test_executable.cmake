function(putils_add_test_executable test_exe_name)
	add_executable(${test_exe_name} ${ARGN})
	putils_copy_dlls(${test_exe_name})

	if(NOT TARGET gtest::gtest)
		find_package(GTest 1.12.1 REQUIRED)
	endif()
	target_link_libraries(${test_exe_name} PRIVATE gtest::gtest)

	include(GoogleTest)
	gtest_discover_tests(${test_exe_name} DISCOVERY_MODE PRE_TEST)
endfunction()