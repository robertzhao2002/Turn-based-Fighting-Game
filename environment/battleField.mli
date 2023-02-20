exception InvalidAction
(** [InvalidAction] is the error state of the environment. This can represent things like:
    attempting to switch out to a dead creature, attempting to revive twice, etc. *)

(** [action] represents the things a player can do during their turn. Performing any of these
    actions will use up their turn.

    - [Switch "creature2"] represents switching to a creature with
      [creature.name = "creature2"]
    - [MoveUsed "move1"] represents the creature in battle using ["move1"]
    - [Revive "creature_dead"] represents reviving a creature with
      [creature.name = "creature_dead"]
    - [Surrender] represents forfetting and giving the opponent the victory *)
type action =
  | Switch of string
  | MoveUsed of string
  | Revive of string
  | Surrender

(** [result] represents the different states that the battle environment can be in.

    - [Battle] is the state when no trainer has all 3 creatures dead at a given time or when a
      trainer has not surrendered
    - [CreatureDead true | false] is the state when either [env.trainer1] or [env.trainer2] has
      a creature that has been killed during the current turn. Thus, they are forced to send a
      new creature out for the next turn. The [bool] value represents which trainer had their
      battling creature killed.
    - [Trainer1Win "winner", "loser"] is the state when [env.trainer1] has won. The strings
      represent each trainer's name: winner and loser, respectively.
    - [Trainer2Win "winner", "loser"] is the state when [env.trainer2] has won. The strings
      represent each trainer's name: winner and loser, respectively.

    NOTE: there cannot be any ties in this game because the moment a trainer has all 3
    creatures dead, a winner is determined. For example, if [env.trainer1] has a poisoned
    creature on the verge of dying (their only creature left) but uses a move to kill the last
    creature of [env.trainer2], [env.trainer1] is the winner, and the result is
    [Trainer1Win "trainer1_name" "trainer2_name"]. The poison damage is always taken at the end
    of each turn if a winner has not been determined.

    Furthermore, if a trainer has not used their revive but all 3 creatures have died, they
    have lost the game. A winner and loser is defined the instant a trainer has all 3 creatures
    dead. *)
type result =
  | Battle
  | CreatureDead of bool
  | Trainer1Win of string * string
  | Trainer2Win of string * string

type t = {
  trainer1 : Trainer.Core.t * action option;
  trainer2 : Trainer.Core.t * action option;
  match_result : result;
  turn : bool;
}
(** [Environment.Core.t] represents the current state of the environment. [trainer1] and
    [trainer2] represent Player 1 and Player2, respectively, as well as the actions that they
    will take. At the beginning of each pair of turns, those values will be [None].
    [match_result] is the current status of the match, each possibility explained above. [turn]
    represents the turn of the environment, [true] and [false] for Player 1 and Player 2,
    respectively. When it is a player's turn, they must perform an action. *)

val init : Trainer.Core.t -> Trainer.Core.t -> t
(** [init t1 t2] is an environment with [env.trainer1 = t1] and [env.trainer2 = t2]. *)

val trainer_from_turn : t -> Trainer.Core.t
(** [trainer_from_turn env] is either [env.trainer1] if [env.turn = true] or [env.trainer2] if
    [env.turn = false]. *)

val other_trainer : t -> Trainer.Core.t
(** [other_trainer env] is the trainer that is not returned by [trainer_from_turn env]. If
    [env.turn = true] then the value is [env.trainer2]. If [env.turn = false] then the value if
    [env.rainer1]. *)

val result_of : t -> result
(** [result_of env] is the current state of the match. Either the match is in progress
    ([Battle] will be returned), or a trainer has won ([Trainer1Win] or [Trainer2Win] will be
    returned based on the victory of the corresponding trainer). *)

val dead_action : t -> Creature.Core.t -> t
(** [dead_action env creature] is [env] after [creature] is either revived or switched out. *)

val next : t -> action -> t
(** [next env action1] is the state of the game environment after 1 turn by the trainer
    determined by [env.turn]. The trainer can either choose to switch to a new creature, revive
    a dead creature, use a move, or surrender. *)
