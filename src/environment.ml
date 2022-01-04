open Trainer
open Random
open Move

let () = Random.self_init ()

type action =
  | Switch
  | MoveUsed
  | Revive of string
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
  let hit_probability = trainer_creature.accuracy /. opponent_creature.evasiveness in
  let damage_output = trainer_creature.attack *. float_of_int move.power in
  match move.accuracy with
  | Accuracy a ->
      let accuracy_rng = Random.float 1. in
      if accuracy_rng < a *. hit_probability then damage_output else 0.
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

let next env action1 action2 =
  match (action1, action2) with
  | Switch, Revive creature_name ->
      let trainer2_creature = Trainer.creature_with_name env.trainer2 creature_name in
      let trainer2_revived = Trainer.revive env.trainer2 trainer2_creature in
      { env with trainer2 = trainer2_revived }
  | _, Surrender -> { env with match_result = Trainer2Win (Trainer.name env.trainer2) }
  | Surrender, _ -> { env with match_result = Trainer1Win (Trainer.name env.trainer1) }
  | _ -> raise Not_found
