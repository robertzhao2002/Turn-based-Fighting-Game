open Trainer
open Random
open Move

type result =
  | Battle of Trainer.t
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
  else
    match env.turn with
    | true -> Battle env.trainer1
    | false -> Battle env.trainer2

let damage env move =
  let trainer_creature =
    match env.turn with
    | true -> creature_of env.trainer1
    | false -> creature_of env.trainer2
  in
  let damage_output = trainer_creature.attack *. float_of_int move.power in
  match move.accuracy with
  | Accuracy a ->
      let accuracy_rng = Random.float 1. in
      if accuracy_rng < a then damage_output else 0.
  | Guarantee -> damage_output

let go env =
  match result_of env with
  | Battle _ -> { env with turn = not env.turn }
  | Trainer1Win s -> { env with match_result = Trainer1Win s }
  | Trainer2Win s -> { env with match_result = Trainer2Win s }
