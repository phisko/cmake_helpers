function(putils_add_test_executable test_exe_name)
	add_executable(${test_exe_name} ${ARGN})
	putils_copy_dlls(${test_exe_name})

	set(customFindPackageNames gtest:GTest)
	set(customLibraryNames gtest:GTest)
	# Setting gtest:shared=True causes the tests to not be found for some reason
	putils_conan_download_and_link_packages_with_names(
		${test_exe_name} PRIVATE
		"${customFindPackageNames}"
		"${customLibraryNames}"
		gtest/1.12.1
	)

	cmake_policy(SET CMP0054 NEW)
	include(GoogleTest)
	gtest_add_tests(TARGET ${test_exe_name})
endfunction()