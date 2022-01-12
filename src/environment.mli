exception InvalidAction

type action =
  | Switch of string
  | MoveUsed of string
  | Revive of string
  | Surrender

type result =
  | Battle
  | CreatureDead of bool
  | Trainer1Win of string * string
  | Trainer2Win of string * string

type t = {
  trainer1 : Trainer.t * action option;
  trainer2 : Trainer.t * action option;
  match_result : result;
  turn : bool;
}

val init : Trainer.t -> Trainer.t -> t
(** [init t1 t2] is an environment with [env.trainer1 = t1] and [env.trainer2 = t2]. *)

val trainer_from_turn : t -> Trainer.t
(** [trainer_from_turn env] is either [env.trainer1] if [env.turn = true] or [env.trainer2] if
    [env.turn = false]. *)

val other_trainer : t -> Trainer.t
(** [other_trainer env] is the trainer that is not returned by [trainer_from_turn env]. If
    [env.turn = true] then the value is [env.trainer2]. If [env.turn = false] then the value if
    [env.rainer1]. *)

val result_of : t -> result
(** [result_of env] is the current state of the match. Either the match is in progress
    ([Battle] will be returned), or a trainer has won ([Trainer1Win] or [Trainer2Win] will be
    returned based on the victory of the corresponding trainer). *)

val dead_action : t -> Creature.t -> t
(** [dead_action env creature] is [env] after [creature] is either revived or switched out. *)

val next : t -> action -> t
(** [next env action1] is the state of the game environment after 1 turn by the trainer
    determined by [env.turn]. The trainer can either choose to switch to a new creature, revive
    a dead creature, use a move, or surrender. *)
