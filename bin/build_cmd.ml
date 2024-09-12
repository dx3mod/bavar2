open Bavar2

let compile_project ~root_dir ~config_filename =
  let config =
    Filename.concat root_dir config_filename |> Project_config.load
  in
  let proj_unit = Project_resolver.resolve ~root_dir ~config in
  let build_dir = Filename.concat root_dir config.layout.build_dir in

  let args =
    Project_builder.firmware_options ~output_path:build_dir ~proj_unit ~config
  in

  List.iter (Printf.printf "%s ") args;
  print_newline ();

  if not (Sys.file_exists build_dir) then Sys.mkdir build_dir 0o777;

  try
    let gcc = Toolchain.Gcc_compiler.{ path = "/usr/bin/avr-gcc" } in
    Toolchain.Gcc_compiler.compile gcc args
  with Toolchain.Gcc_compiler.Error code ->
    Printf.eprintf "\nFailed to compile the project (exit code %d)!\n" code;
    exit code |> ignore;

    ()
