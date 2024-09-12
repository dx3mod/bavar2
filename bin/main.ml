let build_command = ref false
let root_dir = ref @@ Sys.getcwd ()

let speclist =
  [
    ("-build", Arg.Set build_command, "Compile the project");
    ("-root", Arg.Set_string root_dir, "Path to project directory");
  ]

(*  *)

let () =
  Arg.parse speclist ignore
    "A domain-specific build system for AVR C/C++ projects";

  try
    if !build_command then
      Build_cmd.compile_project ~root_dir:!root_dir
        ~config_filename:"bavar-project"
  with Failure msg | Sys_error msg ->
    prerr_endline msg;
    exit 1
