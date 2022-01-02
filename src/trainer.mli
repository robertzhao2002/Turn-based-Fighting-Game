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

type trainer_turn =
  | Switch of Creature.t * Creature.t
  | MoveUsed of Creature.t * Move.t
  | StatusEffectBlocked
  | Revive of Creature.t
  | Surrender

type t
(** The abstract type representing a trainer. Trainers own 3 creatures and have 1 revive. *)

val init_trainer : string -> Creature.t -> Creature.t -> Creature.t -> t
(** [init_trainer n c1 c2 c3] creates a trainer with name [n], creatures [c1], [c2], and [c3],
    and has 1 revive initially. All creatures have full health, no status effects, and no stat
    changes. All moves have maximum uses. *)

val name : t -> string
(** [name t] is the name of trainer [t]. *)

val all_dead : t -> bool
(** [all_dead t] is whether or not all 3 of trainer [t]'s creatures are dead. If any one of
    them have more than 0 hp, then this function returns [false]. *)

val creature_of : t -> Creature.t
(** [creature_of t] is the first creature of trainer [t]. It is the creature that is currently
    on the battle environment. *)

val has_creature : t -> Creature.t -> bool
(** [has_creature t c] is [true] if [c] is either [t.creature1], [t.creature2], or
    [t.creature3]. It returns [false] otherwise. *)

val use_move : t -> Creature.t -> Move.t -> trainer_turn * t
(** [use_move t c m] is the result of trainer [t] using move [m] of creature [c]. *)

val switch : t -> Creature.t -> Creature.t -> trainer_turn * t
(** [switch t c1 c2] is the result of trainer [t] switching between creature [c1] and creature
    [c2]. [c2] is now on the battlefield, and [c1]'s health is unchanged. [c1] will no longer
    be confused, all stat changes are reset, but poison/paralysis remains. *)

val revive : t -> Creature.t -> trainer_turn * t
(** [revive t c] revives creature [c] if [c] has 0 hp (dead) and trainer [t] has a revive left.
    When a creature is revived, it is essentially like new except it has half its original
    health. All of its moves have maximum uses, status conditions are cleared, and all stat
    changes are reset. Reviving uses up a turn. *)

val surrender : t -> trainer_turn * t
(** [surrender t] is the turn of trainer [t] when they choose to surrender. *)

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
        Creature1: 100.0% HP; CONFUSE; (IN BATTLE)
        Creature2: DEAD;
        Creature3: 100.0% HP; PSN;
        Creature1's Moves
        - MoveA: 2/2 uses
        - MoveB: No uses left
      ]}
    - {[
        Trainer1
        Creature1: 100.0% HP; CONFUSE; (IN BATTLE)
        Creature3: 100.0% HP; PSN;
        Creature1's Moves
        - MoveA: 2/2 uses
        - MoveB: No uses left
      ]}*)
