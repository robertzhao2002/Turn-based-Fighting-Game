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
(** The type representing the current state of a creature. The base stats will never change,
    but the current stats will change based on moves used during battle. *)

exception InvalidMove
(** [InvalidMove] is raised when a creature uses a non-existent move, or a move that isn't in
    its moveset. *)

val dead : t -> bool
(** [dead c] is whether or not the creature is dead. It is dead if its [hp] stat is less than
    0. Once its [hp] becomes 0, it is dead and can be revived 1 time to half health during
    battle. *)

val reset : t -> bool -> t
(** [reset c b] is creature [c] with all stats reverted to their original base values. This is
    useful when the creature is switched out by the trainer. If [b] is [true], then confusion
    is removed. Otherwise, just return creature [c] with the same status conditions but with
    stats reset. *)

val change_stats : t -> t -> Effects.StatChange.t list -> t * t
(** [change_stats c1 c2 stat_changes] returns a tuple of [c1] and [c2] after all of the stat
    changes in [s]. The stats will be changed by the amounts given in [s] of either creature
    [c1] or [c2] based on the [bool] value contained by each [Effects.StatChange.t]. [c1] will
    always be ["yourself"] and [c2] will always be ["opponent"]. It will apply the RNG of the
    probability contained each [Effects.StatChange.t] as well.*)

val use_move_with_name : t -> string -> t
(** [use_move_with_name c n] is creature [c] after a move of crature [c] with name[n] has been
    used. Raises [InvalidMove] if [n] is not one of [c]'s moves. Raises [Move.NoMoreUses] is
    the move has no uses left. *)

val as_string : t -> string
(** [as_string c] is [c] name, type(s), hp as a percentage, status effects, stat changes, and
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
        creature_A (type1/type2/type3): 69.4% HP; PSN; PAR; CONFUSE; ++ATK; -DEF; +++SPD; REVIVED
      ]}
    - {[
        creature_B (type1/type2): DEAD
      ]} *)

val stats_as_string : t -> string
(** [stats_as_string c] shows all of the base stats of [c] along with the new value of the stat
    if it has been changed. If there is no more than a 3% difference between the base and
    current value, then return the current value as a string. [base_value -> new_value]

    Examples

    - {[
        CreatureA's Stats
        - TYPE: type1/type2/type3
        - HP: 40.3/200.2
        - ATK: 100.5
        - DEF: 75.6 -> 100.3
        - SPD: 85.5 -> 80.0
      ]}*)

val moves_as_string : t -> string
(** [moves_as_string c] is an abbreviated version of all of [c]'s moves as strings. It will
    include the name and the uses as a fraction.

    Examples

    - {[
        CreatureA's Moves
        - MoveA (type1): 6/6 uses
        - MoveB (type2): No uses left
        - MoveC (type3): 3/5 uses
      ]}
    - {[
        CreatureB's Moves
        - MoveA (type1): 2/6 uses
        - MoveB (type1): No uses left
      ]}*)
