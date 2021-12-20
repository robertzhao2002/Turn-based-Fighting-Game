(** The type representing the move's type (e.g. Water, Fire, Magic). *)
type move_type =
  | Water
  | Fire
  | Magic

type t
(** The abstract type representing a creature that can be used. *)

val name : t -> string
(** [name m] is the name of move [m]. *)

val move_type_of : t -> move_type
(** [move_type_of m] is the type of move [m] (e.g. [Water], [Fire], [Magic], etc.). *)

val power : t -> int
(** [power m] is the base power of move [m]. This determines how much damage [m] can
    potentially do. Moves with higher base power will do more damage when used by the same
    creature. *)

val accuracy : t -> int
(** [accuracy m] is the base accuracy of move [m]. This determines how likely the move will hit
    the target. If it hits the target, it will do damage based on the base power and base
    attack stat of the creature. If it does not hit (misses), then 0 damage is done. *)

val uses : t -> int
(** [uses m] is the number of times move [m] can be used in a battle. Each move has a
    predetermined number of uses. Every time u use [m], this number decrements. Whenever
    [uses m] is 0, then [m] cannot be used anymore. When a creature has no more moves to use,
    it automatically dies, even if it is at full hp. *)
