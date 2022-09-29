open Yojson.Basic.Util
open Typematchup

let json_suffix = ".json"

type effect =
  | Poison of float
  | Stun of float
  | Paralyze of float
  | Confuse of float

type stat_change =
  | Attack of float * float * bool
  | Defense of float * float * bool
  | Speed of float * float * bool

type t = {
  name : string;
  move_type : Typematchup.t;
  base_power : int;
  current_uses : int;
  total_uses : int;
  move_effect : effect list;
  move_stat_change : stat_change list;
}

exception NoMoreUses

let target_of_string = function
  | "yourself" -> true
  | "opponent" -> false
  | _ -> raise Not_found

let rec effect_from_json = function
  | [] -> []
  | h :: t ->
      let current_effect = to_assoc h in
      let effect_string = List.assoc "effect" current_effect |> to_string in
      let effect_probability = List.assoc "probability" current_effect |> to_float in
      let effect =
        match effect_string with
        | "poison" -> Poison effect_probability
        | "stun" -> Stun effect_probability
        | "paralyze" -> Paralyze effect_probability
        | "confuse" -> Confuse effect_probability
        | _ -> raise Not_found
      in
      effect :: effect_from_json t

let rec stats_from_json = function
  | [] -> []
  | h :: t ->
      let current_stat = to_assoc h in
      let effect_string = List.assoc "stat" current_stat |> to_string in
      let stat_change_amount = List.assoc "change" current_stat |> to_float in
      let stat_change_probability = List.assoc "probability" current_stat |> to_float in
      let stat_change_target =
        List.assoc "target" current_stat |> to_string |> target_of_string
      in
      let effect =
        match effect_string with
        | "attack" -> Attack (stat_change_amount, stat_change_probability, stat_change_target)
        | "defense" -> Defense (stat_change_amount, stat_change_probability, stat_change_target)
        | "speed" -> Speed (stat_change_amount, stat_change_probability, stat_change_target)
        | _ -> raise (Failure effect_string)
      in
      effect :: stats_from_json t

let move_json f =
  let json =
    try Yojson.Basic.from_file f with
    | Sys_error _ -> raise Not_found
  in
  json |> to_assoc |> List.assoc "moves" |> to_list

let rec move_json_with_name n = function
  | [] -> raise Not_found
  | h :: t ->
      let current_move_assoc = to_assoc h in
      if List.assoc "name" current_move_assoc |> to_string = n then current_move_assoc
      else move_json_with_name n t

let move_json_assoc move_name file_name =
  move_json_with_name move_name
    (move_json ("moves_data" ^ Filename.dir_sep ^ file_name ^ json_suffix))

let init_move_with_name move_name file_name =
  let moves_json = move_json_assoc move_name file_name in
  let uses = List.assoc "uses" moves_json |> to_int in
  {
    name = move_name;
    move_type = List.assoc "type" moves_json |> to_string |> type_from_string;
    base_power = List.assoc "power" moves_json |> to_int;
    current_uses = uses;
    total_uses = uses;
    move_effect = List.assoc "effects" moves_json |> to_list |> effect_from_json;
    move_stat_change = List.assoc "stat changes" moves_json |> to_list |> stats_from_json;
  }

let use m =
  match m.current_uses with
  | 0 -> raise NoMoreUses
  | uses -> { m with current_uses = uses - 1 }

let percent_string f = Printf.sprintf "%.1f" (f *. 100.)

let effect_as_string = function
  | Poison chance -> percent_string chance ^ "% chance to poison"
  | Confuse chance -> percent_string chance ^ "% chance to confuse"
  | Paralyze chance -> percent_string chance ^ "% chance to paralyze"
  | Stun chance -> percent_string chance ^ "% chance to stun"

let stat_change_as_string_helper (amount, prob, target) stat =
  let prob_percent = percent_string prob in
  let target_string = if target then "user " else "opponent " in
  if amount < 1. then
    let complement = 1. -. amount in
    prob_percent ^ "% chance to reduce " ^ target_string ^ stat ^ "by "
    ^ percent_string complement ^ "%"
  else
    let multiple = amount -. 1. in
    prob_percent ^ "% chance to increase " ^ target_string ^ stat ^ "by "
    ^ percent_string multiple ^ "%"

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

let effects_as_string = function
  | [] -> ""
  | effects ->
      let rec e_to_s_tr acc = function
        | [] -> acc
        | h :: t -> e_to_s_tr (acc ^ " " ^ effect_as_string h ^ ";") t
      in
      e_to_s_tr "\nStatus Effects:" effects

let move_string move =
  Printf.sprintf "%s\nType: %s\nUses: %d/%d\nBase Power: %d; %s%s" move.name
    (move.move_type |> type_as_string)
    move.current_uses move.total_uses move.base_power
    (effects_as_string move.move_effect)
    (stat_changes_as_string move.move_stat_change)
