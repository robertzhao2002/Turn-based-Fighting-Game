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
  paralyze : bool;
  confuse : int option;
  poison : bool;
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

val reset_stats : t -> bool -> t
(** [reset_stats c b] is creature [c] with all stats reverted to their original base values.
    This is useful when the creature is switched out by the trainer. If [b] is [true], then
    confusion is removed. Otherwise, just return creature [c] with the same status conditions
    but with stats reset. *)

val dead : t -> bool
(** [dead c] is whether or not the creature is dead. It is dead if its [hp] stat is greater
    than 0. Once its [hp] becomes 0, it is dead and can be revived 1 time to half health during
    battle. *)

val inflict_status : t -> Move.effect -> t * bool
(** [inflict_status c s] is creature [c] with status condition [s] from a move that has been
    used on it. There will be a RNG that determines whether or not the effect will be
    inflicted. The [bool] value in the tuple represents if the status effect blocks the turn.
    If [snd (inflict_status c s) = true] then the turn is used up and the creature cannot
    attack (stunning, 50% chance from paralysis, and attacking yourself after confusion). *)

val apply_poison : t -> t
(** [apply_poison c] is creature [c] with 5% less hp if [c.poison] is [true]. If [c] is not
    poisoned, then [c] is returned. *)

val apply_confusion : t -> t * bool
(** [apply_confusion c] returns a result of a creature and a [bool] value that represents
    whether or not the turn was used. If the creature is not confused, [(c, false)] is
    returned. If [c] is confused, there will be an RNG to determine whether [c] will snap out
    or stay confused. If [c] snaps out, [(c, false)] is returned and [c] is free to use a move
    without risking any confusion damage. If [c] stays confused, the turn counter in
    [c.confuse] will be incremented. There is a 50% chance that [c] will attack itself and
    [true] will be returned in the result, which means that the turn has been used up. *)

val apply_paralysis : t -> t * bool
(** [apply_paralysis c] returns a result of a creature and a [bool] value that represents
    whether or not the turn was used. If [c] is not paralyzed, [(c, false)] will be returned.
    The paralysis RNG will determine whether or not the creature will be able to use a move.
    [(c, true)] will be returned if the creature is afflicted by paralysis. *)

val inflict_damage : t -> float -> t
(** [inflict_damage c d] is creature [c] with [d] less hp. If subtracting [d] hp causes [d] to
    die ([d > c.hp]), then return [c] with 0 hp. *)

val change_stats : t -> Move.stat_change list -> t
(** [change_stats c s] changes creature [c]'s stats by the amounts given in [s]. If [s] is
    paralyzed, its evasiveness cannot be changed. Attacks will always hit. *)
