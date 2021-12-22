(** The type representing the current status condition that the creature may be in. *)
type status =
  | Poison
  | Confuse
  | Paralyze

type t = {
  name : string;
  hp : int;
  attack : int;
  defense : int;
  speed : int;
  status : status option;
  moves : Move.t list;
}
(** The type representing the current state of a creature. The functions below all represent
    its base stats, but calling a property of this record will give the current value (which
    could change due to stat changing moves). *)

val init_creature_with_name : string -> t
(** [init_creature_with_name n] creates a [Creature] type with name [n]. It has no status
    condition, and all of its base stats are unchanged based on [data/creatures.json]. It has
    full hp. *)

val name : t -> string
(** [name c] is the name of creature [c]. *)

val hp : t -> int
(** [hp c] is the base hp of creature [c]. This is the amount of hitpoints [c] has. *)

val attack : t -> int
(** [attack c] is the base attack of creature [c]. This determines how much damage [c] can deal
    when using a given move. *)

val defense : t -> int
(** [defense c] is the base defense of creature [c]. This determines how easy/hard it is for
    [c] to lose hp. *)

val speed : t -> int
(** [speed c] is the base speed of creature [c]. This determines who goes first in a given
    turn. *)

val status_of : t -> status option
(** [status_of c] is the current status effect on the creature. This can be: [Poison],
    [Paralyze], or [Confuse]. Returns [None] if the creature has no status effect on it
    currently. *)

val dead : t -> bool
(** [dead c] is whether or not the creature is dead. It is dead if its [hp] stat is greater
    than 0. Once its [hp] becomes 0, it is dead and can be revived 1 time to half health during
    battle. *)
