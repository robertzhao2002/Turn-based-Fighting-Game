type t

type action =
  | Switch of string
  | MoveUsed of string
  | Revive of string
  | Surrender

type result =
  | Battle
  | Trainer1Win of string
  | Trainer2Win of string

val result_of : t -> result
(** [result_of env] is the current state of the match. Either the match is in progress
    ([Battle] will be returned), or a trainer has won ([Trainer1Win] or [Trainer2Win] will be
    returned based on the victory of the corresponding trainer). *)

val next : t -> action -> action -> t
(** [next env action1 action2] is the state of the game environment after 1 turn by each
    trainer. During this sequence, either a winner is determined or the game continues.
    [action1] is the action performed by [trainer1], and [action2] is the action performed by
    [trainer2]. Both of these actions will be processed by [env] and the faster one will go
    first. *)
