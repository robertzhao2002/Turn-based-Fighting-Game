open Yojson.Basic.Util
open Move

exception InvalidMove

type status =
  | Poison
  | Confuse
  | Paralyze

type t = {
  name : string;
  hp : float;
  attack : float;
  defense : float;
  speed : float;
  status : status list;
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

let creature_json_assoc n =
  creature_json_with_name n
    (creature_json ("creatures_data" ^ Filename.dir_sep ^ "creatures.json"))

let init_creature_with_name n =
  let c_json = creature_json_assoc n in
  {
    name = n;
    hp = List.assoc "hp" c_json |> to_float;
    attack = List.assoc "attack" c_json |> to_float;
    defense = List.assoc "defense" c_json |> to_float;
    speed = List.assoc "speed" c_json |> to_float;
    status = [];
    moves = List.assoc "moves" c_json |> to_list |> initialize_creature_moves [];
  }

let name c = c.name

let hp c =
  let c_json = creature_json_assoc c.name in
  List.assoc "hp" c_json |> to_float

let attack c =
  let c_json = creature_json_assoc c.name in
  List.assoc "attack" c_json |> to_float

let defense c =
  let c_json = creature_json_assoc c.name in
  List.assoc "defense" c_json |> to_float

let speed c =
  let c_json = creature_json_assoc c.name in
  List.assoc "speed" c_json |> to_float

let status_of c = c.status

let dead c = c.hp <= 0.

let rec has_status s = function
  | [] -> false
  | h :: t -> if h = s then true else has_status s t

let inflict_status c s = if has_status s c.status then c else { c with status = s :: c.status }

let inflict_damage c d =
  let damaged = { c with hp = c.hp -. d } in
  match dead damaged with
  | true -> { damaged with hp = 0. }
  | false -> damaged

let rec change_stats c = function
  | [] -> c
  | h :: t -> (
      match h with
      | Attack (_, prop, _) -> { c with attack = c.attack *. prop }
      | Defense (_, prop, _) -> { c with defense = c.defense *. prop }
      | Speed (_, prop, _) -> { c with attack = c.defense *. prop })
