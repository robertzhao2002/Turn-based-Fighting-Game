open Trainer
open Random
open Move
open Creature
open Command

let () = Random.self_init ()

exception InvalidAction

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
  | CreatureDead of bool
  | Trainer1Win of string * string
  | Trainer2Win of string * string

type t = {
  trainer1 : Trainer.t * action option;
  trainer2 : Trainer.t * action option;
  match_result : result;
  turn : bool;
}

let trainer trainer_action = fst trainer_action

let result_of env =
  let trainer1 = trainer env.trainer1 in
  let trainer2 = trainer env.trainer2 in
  if all_dead trainer1 then Trainer2Win (Trainer.name trainer2, Trainer.name trainer1)
  else if all_dead trainer2 then Trainer1Win (Trainer.name trainer1, Trainer.name trainer2)
  else Battle

let trainer_from_turn env =
  match env.turn with
  | true -> fst env.trainer1
  | false -> fst env.trainer2

let other_trainer env =
  match env.turn with
  | true -> fst env.trainer2
  | false -> fst env.trainer1

let next_turn env = { env with turn = not env.turn }

let damage trainer_creature opponent_creature move =
  let hit_probability = trainer_creature.accuracy /. opponent_creature.evasiveness in
  let damage_output =
    ((trainer_creature.attack /. opponent_creature.defense) +. 50.)
    *. float_of_int move.power /. 50.
  in
  match move.accuracy with
  | Accuracy a ->
      let accuracy_rng = Random.float 1. in
      if accuracy_rng < a *. hit_probability then damage_output *. (Random.float 0.2 +. 0.9)
      else (
        print_endline "Attack missed";
        0.)
  | Guarantee -> damage_output

let apply_move move creature1 creature2 =
  let damage_output = damage creature1 creature2 move in
  let effects = move.meffect in
  let creature_with_effects, turn_used =
    if damage_output > 0. then inflict_multiple_status creature2 effects else (creature2, false)
  in
  (inflict_damage creature_with_effects damage_output, turn_used)

let determine_move env =
  let trainer1 = trainer env.trainer1 in
  let trainer2 = trainer env.trainer2 in
  let trainer1_creature_speed = (creature_of trainer1).speed in
  let trainer2_creature_speed = (creature_of trainer2).speed in
  if trainer1_creature_speed > trainer2_creature_speed then trainer1
    (* true is trainer1 turn *)
  else if trainer2_creature_speed > trainer1_creature_speed then trainer2
    (* false is trainer2 turn *)
  else
    match Random.bool () with
    | true -> trainer1
    | false -> trainer2

let init t1 t2 =
  { trainer1 = (t1, None); trainer2 = (t2, None); turn = true; match_result = Battle }

let dead_action env action =
  match env.turn with
  | true -> true
  | false -> false

let trainer_surrender env =
  let trainer1 = trainer env.trainer1 in
  let trainer2 = trainer env.trainer2 in
  match env.turn with
  | true -> Trainer2Win (Trainer.name trainer2, Trainer.name trainer1)
  | false -> Trainer1Win (Trainer.name trainer1, Trainer.name trainer2)

let modify_env_trainer env tr =
  if env.turn then { env with trainer1 = tr } else { env with trainer2 = tr }

let modify_env_action env ac =
  let env_trainer1 = trainer env.trainer1 in
  let env_trainer2 = trainer env.trainer2 in
  if env.turn then { env with trainer1 = (env_trainer1, Some ac) }
  else { env with trainer2 = (env_trainer2, Some ac) }

let use_move move trainer1 trainer2 =
  let trainer1_creature, paralyze_turn = creature_of trainer1 |> apply_paralysis in
  match paralyze_turn with
  | true ->
      let paralyzed_creature_trainer = modify_creature trainer1 trainer1_creature in
      (paralyzed_creature_trainer, trainer2, paralyze_turn)
  | false -> begin
      let trainer1_creature_not_paralyzed, confusion_turn =
        trainer1_creature |> apply_confusion
      in
      match confusion_turn with
      | false ->
          let move_used = move_with_name trainer1_creature_not_paralyzed move in
          let new_trainer2_creature, turn_used =
            apply_move move_used trainer1_creature_not_paralyzed (creature_of trainer2)
          in
          let trainer1_creature_use_move =
            modify_creature trainer1 (use_move_with_name trainer1_creature_not_paralyzed move)
          in
          let trainer2_damage_inflicted = modify_creature trainer2 new_trainer2_creature in
          (trainer1_creature_use_move, trainer2_damage_inflicted, turn_used)
      | true ->
          let trainer1_hurt_itself =
            modify_creature trainer1 trainer1_creature_not_paralyzed
          in
          (trainer1_hurt_itself, trainer2, confusion_turn)
    end

