type t = { target : target option; layout : layout }
and target = { mcu : string; freq : frequency [@default Any] }
and frequency = Any | Hz of int

and layout = {
  source_dir : string; [@default "src/"]
  include_dir : string; [@default "include/"]
  build_dir : string; [@default "_build/"]
  vendor_dir : string; [@default "vendor/"]
      (** Sub directory of [build_dir].  *)
}
[@@deriving make]

module Decoders = struct
  module D = Decoders_sexplib.Decode
  open D.Infix
  open Sexplib

  let target_decoder =
    let frequency_of_string s =
      (** chop [suffix str] *)
      let chop suffix s =
        String.sub s 0 (String.length s - String.length suffix)
      in

      if String.ends_with ~suffix:"mhz" s then
        chop "mhz" s |> int_of_string |> ( * ) 1_000_000
      else if String.ends_with ~suffix:"hz" s then chop "hz" s |> int_of_string
      else failwith "invalid frequency value"
    in

    D.value >>= function
    | Sexp.(List [ Atom mcu ] | Atom mcu) -> make_target ~mcu () |> D.succeed
    | Sexp.(List [ Atom mcu; Atom freq ]) -> (
        try
          make_target ~mcu ~freq:(Hz (frequency_of_string freq)) () |> D.succeed
        with _ -> D.fail "failed to decode frequency value")
    | _ -> D.fail "empty target stanza"

  let config_decoder =
    let* target = D.field_opt "target" target_decoder in

    D.succeed { target; layout = make_layout () }
end

let of_sexp (sexp : Sexplib.Sexp.t) =
  Decoders.D.decode_value Decoders.config_decoder Sexplib.Sexp.(List [ sexp ])
  |> Result.map_error Decoders.D.string_of_error

let load filename =
  let buf = Bytes.create 200 in
  try Sexplib.Sexp.load_sexp ~buf filename |> of_sexp
  with Failure msg -> Error msg
