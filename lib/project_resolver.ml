let globs ~path patterns =
  let f files pattern =
    try
      Globlon.glob (Filename.concat path pattern) ~glob_brace:true
      |> Array.append files
    with _ -> files
  in
  ListLabels.fold_left ~f ~init:[||] patterns

let resolve ~root_dir ~(config : Project_config.t) =
  let root_dir = Unix.realpath root_dir in
  let source_files =
    globs
      ~path:(Filename.concat root_dir config.layout.source_dir)
      [ "*.c"; "**/*.c"; "*.cpp"; "*.cxx"; "**/*.cpp"; "**/*.cxx" ]
  in

  Project.
    {
      root_dir;
      source_files;
      include_dirs = [ config.layout.source_dir; config.layout.include_dir ];
      depends = [];
    }
