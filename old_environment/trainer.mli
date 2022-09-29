exception NoMoreRevives
(** [NoMoreRevives] is raised when the trainer has used their single revive during the match. *)

exception InvalidCreature
(** [InvalidCreature] is raised when the trainer attempts to perform operations on a creature
    that does not belong to them or doesn't exist. This is a fail state. *)

exception CreatureNotDead of Creature.t
(** [CreatureNotDead c] is raised when a trainer attempts to use a revive on a creature that
    isn't dead. *)

exception NoCreaturesDead
(** [NoCreaturesDead] is raised when a trainer attempts to use a revive when none of their
    creatures are dead. *)

type t
(** The abstract type representing a trainer. Trainers own 3 creatures and have 1 revive. *)

val init_trainer : string -> Creature.t -> Creature.t -> Creature.t -> t
(** [init_trainer n c1 c2 c3] creates a trainer with name [n], creatures [c1], [c2], and [c3],
    and has 1 revive initially. All creatures have full health, no status effects, and no stat
    changes. All moves have maximum uses. *)

val name : t -> string
(** [name t] is the name of trainer [t]. *)

val modify_creature : t -> Creature.t -> t
(** [modify_creature t c] is [t] with [t.creature1 = c]. *)

val has_revive : t -> bool
(** [has_revive t] is the opposite of [t.revive_used], aka [not t.revive_used]. **)

val all_dead : t -> bool
(** [all_dead t] is whether or not all 3 of trainer [t]'s creatures are dead. If any one of
    them have more than 0 hp, then this function returns [false]. *)

val creature_of : t -> Creature.t
(** [creature_of t] is the first creature of trainer [t]. It is the creature that is currently
    on the battle environment. *)

val has_creature : t -> string -> bool
(** [has_creature t c] is [true] if [c] is either the name of [t.creature1], [t.creature2], or
    [t.creature3]. It returns [false] otherwise. *)

val creature_not_in_battle : t -> string -> bool
(** [creature_not_in_battle t c] is [true] if [c] is either the name of [t.creature2] or
    [t.creature3]. It returns [false] otherwise. *)

val creature_with_name : t -> string -> Creature.t
(** [creature_with_name tr n] is a creature with name [n] if it is one of [tr.creature1],
    [tr.creature2], or [tr.creature3]. Otherwise, it raises [InvalidCreature]. *)

val use_move : t -> string -> t
(** [use_move t c m] is the result of trainer [t] using move [m] of creature [c]. This can
    raise [Creature.InvalidMove] or [Move.NoMoreUses] based on those corresponding conditions. *)

val switch : t -> string -> t
(** [switch t n] is the result of trainer [t] switching to one of [trainer.creature2] or
    [trainer.creature3] with name [n]. As a result, the creature with name [n] should now be
    [trainer.creature1], and the old [trainer.creature1] has been placed in the vacant slot. If
    [n] does not correspond to a creature name or if the creature corresponding to [n] is dead,
    [InvalidCreature] is raised. *)

val revive : t -> string -> t
(** [revive t n] revives creature with name [n] if [n] has 0 hp (dead) and trainer [t] has a
    revive left. When a creature is revived, it is essentially like new except it has half its
    original health. All of its moves have maximum uses, status conditions are cleared, and all
    stat changes are reset. Reviving uses up a turn. *)

val trainer_string : t -> string
(** [trainer_string t] is the trainer's name along with whether or not the revive has been used
    and all of their creatures. [trainer.creature1] will have their moves and uses (as
    fractions) shown below the list of 3 trainers. If the revive has not been used, dead
    creatures will show up as dead. If the revive has been used, dead creatures will not be
    shown.

    Examples

    - {[
        Trainer1
        REVIVE
        Creature1 (type1/type2): 100.0% HP; CONFUSE; (IN BATTLE)
        Creature2 (type1): DEAD;
        Creature3 (type1/type2/type3): 100.0% HP; PSN;
        Creature1's Moves
        - MoveA (type1): 2/2 uses
        - MoveB (type2): No uses left
      ]}
    - {[
        Trainer1
        Creature1 (type1/type2): 100.0% HP; CONFUSE; (IN BATTLE)
        Creature3 (type1/type2/type3): 100.0% HP; PSN;
        Creature1's Moves
        - MoveA (type1): 2/2 uses
        - MoveB (type2): No uses left
      ]}*)
