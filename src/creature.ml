open Yojson.Basic.Util
open Move
open Random
open Typematchup

let () = Random.self_init ()

let json_suffix = ".json"

exception InvalidMove

type t = {
  name : string;
  creature_type : Typematchup.creature_type;
  current_hp : float;
  current_attack : float;
  current_defense : float;
  current_speed : float;
  base_hp : float;
  base_attack : float;
  base_defense : float;
  base_speed : float;
  paralyze : bool;
  confuse : int option;
  poison : bool;
  moves : Move.t list;
  revived : bool;
}

let rec initialize_creature_moves acc move_file_name = function
  | [] -> acc
  | h :: t ->
      let move_name_str = to_string h in
      let accumulate_move = init_move_with_name move_name_str move_file_name :: acc in
      initialize_creature_moves accumulate_move move_file_name t

let rec get_type_strings acc = function
  | [] -> acc
  | h :: t ->
      let type_str = to_string h in
      let accumulate_type = type_str :: acc in
      get_type_strings accumulate_type t

let type_strings_to_creature_type = function
  | [ h ] -> (type_from_string h, None, None)
  | [ h1; h2 ] -> (type_from_string h1, Some (type_from_string h2), None)
  | [ h1; h2; h3 ] ->
      (type_from_string h1, Some (type_from_string h2), Some (type_from_string h3))
  | _ -> raise (Failure "Impossible")

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

let creature_json_assoc name file_name =
  creature_json_with_name name
    (creature_json ("creatures_data" ^ Filename.dir_sep ^ file_name ^ json_suffix))

let init_creature_with_name name creature_file_name move_file_name =
  let creatures_json = creature_json_assoc name creature_file_name in
  let hp = List.assoc "hp" creatures_json |> to_float in
  let attack = List.assoc "attack" creatures_json |> to_float in
  let defense = List.assoc "defense" creatures_json |> to_float in
  let speed = List.assoc "speed" creatures_json |> to_float in
  {
    name;
    creature_type =
      List.assoc "type(s)" creatures_json
      |> to_list |> get_type_strings [] |> type_strings_to_creature_type;
    current_hp = hp;
    base_hp = hp;
    current_attack = attack;
    base_attack = attack;
    current_defense = defense;
    base_defense = defense;
    current_speed = speed;
    base_speed = speed;
    paralyze = false;
    confuse = None;
    poison = false;
    moves =
      List.assoc "moves" creatures_json
      |> to_list
      |> initialize_creature_moves [] move_file_name;
    revived = false;
  }

let coerce_health creature =
  if creature.current_hp < 0.001 then { creature with current_hp = 0. }
  else
    let base_hp = creature.base_hp in
    if creature.current_hp > base_hp then { creature with current_hp = base_hp } else creature

let dead c = c.current_hp <= 0.001

let inflict_damage c d =
  let damaged = { c with current_hp = c.current_hp -. d } in
  match dead damaged with
  | true -> { damaged with current_hp = 0. }
  | false -> damaged

let rec change_stats c1 c2 = function
  | [] -> (c1, c2)
  | h :: t -> begin
      match h with
      | Attack (prob, prop, apply_to) ->
          if Random.float 1. < prob then
            if apply_to then
              change_stats { c1 with current_attack = c1.current_attack *. prop } c2 t
            else change_stats c1 { c2 with current_attack = c2.current_attack *. prop } t
          else change_stats c1 c2 t
      | Defense (prob, prop, apply_to) ->
          if Random.float 1. < prob then
            if apply_to then
              change_stats { c1 with current_defense = c1.current_defense *. prop } c2 t
            else change_stats c1 { c2 with current_defense = c2.current_defense *. prop } t
          else change_stats c1 c2 t
      | Speed (prob, prop, apply_to) ->
          if Random.float 1. < prob then
            if apply_to then
              change_stats { c1 with current_speed = c1.current_speed *. prop } c2 t
            else change_stats c1 { c2 with current_speed = c2.current_speed *. prop } t
          else change_stats c1 c2 t
    end

