module Gcc_compiler = struct
  type t = { path : string }

  exception Error of int

  let compile { path } args =
    let exit_code =
      (* TODO: don't use Sys.command! It's a security hole for execute external code!  *)
      Sys.command @@ Printf.sprintf "%s %s" path (String.concat " " args)
    in
    if exit_code <> 0 then raise (Error exit_code)
end
