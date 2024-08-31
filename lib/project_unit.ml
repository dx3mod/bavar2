type t = {
  root_dir : string;
  source_files : files;
  include_dirs : string list;
  depends : t list;
}

and files = string array
