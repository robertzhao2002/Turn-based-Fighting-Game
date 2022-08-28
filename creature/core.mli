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

val coerce_health : t -> t