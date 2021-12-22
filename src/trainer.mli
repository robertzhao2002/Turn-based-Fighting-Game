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
  | Switch of Creature.t
  | Attack of Creature.t * Move.t
  | Surrender

type t

val init_trainer : string -> Creature.t -> Creature.t -> Creature.t -> t
(** [init_trainer n c1 c2 c3] creates a trainer with name [n], creatures [c1], [c2], and [c3],
    and has 1 revive initially. All creatures have full health, no status effects, and no stat
    changes. All moves have maximum uses. *)

val revive : t -> Creature.t -> t
(** [revive t c] revives creature [c] if [c] has 0 hp (dead) and trainer [t] has a revive left.
    When a creature is revived, it is essentially like new except it has half its original
    health. All of its moves have maximum uses, status conditions are cleared, and all stat
    changes are reset. Reviving uses up a turn. *)
