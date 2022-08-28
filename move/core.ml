type t = {
  name : string;
  move_type : Types.Core.t;
  base_power : int;
  current_uses : int;
  max_uses : int;
  stat_changes : Effects.StatChange.t list;
  effects : Effects.StatusEffect.prob list;
}

exception NoMoreUses

let init_move_with_name move_name =
  let module MoveData = struct
    let main_field_name = "moves"

    let object_name = move_name

    let json_file = "data" ^ Filename.dir_sep ^ "game_data.json"
  end in
  let module MoveJsonAdapter = Util.Json.GetData (MoveData) in
  {
    name = MoveJsonAdapter.to_string_value "name";
    move_type = MoveJsonAdapter.to_string_value "type" |> Types.Core.type_from_string;
    base_power = MoveJsonAdapter.to_int_value "base_power";
    current_uses = MoveJsonAdapter.to_int_value "max_uses";
    max_uses = MoveJsonAdapter.to_int_value "max_uses";
    stat_changes =
      MoveJsonAdapter.to_json_object_list_value "stat_changes"
      |> List.map Effects.StatChange.Adapter.to_object;
    effects =
      MoveJsonAdapter.to_json_object_list_value "effects"
      |> List.map Effects.StatusEffect.Adapter.to_object;
  }

let use m =
  match m.current_uses with
  | 0 -> raise NoMoreUses
  | uses -> { m with current_uses = uses - 1 }

let move_string move =
  Printf.sprintf "%s\nType: %s\nUses: %d/%d\nBase Power: %d; %s%s" move.name
    (move.move_type |> Types.Core.type_as_string)
    move.current_uses move.max_uses move.base_power
    (Effects.StatusEffect.effects_as_string move.effects)
    (Effects.StatChange.stat_changes_as_string move.stat_changes)