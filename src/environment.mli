type t

type action =
  | Switch of Creature.t * Creature.t
  | MoveUsed of Creature.t * Move.t
  | Revive of Creature.t
  | Surrender

type result =
  | Battle
  | Trainer1Win of string
  | Trainer2Win of string

val result_of : t -> result
(** [result_of env] is the current state of the match. Either the match is in progress
    ([Battle] will be returned), or a trainer has won ([Trainer1Win] or [Trainer2Win] will be
    returned based on the victory of the corresponding trainer). *)

val go : t -> action -> t
(** [go env action] is the state of the game environment after 1 turn. Either a winner is
    determined or the game continues. *)
