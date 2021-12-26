open Yojson.Basic.Util

type effect =
  | Poison of float
  | Stun of float
  | Paralyze of float
  | Confuse of float

type stat_change =
  | Attack of float * float * bool
  | Defense of float * float * bool
  | Speed of float * float * bool

type move_type =
  | Water
  | Fire
  | Magic

type accuracy =
  | Accuracy of float
  | Guarantee

type t = {
  name : string;
  mtype : move_type;
  power : int;
  accuracy : accuracy;
  uses : int;
  meffect : effect list;
  mstat_change : stat_change list;
}

exception NoMoreUses

let type_from_string = function
  | "water" -> Water
  | "fire" -> Fire
  | "magic" -> Magic
  | _ -> raise Not_found

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
        | _ -> raise Not_found
      in
      effect :: stats_from_json t

let accuracy_from_int = function
  | 1000 -> Guarantee
  | a -> Accuracy (float_of_int a /. 100.)

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

let move_json_assoc n =
  move_json_with_name n (move_json ("moves_data" ^ Filename.dir_sep ^ "moves.json"))

let init_move_with_name n =
  let m_json = move_json_assoc n in
  {
    name = n;
    mtype = List.assoc "type" m_json |> to_string |> type_from_string;
    power = List.assoc "power" m_json |> to_int;
    accuracy = List.assoc "accuracy" m_json |> to_int |> accuracy_from_int;
    uses = List.assoc "uses" m_json |> to_int;
    meffect = List.assoc "effects" m_json |> to_list |> effect_from_json;
    mstat_change = List.assoc "stat changes" m_json |> to_list |> stats_from_json;
  }

let name m = m.name

let move_type_of m =
  let m_json = move_json_assoc m.name in
  List.assoc "type" m_json |> to_string |> type_from_string

let base_power m =
  let m_json = move_json_assoc m.name in
  List.assoc "power" m_json |> to_int

let base_accuracy m =
  let m_json = move_json_assoc m.name in
  let accuracy = List.assoc "accuracy" m_json |> to_int |> accuracy_from_int in
  match accuracy with
  | Accuracy a -> a
  | Guarantee -> 1.

let uses m =
  let m_json = move_json_assoc m.name in
  List.assoc "uses" m_json |> to_int

let effects m =
  let m_json = move_json_assoc m.name in
  List.assoc "effects" m_json |> to_list |> effect_from_json

let stat_changes m =
  let m_json = move_json_assoc m.name in
  List.assoc "stat changes" m_json |> to_list |> stats_from_json

let use m =
  match m.uses with
  | 0 -> raise NoMoreUses
  | u -> { m with uses = u - 1 }