let switch_and_move (trainer1, mv) (trainer2, cr) =
  let trainer2_switch = switch trainer2 cr in
  use_move mv trainer1 trainer2_switch

let rec process_turns env =
  match env.match_result with
  | Battle -> begin
      let trainer1, action1 = env.trainer1 in
      let trainer2, action2 = env.trainer2 in
      match (action1, action2) with
      | None, _ -> { env with turn = true }
      | Some _, None -> { env with turn = false }
      | Some a1, Some a2 -> process_actions env (a1, a2)
    end
  | CreatureDead turn -> { env with turn }
  | winner -> next_turn env

and process_actions env (action1, action2) =
  let trainer1 = trainer env.trainer1 in
  let trainer2 = trainer env.trainer2 in
  match (action1, action2) with
  | Switch c1, Switch c2 ->
      let trainer1_switch = switch trainer1 c1 in
      let trainer2_switch = switch trainer2 c2 in
      process_turns
        { env with trainer1 = (trainer1_switch, None); trainer2 = (trainer2_switch, None) }
  | Switch c1, Revive c2 ->
      let trainer1_switch = switch trainer1 c1 in
      let trainer2_revive = revive trainer2 c2 in
      process_turns
        { env with trainer1 = (trainer1_switch, None); trainer2 = (trainer2_revive, None) }
  | Revive c1, Revive c2 ->
      let trainer1_revive = revive trainer1 c1 in
      let trainer2_revive = revive trainer2 c2 in
      process_turns
        { env with trainer1 = (trainer1_revive, None); trainer2 = (trainer2_revive, None) }
  | Revive c1, Switch c2 ->
      let trainer1_revive = revive (trainer env.trainer1) c1 in
      let trainer2_switch = switch (trainer env.trainer2) c2 in
      process_turns
        { env with trainer1 = (trainer1_revive, None); trainer2 = (trainer2_switch, None) }
  | MoveUsed m1, Switch c2 ->
      let trainer1_creature_use_move, trainer2_damage_inflicted, _ =
        switch_and_move (trainer1, m1) (trainer2, c2)
      in
      process_turns
        {
          env with
          trainer1 = (trainer1_creature_use_move, None);
          trainer2 = (trainer2_damage_inflicted, None);
          match_result =
            (if dead (creature_of trainer2_damage_inflicted) then
             if all_dead trainer2_damage_inflicted then
               Trainer1Win
                 ( Trainer.name trainer1_creature_use_move,
                   Trainer.name trainer2_damage_inflicted )
             else CreatureDead false
            else Battle);
        }
  | Switch c1, MoveUsed m2 ->
      let trainer2_creature_use_move, trainer1_damage_inflicted, _ =
        switch_and_move (trainer2, m2) (trainer1, c1)
      in
      process_turns
        {
          env with
          trainer1 = (trainer1_damage_inflicted, None);
          trainer2 = (trainer2_creature_use_move, None);
          match_result =
            (if dead (creature_of trainer1_damage_inflicted) then
             if all_dead trainer1_damage_inflicted then
               Trainer2Win
                 ( Trainer.name trainer2_creature_use_move,
                   Trainer.name trainer1_damage_inflicted )
             else CreatureDead true
            else Battle);
        }
  | MoveUsed m1, MoveUsed m2 -> env
  | _ -> raise Not_found

let dead_action env creature =
  let env_turn_trainer = trainer_from_turn env in
  if dead creature && has_revive env_turn_trainer then
    let tr_revive = revive env_turn_trainer creature.name in
    let new_env = modify_env_trainer env (tr_revive, None) in
    process_turns { new_env with match_result = Battle }
  else
    let tr_switch =
      try switch env_turn_trainer creature.name with
      | InvalidCreature -> raise InvalidAction
    in
    let new_env = modify_env_trainer env (tr_switch, None) in
    process_turns { new_env with match_result = Battle }

let next env act =
  let env_turn_trainer = trainer_from_turn env in
  let action_env =
    match act with
    | Switch c ->
        if creature_not_in_battle env_turn_trainer c then modify_env_action env act
        else raise InvalidAction
    | Revive c ->
        if has_creature env_turn_trainer c && has_revive env_turn_trainer then
          let creature = creature_with_name env_turn_trainer c in
          if dead creature then modify_env_action env act else raise InvalidAction
        else raise InvalidAction
    | Surrender -> { env with match_result = trainer_surrender env }
    | MoveUsed move_name ->
        let turn_creature = creature_of env_turn_trainer in
        if has_move turn_creature move_name then modify_env_action env act
        else raise InvalidAction
  in
  process_turns action_env
