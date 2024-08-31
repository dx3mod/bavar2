type t = {
  target : target option;
  profile : build_profile; [@default Release]
  layout : layout;
}

and target = { mcu : string; freq : freqency }
and freqency = Any | Hz of int
and build_profile = Debug | Release

and layout = {
  source_dir : string; [@default "src/"]
  include_dir : string; [@default "include/"]
  build_dir : string; [@default "_build/"]
  vendor_dir : string; [@default "vendor/"]
}
[@@deriving make]