let reset_stats creature reset_confusion =
  let reset_creature =
    {
      creature with
      current_attack = creature.base_attack;
      current_defense = creature.base_defense;
      current_speed = creature.base_speed;
    }
  in
  match reset_confusion with
  | true -> { reset_creature with confuse = None }
  | false -> reset_creature

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
  | true -> coerce_health { creature with current_hp = 0.95 *. creature.current_hp }
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
            | true -> creature.current_hp *. 0.9
            | false -> creature.current_hp
          in
          ( coerce_health
              { creature with current_hp = attack_yourself_hp; confuse = Some (turns + 1) },
            true ))

let inflict_status c = function
  | Stun prob -> (c, Random.float 1. < prob)
  | Paralyze prob -> (
      if c.paralyze then (c, Random.bool ())
      else
        match Random.float 1. < prob with
        | true ->
            ( { c with paralyze = true; current_speed = c.current_speed *. 0.75 },
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
  | Poison prob -> (coerce_health { c with poison = Random.float 1. < prob }, false)

let inflict_multiple_status creature effects =
  let rec inflict_multiple_status_tr effects (current_creature, use_turn) =
    match effects with
    | [] -> (current_creature, use_turn)
    | h :: t ->
        let new_creature, turn_used = inflict_status current_creature h in
        inflict_multiple_status_tr t (new_creature, turn_used || use_turn)
  in
  inflict_multiple_status_tr effects (creature, false)

let rec find_move_with_name move_name (move_list : Move.t list) =
  match move_list with
  | [] -> raise InvalidMove
  | h :: t ->
      if String.lowercase_ascii h.name = String.lowercase_ascii move_name then h
      else find_move_with_name move_name t

let has_move creature move_name =
  let rec has_move_helper name (move_list : Move.t list) =
    match move_list with
    | [] -> false
    | h :: t ->
        if String.lowercase_ascii h.name = String.lowercase_ascii name && h.current_uses > 0
        then true
        else has_move_helper name t
  in
  has_move_helper move_name creature.moves

let use_move_with_name creature mname =
  let rec use_move_with_name_tr move_name acc (move_list : Move.t list) =
    match move_list with
    | [] -> acc
    | h :: t ->
        if String.lowercase_ascii h.name = String.lowercase_ascii move_name then
          use_move_with_name_tr move_name (use h :: acc) t
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
  if dead creature then
    Printf.sprintf "%s (%s): DEAD" creature.name
      (creature.creature_type |> creature_type_as_string)
  else
    Printf.sprintf "%s (%s): %.1f%% HP;%s%s%s%s%s%s%s" creature.name
      (creature.creature_type |> creature_type_as_string)
      (creature.current_hp /. creature.base_hp *. 100.)
      (psn_par_string creature.poison " PSN;")
      (psn_par_string creature.paralyze " PAR;")
      (confuse_string creature)
      (stat_change_string creature.current_attack creature.base_attack "ATK")
      (stat_change_string creature.current_defense creature.base_defense "DEF")
      (stat_change_string creature.current_speed creature.base_speed "SPD")
      (if creature.revived then " REVIVED" else "")

let creature_moves_string creature =
  let rec creature_moves_string_tr acc = function
    | [] -> acc
    | h :: t ->
        let prefix = "\n- " in
        let type_string = " (" ^ (h.move_type |> type_as_string) ^ ")" in
        creature_moves_string_tr
          (if h.current_uses > 0 then
           acc ^ prefix ^ h.name ^ type_string ^ ": " ^ string_of_int h.current_uses ^ "/"
           ^ string_of_int h.total_uses ^ " uses"
          else acc ^ prefix ^ h.name ^ type_string ^ ": No uses left")
          t
  in
  creature_moves_string_tr (creature.name ^ "'s Moves") creature.moves

let show_change base current =
  let ratio = current /. base in
  if ratio <= 1.03 && ratio >= 0.97 then Printf.sprintf "%.1f" current
  else Printf.sprintf "%.1f -> %.1f" base current

let creature_stats_string creature =
  Printf.sprintf "%s's Stats\n- TYPE: %s\n- HP: %.1f/%.1f\n- ATK: %s\n- DEF: %s\n- SPD: %s"
    creature.name
    (creature.creature_type |> creature_type_as_string)
    creature.current_hp creature.base_hp
    (show_change creature.base_attack creature.current_attack)
    (show_change creature.base_defense creature.current_defense)
    (show_change creature.base_speed creature.current_speed)
