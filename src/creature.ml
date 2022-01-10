open Yojson.Basic.Util
open Move
open Random

let () = Random.self_init ()

exception InvalidMove

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
  revived : bool;
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
    revived = false;
  }

let name c = c.name

let base_hp c =
  let c_json = creature_json_assoc c.name in
  List.assoc "hp" c_json |> to_float

let health_within_range c =
  if c.hp < 0.001 then { c with hp = 0. }
  else
    let b_hp = base_hp c in
    if c.hp > b_hp then { c with hp = b_hp } else c

let base_attack c =
  let c_json = creature_json_assoc c.name in
  List.assoc "attack" c_json |> to_float

let base_defense c =
  let c_json = creature_json_assoc c.name in
  List.assoc "defense" c_json |> to_float

let base_speed c =
  let c_json = creature_json_assoc c.name in
  List.assoc "speed" c_json |> to_float

let dead c = c.hp <= 0.001

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
  | true -> health_within_range { creature with hp = 0.95 *. creature.hp }
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
          ( health_within_range
              { creature with hp = attack_yourself_hp; confuse = Some (turns + 1) },
            true ))

let inflict_status c = function
  | Stun prob -> (c, Random.float 1. < prob)
  | Paralyze prob -> (
      if c.paralyze then (c, Random.bool ())
      else
        match Random.float 1. < prob with
        | true ->
            ( { c with paralyze = true; speed = c.speed *. 0.75; evasiveness = 0. },
              Random.bool () )
        | false -> (c, false))
  | Confuse prob -> begin
      match c.confuse with
      | Some _ -> apply_confusion c
      | None -> begin
          match Random.float 1. < prob with
          | true ->
              let initial_confused = { c with confuse = Some 0 } in
              apply_confusion initial_confused
          | false -> (c, false)
        end
    end
  | Poison prob -> (health_within_range { c with poison = Random.float 1. < prob }, false)

let rec find_move_with_name move_name = function
  | [] -> raise InvalidMove
  | h :: t -> if Move.name h = move_name then h else find_move_with_name move_name t

let has_move creature move_name =
  let rec has_move_helper n = function
    | [] -> false
    | h :: t -> if Move.name h = n && h.uses > 0 then true else has_move_helper n t
  in
  has_move_helper move_name creature.moves

let use_move_with_name creature mname =
  let rec use_move_with_name_tr move_name acc = function
    | [] -> acc
    | h :: t ->
        if Move.name h = move_name then use_move_with_name_tr move_name (use h :: acc) t
        else use_move_with_name_tr move_name (h :: acc) t
  in
  { creature with moves = use_move_with_name_tr mname [] creature.moves }

let move_with_name creature move_name = find_move_with_name move_name creature.moves

let psn_par_string status condition =
  match status with
  | true -> condition
  | false -> ""

let confuse_string c =
  match c.confuse with
  | Some _ -> " CONFUSE;"
  | None -> ""

let rec pm_iter ch = function
  | 0 -> ""
  | n -> ch ^ pm_iter ch (n - 1)

let stat_change_string stat base str =
  let ratio = stat /. base in
  if stat = 0. then ""
  else if stat > base then
    let int_multiple = int_of_float ratio in
    " " ^ pm_iter "+" int_multiple ^ str ^ ";"
  else if stat < base then
    let int_multiple = int_of_float (1. /. ratio) in
    " " ^ pm_iter "-" int_multiple ^ str ^ ";"
  else ""

let creature_string creature =
  if dead creature then Printf.sprintf "%s: DEAD" creature.name
  else
    Printf.sprintf "%s: %.1f%% HP;%s%s%s%s%s%s%s%s%s" creature.name
      (creature.hp /. base_hp creature *. 100.)
      (psn_par_string creature.poison " PSN;")
      (psn_par_string creature.paralyze " PAR;")
      (confuse_string creature)
      (stat_change_string creature.attack (base_attack creature) "ATK")
      (stat_change_string creature.defense (base_defense creature) "DEF")
      (stat_change_string creature.speed (base_speed creature) "SPD")
      (stat_change_string creature.accuracy 1. "ACCURACY")
      (stat_change_string creature.evasiveness 1. "EVASIVENESS")
      (if creature.revived then " REVIVED" else "")

let creature_moves_string creature =
  let rec creature_moves_string_tr acc = function
    | [] -> acc
    | h :: t ->
        let prefix = "\n- " in
        creature_moves_string_tr
          (if h.uses > 0 then
           acc ^ prefix ^ Move.name h ^ ": " ^ string_of_int h.uses ^ "/"
           ^ string_of_int (total_uses h)
           ^ " uses"
          else prefix ^ Move.name h ^ ":" ^ "No uses left")
          t
  in
  creature_moves_string_tr (creature.name ^ "'s Moves") creature.moves

let show_change base current =
  let ratio = current /. base in
  if ratio <= 1.03 && ratio >= 0.97 then Printf.sprintf "%.1f" current
  else Printf.sprintf "%.1f -> %.1f" base current

let creature_stats_string creature =
  Printf.sprintf "%s's Stats\nHP: %.1f/%.1f\nATK: %s\nDEF: %s\nSPD: %s" creature.name
    creature.hp (base_hp creature)
    (show_change (base_attack creature) creature.attack)
    (show_change (base_defense creature) creature.defense)
    (show_change (base_speed creature) creature.speed)
