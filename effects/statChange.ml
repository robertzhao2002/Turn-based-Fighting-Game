type t =
  | Attack of float * float * bool
  | Defense of float * float * bool
  | Speed of float * float * bool

let stat_change_as_string_helper (amount, prob, target) stat =
  let prob_percent = Util.Helper.percent_string prob in
  let target_string = if target then "user " else "opponent " in
  if amount < 1. then
    let complement = 1. -. amount in
    prob_percent ^ "% chance to reduce " ^ target_string ^ stat ^ "by "
    ^ Util.Helper.percent_string complement
    ^ "%"
  else
    let multiple = amount -. 1. in
    prob_percent ^ "% chance to increase " ^ target_string ^ stat ^ "by "
    ^ Util.Helper.percent_string multiple
    ^ "%"

let stat_change_as_string = function
  | Attack (amount, prob, target) ->
      stat_change_as_string_helper (amount, prob, target) "attack "
  | Defense (amount, prob, target) ->
      stat_change_as_string_helper (amount, prob, target) "defense "
  | Speed (amount, prob, target) ->
      stat_change_as_string_helper (amount, prob, target) "speed "

let stat_changes_as_string = function
  | [] -> ""
  | stat_changes ->
      let rec sc_to_str_tr acc = function
        | [] -> acc
        | h :: t -> sc_to_str_tr (acc ^ " " ^ stat_change_as_string h ^ ";") t
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
