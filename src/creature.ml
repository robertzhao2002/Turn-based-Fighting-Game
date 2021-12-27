open Yojson.Basic.Util
open Move
open Random

exception InvalidMove

type status =
  | Paralyze
  | Confuse of int
  | Poison

type t = {
  name : string;
  hp : float;
  attack : float;
  defense : float;
  speed : float;
  status : status list;
  moves : Move.t list;
  accuracy : float;
  evasiveness : float;
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
    accuracy = 1.;
    evasiveness = 1.;
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

let dead c = c.hp <= 0.

let compare_status s1 s2 =
  match s2 with
  | Paralyze -> begin
      match s1 with
      | Paralyze -> 0
      | _ -> 1
    end
  | Confuse c -> begin
      match s1 with
      | Paralyze -> -1
      | Poison -> 1
      | _ -> 0
    end
  | Poison -> begin
      match s1 with
      | Poison -> 0
      | _ -> -1
    end

let rec has_status s = function
  | [] -> false
  | h :: t -> begin
      match (h, s) with
      | Paralyze, Paralyze
      | Confuse _, Confuse _
      | Poison, Poison ->
          true
      | _ -> has_status s t
    end

let inflict_status c s =
  if has_status s c.status then c
  else
    match s with
    | Paralyze ->
        {
          c with
          speed = c.speed *. 0.75;
          status = List.sort_uniq compare_status (s :: c.status);
          evasiveness = 1.;
        }
    | _ -> { c with status = List.sort_uniq compare_status (s :: c.status) }

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
      | Speed (_, prop, _) -> { c with speed = c.speed *. prop }
      | AccuracyS (_, prop, _) -> { c with accuracy = c.accuracy *. prop }
      | Evasiveness (_, prop, _) -> { c with evasiveness = c.evasiveness *. prop })

let status_of c = List.sort_uniq compare_status c.status

let rec remove_confusion_tr acc = function
  | []
  | [ Confuse _ ] ->
      List.sort compare_status acc
  | Confuse _ :: t -> remove_confusion_tr acc t
  | h :: t -> remove_confusion_tr (h :: acc) t

let remove_confusion = remove_confusion_tr []

let reset_stats creature = function
  | true ->
      {
        creature with
        attack = attack creature;
        defense = defense creature;
        speed = speed creature;
        status = remove_confusion creature.status;
        accuracy = 1.;
        evasiveness = 1.;
      }
  | false ->
      {
        creature with
        attack = attack creature;
        defense = defense creature;
        speed = speed creature;
        accuracy = 1.;
        evasiveness = 1.;
      }

let rec apply_status_effect c = function
  | [] -> c
  | Paralyze :: t -> begin
      match Random.bool () with
      | false -> apply_status_effect c t
      | true -> apply_status_effect c (remove_confusion t)
    end
  | Confuse turns :: t -> (
      let prob_snap_out = if turns < 5 then 0.5 +. (float_of_int turns *. 0.1) else 0.999 in
      let random_snap_out = Random.float 1. in
      if random_snap_out < prob_snap_out then { c with status = remove_confusion c.status }
      else
        match Random.bool () with
        | true -> { c with hp = (if 0.9 *. c.hp <= 0.001 then 0. else 0.9 *. c.hp) }
        | false -> c)
  | Poison :: t ->
      apply_status_effect
        { c with hp = (if 0.95 *. c.hp <= 0.001 then 0. else 0.95 *. c.hp) }
        t
