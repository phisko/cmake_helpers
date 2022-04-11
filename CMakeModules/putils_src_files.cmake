function(putils_src_files dst_list)
	set(allfiles "")
	foreach (dir ${ARGN})
		list(APPEND allfiles ${dir}/*.cpp ${dir}/*.hpp ${dir}/*.inl)
	endforeach()

	file(GLOB src_files ${allfiles})
	set(${dst_list} ${src_files} PARENT_SCOPE)
endfunction()
