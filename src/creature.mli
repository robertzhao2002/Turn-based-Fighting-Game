exception InvalidMove
(** [InvalidMove] is raised when a creature uses a non-existent move, or a move that isn't in
    its moveset. *)

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
  revived : bool;
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

val base_hp : t -> float
(** [base_hp c] is the base hp of creature [c]. This is the amount of hitpoints [c] has. *)

val base_attack : t -> float
(** [base_attack c] is the base attack of creature [c]. This determines how much damage [c] can
    deal when using a given move. *)

val base_defense : t -> float
(** [base_defense c] is the base defense of creature [c]. This determines how easy/hard it is
    for [c] to lose hp. *)

val base_speed : t -> float
(** [base_speed c] is the base speed of creature [c]. This determines who goes first in a given
    turn. *)

val reset_stats : t -> bool -> t
(** [reset_stats c b] is creature [c] with all stats reverted to their original base values.
    This is useful when the creature is switched out by the trainer. If [b] is [true], then
    confusion is removed. Otherwise, just return creature [c] with the same status conditions
    but with stats reset. *)

val change_stats : t -> t -> Move.stat_change list -> t * t
(** [change_stats c1 c2 s] returns a tuple of [c1] and [c2] after all of the stat changes in
    [s]. The stats will be changed by the amounts given in [s] of either creature [c1] or [c2]
    based on the [bool] value contained by each [Move.stat_change]. [c1] will always be
    ["yourself"] and [c2] will always be ["opponent"]. It will apply the RNG of the probability
    contained each [Move.stat_change] as well. If [s] is paralyzed, its evasiveness cannot be
    changed since attacks will always hit paralyzed creatures. *)

val dead : t -> bool
(** [dead c] is whether or not the creature is dead. It is dead if its [hp] stat is less than
    0. Once its [hp] becomes 0, it is dead and can be revived 1 time to half health during
    battle. *)

val inflict_status : t -> Move.effect -> t * bool
(** [inflict_status c s] is creature [c] with status condition [s] from a move that has been
    used on it. There will be a RNG that determines whether or not the effect will be
    inflicted. The [bool] value in the tuple represents if the status effect blocks the turn.
    If [snd (inflict_status c s) = true] then the turn is used up and the creature cannot
    attack (stunning, 50% chance from paralysis, and attacking yourself after confusion). If
    [c] already has the given status condition, then it will apply them, rather than treating
    the status effect as an initial trigger. *)

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

val move_with_name : t -> string -> Move.t
(** [move_with_name c s] is a [Move.t] with name [s] if this move is one of creature [c]'s
    moves. Otherwise, raise [InvalidMove]. *)

val creature_string : t -> string
(** [creature_string c] is [c] name, hp as a percentage, status effects, stat changes, and
    whether or not [c] was revived displayed as a string. If [c] is dead, then [DEAD] will be
    next to its name.

    Codes

    - [HP]: HP
    - [ATK]: ATTACK
    - [DEF]: DEFENSE
    - [SPD]: SPEED
    - [PSN]: POISON
    - [PAR]: PARALYZE

    For the stat changes, the number of plus/minus is based on the ratio of the current value
    of the stat to the base stat. If this value is less than 1, then we can think of the value
    as [1/n] of the base value. [n] will be truncated to an integer and that number of [-] will
    be prepended to the stat. If this value is greater than 1, then we can think of the value
    as [n] times the base value. [n] will be truncated to an integer and that number of [+]
    will be prepended to the stat.

    Examples

    - {[
        creature_A: 69.4% HP; PSN; PAR; CONFUSE; ++ATK; -DEF; +++SPD; -ACCURACY; +EVASIVENESS; REVIVED
      ]}
    - {[ creature_B: DEAD ]} *)

val creature_moves_string : t -> string
(** [creature_moves_string c] is an abbreviated version of all of [c]'s moves as strings. It
    will include the name and the uses as a fraction.

    Examples

    - {[
        CreatureA's Moves
        - MoveA: 6/6 uses
        - MoveB: No uses left
        - MoveC: 3/5 uses
      ]}
    - {[
        CreatureB's Moves
        - MoveA: 2/6 uses
        - MoveB: No uses left
      ]}*)
