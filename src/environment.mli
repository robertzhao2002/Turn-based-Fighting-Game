type t

type action =
  | Switch of Creature.t * Creature.t
  | MoveUsed of Creature.t * Move.t
  | Revive of Creature.t
  | Surrender

val go : t -> action -> t
(** [go env action] is the state of the game environment after 1 turn. Either a winner is
    determined or the game continues. *)
