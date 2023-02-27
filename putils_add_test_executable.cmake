function(putils_add_test_executable test_exe_name)
	add_executable(${test_exe_name} ${ARGN})
	putils_copy_dlls(${test_exe_name})

	find_package(GTest CONFIG REQUIRED)
	target_link_libraries(${test_exe_name} PRIVATE GTest::gtest GTest::gtest_main)

	include(GoogleTest)
	gtest_discover_tests(${test_exe_name} DISCOVERY_MODE PRE_TEST)
endfunction()