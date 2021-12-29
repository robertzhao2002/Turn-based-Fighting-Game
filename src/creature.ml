open Yojson.Basic.Util
open Move
open Random

let () = Random.self_init ()

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
  paralyze : bool;
  confuse : int option;
  poison : bool;
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
    paralyze = false;
    confuse = None;
    poison = false;
    moves = List.assoc "moves" c_json |> to_list |> initialize_creature_moves [];
    accuracy = 1.;
    evasiveness = 1.;
  }

let name c = c.name

let dead_tolerance c =
  match c.hp < 0.001 with
  | true -> { c with hp = 0. }
  | false -> c

let base_hp c =
  let c_json = creature_json_assoc c.name in
  List.assoc "hp" c_json |> to_float

let base_attack c =
  let c_json = creature_json_assoc c.name in
  List.assoc "attack" c_json |> to_float

let base_defense c =
  let c_json = creature_json_assoc c.name in
  List.assoc "defense" c_json |> to_float

let base_speed c =
  let c_json = creature_json_assoc c.name in
  List.assoc "speed" c_json |> to_float

let dead c = c.hp <= 0.

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

let inflict_damage c d =
  let damaged = { c with hp = c.hp -. d } in
  match dead damaged with
  | true -> { damaged with hp = 0. }
  | false -> damaged

let rec change_stats c1 c2 = function
  | [] -> (c1, c2)
  | h :: t -> begin
      match h with
      | Attack (prob, prop, apply_to) ->
          if Random.float 1. < prob then
            if apply_to then change_stats { c1 with attack = c1.attack *. prop } c2 t
            else change_stats c1 { c2 with attack = c2.attack *. prop } t
          else change_stats c1 c2 t
      | Defense (prob, prop, apply_to) ->
          if Random.float 1. < prob then
            if apply_to then change_stats { c1 with defense = c1.defense *. prop } c2 t
            else change_stats c1 { c2 with defense = c2.defense *. prop } t
          else change_stats c1 c2 t
      | Speed (prob, prop, apply_to) ->
          if Random.float 1. < prob then
            if apply_to then change_stats { c1 with speed = c1.speed *. prop } c2 t
            else change_stats c1 { c2 with speed = c2.speed *. prop } t
          else change_stats c1 c2 t
      | AccuracyS (prob, prop, apply_to) ->
          if Random.float 1. < prob then
            if apply_to then change_stats { c1 with accuracy = c1.accuracy *. prop } c2 t
            else change_stats c1 { c2 with accuracy = c2.accuracy *. prop } t
          else change_stats c1 c2 t
      | Evasiveness (prob, prop, apply_to) ->
          if Random.float 1. < prob then
            if apply_to then
              if c1.paralyze then change_stats c1 c2 t
              else change_stats { c1 with evasiveness = c1.evasiveness *. prop } c2 t
            else if c2.paralyze then change_stats c1 c2 t
            else change_stats c1 { c2 with evasiveness = c2.evasiveness *. prop } t
          else change_stats c1 c2 t
    end

let reset_stats creature = function
  | true ->
      {
        creature with
        attack = base_attack creature;
        defense = base_defense creature;
        speed = base_speed creature;
        confuse = None;
        accuracy = 1.;
        evasiveness = 1.;
      }
  | false ->
      {
        creature with
        attack = base_attack creature;
        defense = base_defense creature;
        speed = base_speed creature;
        accuracy = 1.;
        evasiveness = 1.;
      }

let apply_paralysis creature =
  match creature.paralyze with
  | false -> (creature, false)
  | true -> begin
      match Random.bool () with
      | true -> (creature, true)
      | false -> (creature, false)
    end

let apply_poison creature =
  match creature.poison with
  | true -> dead_tolerance { creature with hp = 0.95 *. creature.hp }
  | false -> creature

let apply_confusion creature =
  match creature.confuse with
  | None -> (creature, false)
  | Some turns -> (
      let prob_snap_out = if turns < 5 then 0.5 +. (float_of_int turns *. 0.1) else 0.999 in
      let rng_snap_out = Random.float 1. in
      match rng_snap_out < prob_snap_out with
      | true -> ({ creature with confuse = None }, false)
      | false ->
          let attack_yourself_hp =
            match Random.bool () with
            | true -> creature.hp *. 0.9
            | false -> creature.hp
          in
          ( dead_tolerance { creature with hp = attack_yourself_hp; confuse = Some (turns + 1) },
            true ))

let inflict_status c = function
  | Stun prob -> (c, Random.float 1. < prob)
  | Paralyze prob -> begin
      match Random.float 1. < prob with
      | true ->
          ( { c with paralyze = true; speed = c.speed *. 0.75; evasiveness = 0. },
            Random.bool () )
      | false -> (c, false)
    end
  | Confuse prob -> begin
      match Random.float 1. < prob with
      | true ->
          let initial_confused = { c with confuse = Some 0 } in
          apply_confusion initial_confused
      | false -> (c, false)
    end
  | Poison prob -> (dead_tolerance { c with poison = Random.float 1. < prob }, false)
