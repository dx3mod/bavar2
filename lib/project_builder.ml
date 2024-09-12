(** Compiler options builder. *)
module Compiler_options_builder = struct
  open Printf

  type options = string list

  (* Basic *)

  let empty : options = []
  let raw = List.cons
  let raws = ( @ )

  (* Combinator *)

  let ( & ) oa ob (options : options) = oa (ob options) [@@inline]
  let opt f o options = Option.fold o ~none:options ~some:(Fun.flip f options)

  (* Other *)

  let define key value = raw @@ sprintf "-D%s=%s" key value
  let hz = define "F_CPU"
  let mcu mcu = raw @@ sprintf "-mmcu=%s" mcu

  let target ~mcu:mcu' ~hz:hz' =
    opt mcu mcu' & opt hz (Option.map string_of_int hz')

  let output path options = "-o" :: path :: options
  let arguments = raw
  let files = Fun.compose raws Array.to_list
  let header = Fun.compose raw @@ sprintf "-I%s"
  let headers = Fun.compose raws @@ List.map (sprintf "-I%s")
end

let firmware_options ~output_path ~(proj_unit : Project_unit.t)
    ~(config : Project_config.t) =
  let open Compiler_options_builder in
  empty
  |> output (Filename.concat output_path "firmware.elf")
  |> files proj_unit.source_files
  |> header proj_unit.root_dir
  |> headers proj_unit.include_dirs
  |> raws [ "-Os"; "-flto"; "-Wall"; "-Wpedantic" ]
  |> target
       ~mcu:(Project_config.option_of_mcu config.target.mcu)
       ~hz:(Project_config.option_of_hz config.target.freq)
