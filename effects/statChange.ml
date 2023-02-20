type t =
  | Attack of float * float * bool
  | Defense of float * float * bool
  | Speed of float * float * bool

let bind stat_change f =
  match stat_change with
  | Attack (multiplier, probability, self) -> f (multiplier, probability, self)
  | Defense (multiplier, probability, self) -> f (multiplier, probability, self)
  | Speed (multiplier, probability, self) -> f (multiplier, probability, self)

let single_as_string_helper (multiplier, probability, self) stat =
  let prob_percent = Util.Helper.percent_string probability in
  let target_string = if self then "user " else "opponent " in
  if multiplier < 1. then
    let complement = 1. -. multiplier in
    prob_percent ^ " chance to reduce " ^ target_string ^ stat ^ "by "
    ^ Util.Helper.percent_string complement
  else
    let multiple = multiplier -. 1. in
    prob_percent ^ " chance to increase " ^ target_string ^ stat ^ "by "
    ^ Util.Helper.percent_string multiple

let single_as_string = function
  | Attack (multiplier, probability, self) ->
      single_as_string_helper (multiplier, probability, self) "attack "
  | Defense (multiplier, probability, self) ->
      single_as_string_helper (multiplier, probability, self) "defense "
  | Speed (multiplier, probability, self) ->
      single_as_string_helper (multiplier, probability, self) "speed "

let as_string = function
  | [] -> ""
  | stat_changes ->
      let rec sc_to_str_tr acc = function
        | [] -> acc
        | h :: t -> sc_to_str_tr (acc ^ " " ^ single_as_string h ^ ";") t
      in
      sc_to_str_tr "\nStat Changes: " stat_changes

module Adapter = struct
  let to_object json_object =
    let stat = Util.Json.value_from_json json_object "stat" Yojson.Basic.Util.to_string in
    let multiplier =
      Util.Json.value_from_json json_object "multiplier" Yojson.Basic.Util.to_float
    in
    let probability =
      Util.Json.value_from_json json_object "probability" Yojson.Basic.Util.to_float
    in
    let self = Util.Json.value_from_json json_object "self" Yojson.Basic.Util.to_bool in
    match stat with
    | "attack" -> Attack (multiplier, probability, self)
    | "defense" -> Defense (multiplier, probability, self)
    | "speed" -> Speed (multiplier, probability, self)
    | _ -> raise (Failure ("Invalid Stat Name: " ^ stat))
end
