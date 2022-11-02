function(putils_add_test_executable test_exe_name)
	add_executable(${test_exe_name} ${ARGN})
	putils_copy_dlls(${test_exe_name})

	set(customFindPackageNames gtest:GTest)
	set(customLibraryNames gtest:GTest)
	putils_conan_download_and_link_packages_with_names(
		${test_exe_name} PRIVATE
		"${customFindPackageNames}"
		"${customLibraryNames}"
		gtest/cci.20210126
	)

	include(GoogleTest)
	gtest_discover_tests(${test_exe_name})
endfunction()