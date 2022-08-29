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

val init_move_with_name : string -> t

val use : t -> t

val as_string : t -> string