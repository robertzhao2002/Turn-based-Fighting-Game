type t = {
  name : string;
  creature_type : Types.CreatureType.t;
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
  moves : Move.Core.t list;
  revived : bool;
}

exception InvalidMove

let init_creature_with_name creature_name =
  let module CreatureData = struct
    let main_field_name = "creatures"

    let object_name = creature_name

    let json_file = "data" ^ Filename.dir_sep ^ "game_data.json"
  end in
  let module CreatureJsonAdapter = Util.Json.GetData (CreatureData) in
  let hp = CreatureJsonAdapter.to_float_value "hp" in
  let attack = CreatureJsonAdapter.to_float_value "attack" in
  let defense = CreatureJsonAdapter.to_float_value "defense" in
  let speed = CreatureJsonAdapter.to_float_value "speed" in
  {
    name = CreatureJsonAdapter.to_string_value "name";
    creature_type =
      CreatureJsonAdapter.to_string_list_value "type(s)" |> Types.CreatureType.from_string_list;
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
      CreatureJsonAdapter.to_string_list_value "moves"
      |> List.map Move.Core.init_move_with_name;
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

let use_move_with_name creature mname =
  let rec use_move_with_name_tr move_name acc (move_list : Move.Core.t list) =
    match move_list with
    | [] -> acc
    | h :: t ->
        if String.lowercase_ascii h.name = String.lowercase_ascii move_name then
          use_move_with_name_tr move_name (Move.Core.use h :: acc) t
        else use_move_with_name_tr move_name (h :: acc) t
  in
  { creature with moves = use_move_with_name_tr mname [] creature.moves }

let creature_string creature =
  if dead creature then
    Printf.sprintf "%s (%s): DEAD" creature.name
      (creature.creature_type |> Types.CreatureType.type_as_string)
  else
    Printf.sprintf "%s (%s): %.1f%% HP;%s%s%s%s%s%s%s" creature.name
      (creature.creature_type |> Types.CreatureType.type_as_string)
      (creature.current_hp /. creature.base_hp *. 100.)
      (StatusEffect.psn_par_string creature.poison " PSN;")
      (StatusEffect.psn_par_string creature.paralyze " PAR;")
      (StatusEffect.confuse_string creature.confuse)
      (Stats.stat_change_string creature.current_attack creature.base_attack "ATK")
      (Stats.stat_change_string creature.current_defense creature.base_defense "DEF")
      (Stats.stat_change_string creature.current_speed creature.base_speed "SPD")
      (if creature.revived then " REVIVED" else "")

let creature_moves_string creature =
  let rec creature_moves_string_tr acc = function
    | [] -> acc
    | h :: t ->
        let move : Move.Core.t = h in
        let prefix = "\n- " in
        let type_string = " (" ^ (move.move_type |> Types.Core.type_as_string) ^ ")" in
        creature_moves_string_tr
          (if h.current_uses > 0 then
           acc ^ prefix ^ h.name ^ type_string ^ ": " ^ string_of_int h.current_uses ^ "/"
           ^ string_of_int move.max_uses ^ " uses"
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
    (creature.creature_type |> Types.CreatureType.type_as_string)
    creature.current_hp creature.base_hp
    (show_change creature.base_attack creature.current_attack)
    (show_change creature.base_defense creature.current_defense)
    (show_change creature.base_speed creature.current_speed)