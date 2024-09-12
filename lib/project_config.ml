type t = { target : target; layout : layout }
and target = { mcu : mcu; freq : frequency [@default Any] }
and frequency = Any | Hz of int
and mcu = Any | Mcu of string

and layout = {
  source_dir : string; [@default "src/"]
  include_dir : string; [@default "include/"]
  build_dir : string; [@default "_build/"]
  vendor_dir : string; [@default "vendor/"]
      (** Sub directory of [build_dir].  *)
}
[@@deriving make]

let option_of_mcu : mcu -> string option = function
  | Any -> None
  | Mcu mcu -> Some mcu

let option_of_hz : frequency -> int option = function
  | Any -> None
  | Hz hz -> Some hz

module Decoders = struct
  module D = Decoders_sexplib.Decode
  open D.Infix
  open Sexplib

  let target_decoder =
    let frequency_of_string s =
      let chop suffix s =
        String.sub s 0 (String.length s - String.length suffix)
      in

      if String.ends_with ~suffix:"mhz" s then
        chop "mhz" s |> int_of_string |> ( * ) 1_000_000
      else if String.ends_with ~suffix:"hz" s then chop "hz" s |> int_of_string
      else failwith "invalid frequency value"
    in

    let mcu_of_string : string -> mcu = function
      | "_" -> Any
      | mcu -> Mcu mcu
    in

    D.value >>= function
    | Sexp.(List [ Atom mcu ] | Atom mcu) ->
        make_target ~mcu:(mcu_of_string mcu) () |> D.succeed
    | Sexp.(List [ Atom mcu; Atom freq ]) -> (
        try
          let freq : frequency =
            if freq = "_" then Any else Hz (frequency_of_string freq)
          in
          make_target ~mcu:(mcu_of_string mcu) ~freq () |> D.succeed
        with _ -> D.fail "failed to decode frequency value")
    | _ -> D.fail "empty target stanza"

  let config_decoder =
    let* target = D.field "target" target_decoder in

    D.succeed { target; layout = make_layout () }
end

let of_sexp (sexp : Sexplib.Sexp.t) =
  Decoders.D.decode_value Decoders.config_decoder Sexplib.Sexp.(List [ sexp ])
  |> Result.fold ~ok:Fun.id ~error:(fun e ->
         failwith @@ Decoders.D.string_of_error e)

let load filename =
  let buf = Bytes.create 200 in
  try Sexplib.Sexp.load_sexp ~buf filename |> of_sexp
  with Failure msg -> failwith @@ "Failed to load project config!\n  " ^ msg
