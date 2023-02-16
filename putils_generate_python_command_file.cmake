# Circumvent cmd's 8191 character limit by generating a Python file that will run the command
# An alternative would be to use response files, but I haven't found a way to tell CMake or Ninja to do so
function(putils_generate_python_command_file command_file command)
    string(JOIN " " command_string ${command})
    set(
            file_content
            "
import subprocess
subprocess.run('${command_string}')
"
    )

    file(
            GENERATE
            OUTPUT ${command_file}
            CONTENT "${file_content}"
    )
endfunction()