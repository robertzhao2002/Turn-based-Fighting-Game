let value_from_json json_object field_name converter =
  Yojson.Basic.Util.to_assoc json_object |> List.assoc field_name |> converter

let value_from_json_mapping json_mapping field_name converter =
  List.assoc field_name json_mapping |> converter

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

module GetData (Data : AdaptableJSONData) : Adapter = struct
  let get_json =
    let json =
      try Yojson.Basic.from_file Data.json_file with
      | Sys_error _ -> raise Not_found
    in
    json |> Yojson.Basic.Util.to_assoc |> List.assoc Data.main_field_name
    |> Yojson.Basic.Util.to_list

  let json_object =
    let name = Data.object_name in
    let rec find_object = function
      | [] -> raise (Failure ("Object with name " ^ name ^ " not found."))
      | h :: t ->
          let current_object = Yojson.Basic.Util.to_assoc h in
          if List.assoc "name" current_object |> Yojson.Basic.Util.to_string = name then
            current_object
          else find_object t
    in
    find_object get_json

  let to_bool_value field_name =
    value_from_json_mapping json_object field_name Yojson.Basic.Util.to_bool

  let to_int_value field_name =
    value_from_json_mapping json_object field_name Yojson.Basic.Util.to_int

  let to_float_value field_name =
    value_from_json_mapping json_object field_name Yojson.Basic.Util.to_float

  let to_string_value field_name =
    value_from_json_mapping json_object field_name Yojson.Basic.Util.to_string

  let to_string_list_value field_name =
    let rec to_string_list = function
      | [] -> raise (Failure "Cannot have empty string list")
      | h :: t -> Yojson.Basic.Util.to_string h :: to_string_list t
    in
    List.assoc field_name json_object |> Yojson.Basic.Util.to_list |> to_string_list

  let to_json_object_value field_name =
    value_from_json_mapping json_object field_name Helper.identity

  let to_json_object_list_value field_name =
    value_from_json_mapping json_object field_name Yojson.Basic.Util.to_list
end
