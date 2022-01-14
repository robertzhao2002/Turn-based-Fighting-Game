(** [Typematchup.t] represents the different creature and move types. *)
type t =
  | Type1
  | Type2
  | Type3
  | Type4
  | Type5
  | Type6

type creature_type = t * t option * t option
(** [creature_type] represents a collection of types that a creature can be. *)

val type_matchup_factor : t * t -> float
(** [type_matchup_factor (offense, defense)] is the value corresponding when a move of
    [offense] type is used on a creature with [defense] type.

    Values:

    - [2.0] -> super effective
    - [1.0] -> normal damage
    - [0.5] -> not very effective
    - [0] -> no effect *)

val multiple_type_matchup : t -> t * t option * t option -> float
(** [multiple_type_matchup offense (type1, type2 option, type3 option)] is the value
    corresponding to when a move with type [offense] attacks a creature, which can have up to 3
    [Typematchup.t] types. The first one is guaranteed, but the next 2 are optional. *)
