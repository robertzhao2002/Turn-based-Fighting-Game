type effect =
  | Poison
  | Paralyze
  | Confuse

type stat_change =
  | Attack of float
  | Defense of float
  | Speed of float

type move_variant =
  | Damaging
  | Status of effect
  | StatChange of stat_change

type move_type =
  | Water
  | Fire
  | Magic

type t = {
  name : string;
  base_power : int;
  base_accuracy : int;
  uses : int;
  mtype : move_type;
  mvariant : move_variant;
}

let name m = m.name

let move_type_of m = m.mtype

let power m = m.base_power

let accuracy m = m.base_accuracy

let uses m = m.uses
