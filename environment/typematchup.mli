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

val multiple_type_matchup : t -> creature_type -> float
(** [multiple_type_matchup offense (type1, type2 option, type3 option)] is the value
    corresponding to when a move with type [offense] attacks a creature, which can have up to 3
    [Typematchup.t] types. The first one is guaranteed, but the next 2 are optional. *)

val same_type_bonus : t -> creature_type -> float
(** [same_type_bonus mt ct] is 1.25 if any of the [Typematchup.t] in [ct] is equal to [mt].
    Otherwise, the value is 1.0. *)

val effectiveness_as_string : float -> string
(** [effectiveness_as_string f] is [super effective] if [f >= 2.0]. It is [not very effective]
    if [f <= 0.5]. It is [no effect] if [f = 0]. Otherwise, it is the empty string. *)

val type_from_string : string -> t
(** [type_from_string s] is the [Typematchup.t] value corresponding to [s]. [s] will
    automatically be transformed into lowercase. *)

val type_as_string : t -> string
(** [type_as_string t] is [t] represented as a primitive string type. *)

val creature_type_as_string : creature_type -> string
(** [creature_type_as_string ct] is [ct] as a primitive string type in the following form.

    - 3 types: [Type1/Type2/Type3]
    - 2 types: [Type1/Type2]
    - 1 type: [Type1] *)
