open Trainer
open Random
open Move

let () = Random.self_init ()

type action =
  | Switch of string
  | MoveUsed of string
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

let result_of env =
  if all_dead env.trainer1 then Trainer2Win (Trainer.name env.trainer2)
  else if all_dead env.trainer2 then Trainer1Win (Trainer.name env.trainer1)
  else Battle

let trainer_from_turn env =
  match env.turn with
  | true -> env.trainer1
  | false -> env.trainer2

let other_trainer env =
  match env.turn with
  | true -> env.trainer2
  | false -> env.trainer1

let next_turn env = { env with turn = not env.turn }

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
      if accuracy_rng < a *. hit_probability then damage_output *. (Random.float 0.2 +. 0.9)
      else 0.
  | Guarantee -> damage_output

let determine_move trainer1 trainer2 =
  let trainer1_creature_speed = (creature_of trainer1).speed in
  let trainer2_creature_speed = (creature_of trainer2).speed in
  if trainer1_creature_speed > trainer2_creature_speed then true (* true is trainer1 turn *)
  else if trainer2_creature_speed > trainer1_creature_speed then false
    (* false is trainer2 turn *)
  else Random.bool ()

let init t1 t2 = { trainer1 = t1; trainer2 = t2; turn = true; match_result = Battle }

let dead_action env action =
  match env.turn with
  | true -> true
  | false -> false

let winner env =
  match env.turn with
  | true -> Trainer2Win (Trainer.name env.trainer2)
  | false -> Trainer1Win (Trainer.name env.trainer1)

let modify_env_turn env tr =
  if env.turn then { env with trainer1 = tr } else { env with trainer2 = tr }

let next env action1 =
  let env_turn_trainer = trainer_from_turn env in
  match action1 with
  | Switch c ->
      let tr_switch = Trainer.switch env_turn_trainer c in
      let new_env = modify_env_turn env tr_switch in
      { new_env with turn = not env.turn }
  | Revive c ->
      let tr_revive = Trainer.revive env_turn_trainer c in
      let new_env = modify_env_turn env tr_revive in
      { new_env with turn = not env.turn }
  | Surrender -> { env with match_result = winner env }
  | MoveUsed _ -> raise (Failure "Should be impossible")

let next_wrong env action1 action2 =
  match (action1, action2) with
  | Switch creature_name1, Revive creature_name2 ->
      let trainer1_switch = Trainer.switch env.trainer1 creature_name1 in
      let trainer2_revive = Trainer.revive env.trainer2 creature_name2 in
      { env with trainer1 = trainer1_switch; trainer2 = trainer2_revive }
  | Revive creature_name1, Switch creature_name2 ->
      let trainer1_revive = Trainer.revive env.trainer1 creature_name1 in
      let trainer2_switch = Trainer.switch env.trainer2 creature_name2 in
      { env with trainer1 = trainer1_revive; trainer2 = trainer2_switch }
  | _, Surrender -> { env with match_result = Trainer2Win (Trainer.name env.trainer2) }
  | Surrender, _ -> { env with match_result = Trainer1Win (Trainer.name env.trainer1) }
  (* | MoveUsed move1, MoveUsed move2 *)
  | _ -> raise Not_found
