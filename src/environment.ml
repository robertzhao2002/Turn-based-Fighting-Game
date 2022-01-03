open Trainer
open Random
open Move

let () = Random.self_init ()

type action =
  | Switch of Creature.t * Creature.t
  | MoveUsed of Creature.t * Move.t
  | Revive of Creature.t
  | Surrender

type game_mode =
  | Random of bool (* the boolean will represent single- or 2- player *)
  | NonRandom of bool

type result =
  | Battle
  | Trainer1Win of string
  | Trainer2Win of string

type t = {
  trainer1 : Trainer.t;
  trainer2 : Trainer.t;
  match_result : result;
  turn : bool;
}

let env_turn env =
  match env.turn with
  | true -> env.trainer1
  | false -> env.trainer2

let result_of env =
  if all_dead env.trainer1 then Trainer2Win (Trainer.name env.trainer2)
  else if all_dead env.trainer2 then Trainer1Win (Trainer.name env.trainer1)
  else Battle

let damage env move =
  let trainer_creature, opponent_creature =
    match env.turn with
    | true -> (creature_of env.trainer1, creature_of env.trainer2)
    | false -> (creature_of env.trainer2, creature_of env.trainer1)
  in
  let damage_output = trainer_creature.attack *. float_of_int move.power in
  match move.accuracy with
  | Accuracy a ->
      let accuracy_rng = Random.float 1. in
      if accuracy_rng < a then damage_output else 0.
  | Guarantee -> damage_output

let determine_move trainer1 trainer2 =
  let trainer1_creature_speed = (creature_of trainer1).speed in
  let trainer2_creature_speed = (creature_of trainer2).speed in
  if trainer1_creature_speed > trainer2_creature_speed then true (* true is trainer1 turn *)
  else if trainer2_creature_speed > trainer1_creature_speed then false
    (* false is trainer2 turn *)
  else Random.bool ()

let init t1 t2 =
  { trainer1 = t1; trainer2 = t2; turn = determine_move t1 t2; match_result = Battle }

let go env = function
  | Switch (c1, c2) -> env
  | MoveUsed (creature, move) -> env
  | Revive c -> env
  | Surrender -> env
