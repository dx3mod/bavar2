(** Compiler options builder. *)
module Options_builder = struct
  type t = string list

  open Printf

  (* Basic *)

  let empty : t = []
  let raw option options = List.cons option options [@@inline]

  (* Combinator *)

  let ( & ) oa ob (options : t) = oa (ob options) [@@inline]
  let opt f o options = Option.fold o ~none:options ~some:(Fun.flip f options)

  (* Other *)

  let define key value = raw @@ sprintf "-D%s=%s" key value
  let hz = define "F_CPU"
  let mcu mcu = raw @@ sprintf "-mmcu=%s" mcu
  let target ~mcu:mcu' ?hz:hz' () = mcu mcu' & opt hz hz'
  let output path options = "-o" :: path :: options
  let arguments = ( @ )
end
