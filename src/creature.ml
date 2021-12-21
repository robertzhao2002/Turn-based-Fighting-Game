open Yojson.Basic.Util
open Move

type status =
  | Poison
  | Confuse
  | Paralyze

type t = {
  name : string;
  hp : int;
  attack : int;
  defense : int;
  speed : int;
  status : status option;
  moves : Move.t list;
}

let rec initialize_creature_moves acc = function
  | [] -> acc
  | h :: t ->
      let move_name_str = to_string h in
      let accumulate_move = init_move_with_name move_name_str :: acc in
      initialize_creature_moves accumulate_move t

let creature_json f =
  let json =
    try Yojson.Basic.from_file f with
    | Sys_error _ -> raise Not_found
  in
  json |> to_assoc |> List.assoc "creatures" |> to_list

let rec creature_json_with_name n = function
  | [] -> raise Not_found
  | h :: t ->
      let current_creature_assoc = to_assoc h in
      if List.assoc "name" current_creature_assoc |> to_string = n then current_creature_assoc
      else creature_json_with_name n t

let init_creature_with_name n =
  let creature_json_assoc =
    creature_json_with_name n
      (creature_json ("creatures_data" ^ Filename.dir_sep ^ "creatures.json"))
  in
  {
    name = n;
    hp = List.assoc "hp" creature_json_assoc |> to_int;
    attack = List.assoc "attack" creature_json_assoc |> to_int;
    defense = List.assoc "defense" creature_json_assoc |> to_int;
    speed = List.assoc "speed" creature_json_assoc |> to_int;
    status = None;
    moves = List.assoc "moves" creature_json_assoc |> to_list |> initialize_creature_moves [];
  }

let name c = c.name

let hp c = c.hp

let attack c = c.attack

let defense c = c.defense

let speed c = c.speed

let status_of c = c.status
