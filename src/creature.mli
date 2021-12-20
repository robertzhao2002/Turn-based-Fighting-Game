(** The type representing the current status condition that the creature may be in. *)

type status =
  | Poison
  | Confuse
  | Paralyze

type t
(** The abstract type representing a creature that can be used. *)

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
