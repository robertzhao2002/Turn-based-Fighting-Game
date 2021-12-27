exception InvalidMove
(** [InvalidMove] is raised when a creature uses a non-existent move, or a move that isn't in
    its moveset. *)

(** The type representing the current status condition that the creature may be in.

    Status conditions are evaluated this way:

    - [Paralyze]: 50% does not do anything. In this case, skip confusion, and apply poison
      damage.
    - [Confuse]: If the creature is paralyzed and it got the 50% move *)
type status =
  | Paralyze
  | Confuse of int
  | Poison

type t = {
  name : string;
  hp : float;
  attack : float;
  defense : float;
  speed : float;
  status : status list;
  moves : Move.t list;
  accuracy : float;
  evasiveness : float;
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

val hp : t -> float
(** [hp c] is the base hp of creature [c]. This is the amount of hitpoints [c] has. *)

val attack : t -> float
(** [attack c] is the base attack of creature [c]. This determines how much damage [c] can deal
    when using a given move. *)

val defense : t -> float
(** [defense c] is the base defense of creature [c]. This determines how easy/hard it is for
    [c] to lose hp. *)

val speed : t -> float
(** [speed c] is the base speed of creature [c]. This determines who goes first in a given
    turn. *)

val status_of : t -> status list
(** [status_of c] is the current status effect on the creature. This can be: [Poison],
    [Paralyze], [Confuse], or any combination of them. The list will be sorted in the order
    that these status conditions are applied onto the creature.

    [\[Paralyze; Confuse; Poison\]] is the sorted order if a creature has all 3 conditions.

    Returns the empty list if the creature has no status effect on it currently. *)

val reset_stats : t -> bool -> t
(** [reset_stats c b] is creature [c] with all stats reverted to their original base values.
    This is useful when the creature is switched out by the trainer. If [b] is [true], then
    confusion is removed. Otherwise, just return creature [c] with the same status conditions
    but with stats reset. *)

val dead : t -> bool
(** [dead c] is whether or not the creature is dead. It is dead if its [hp] stat is greater
    than 0. Once its [hp] becomes 0, it is dead and can be revived 1 time to half health during
    battle. *)

val inflict_status : t -> status -> t
(** [inflict_status c s] is creature [c] with status condition [s]. If it did not have [s]
    before, it is added to its list of status conditions. If it already has [s], nothing is
    changed. *)

val inflict_damage : t -> float -> t
(** [inflict_damage c d] is creature [c] with [d] less hp. If subtracting [d] hp causes [d] to
    die ([d > c.hp]), then return [c] with 0 hp. *)

val change_stats : t -> Move.stat_change list -> t
(** [change_stats c s] changes creature [c]'s stats by the amounts given in [s]. *)
