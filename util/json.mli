val value_from_json : Yojson.Basic.t -> string -> (Yojson.Basic.t -> 'a) -> 'a

val value_from_json_mapping :
  (string * Yojson.Basic.t) list -> string -> (Yojson.Basic.t -> 'a) -> 'a

module type AdaptableJSONData = sig
  val main_field_name : string

  val object_name : string

  val json_file : string
end

module type Adapter = sig
  val to_bool_value : string -> bool

  val to_int_value : string -> int

  val to_float_value : string -> float

  val to_string_value : string -> string

  val to_string_list_value : string -> string list

  val to_json_object_value : string -> Yojson.Basic.t

  val to_json_object_list_value : string -> Yojson.Basic.t list
end

module GetData (Data : AdaptableJSONData) : Adapter
