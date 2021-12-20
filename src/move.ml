open Yojson.Basic.Util

type effect =
  | Poison of float
  | Paralyze of float
  | Confuse of float

type stat_change =
  | Attack of float
  | Defense of float
  | Speed of float

type move_variant =
  | Damaging
  | Status of effect
  | StatChange of stat_change

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
  base_power : int;
  base_accuracy : accuracy;
  uses : int;
  meffect : effect list;
  mvariant : move_variant;
}

let type_from_string = function
  | "water" -> Water
  | "fire" -> Fire
  | "magic" -> Magic
  | _ -> raise Not_found

let rec effect_from_json = function
  | [] -> []
  | h :: t ->
      let current_effect = to_assoc h in
      let effect_string = List.assoc "effect" current_effect |> to_string in
      let effect_probability =
        List.assoc "probability" current_effect |> to_int |> float_of_int
      in
      let effect =
        match effect_string with
        | "poison" -> Poison (effect_probability /. 100.)
        | "paralyze" -> Paralyze (effect_probability /. 100.)
        | "confuse" -> Confuse (effect_probability /. 100.)
        | _ -> raise Not_found
      in
      effect :: effect_from_json t

let accuracy_from_int = function
  | 1000 -> Guarantee
  | a -> Accuracy (float_of_int a /. 100.)

let rec move_json f =
  let json =
    try Yojson.Basic.from_file f with
    | Sys_error _ -> raise Not_found
  in
  json |> to_assoc |> List.assoc "moves" |> to_list

let rec move_json_with_name n = function
  | [] -> raise Not_found
  | h :: t ->
      let current_move_assoc = to_assoc h in
      if List.assoc "name" current_move_assoc |> to_string = n then to_assoc h
      else move_json_with_name n t

let init_move_with_name n =
  let move_json_assoc =
    move_json_with_name n (move_json ("moves_data" ^ Filename.dir_sep ^ "moves.json"))
  in
  {
    name = n;
    mtype = List.assoc "type" move_json_assoc |> to_string |> type_from_string;
    base_power = List.assoc "power" move_json_assoc |> to_int;
    base_accuracy = List.assoc "accuracy" move_json_assoc |> to_int |> accuracy_from_int;
    uses = List.assoc "uses" move_json_assoc |> to_int;
    meffect = List.assoc "effects" move_json_assoc |> to_list |> effect_from_json;
    mvariant = Damaging;
  }

let name m = m.name

let move_type_of m = m.mtype

let power m = m.base_power

let accuracy m =
  match m.base_accuracy with
  | Accuracy a -> a
  | Guarantee -> 1.

let uses m = m.uses
