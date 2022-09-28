open Game.Move
open Game.Creature
open Game.Trainer
open Helper

(* Moves *)
let yell = init_move_with_name "yell" "test_moves"
let yell_2 = use_times yell 2
let nutty = init_move_with_name "nutty" "test_moves"
let nutty_5 = use_times nutty 5
let chug_jug = init_move_with_name "chug jug" "test_moves"

(* Creatures *)
let jit_test = init_creature_with_name "Jit" "test_creatures" "test_moves"
let jit_attack_reduced = { jit_test with current_attack = 0.5 *. jit_test.current_attack }

let jit_defense_boost_attack_reduced =
  { jit_attack_reduced with current_defense = 1.5 *. jit_attack_reduced.current_defense }

let jit_poison = { jit_test with poison = true }
let jit_after_poison = { jit_poison with current_hp = jit_poison.current_hp *. 0.95 }
let jit_confuse = { jit_test with confuse = Some 0 }

let jit_confuse_1_turn =
  { jit_confuse with current_hp = jit_confuse.current_hp *. 0.9; confuse = Some 1 }

let jit_everything = jit_test

(* Trainers *)

let trainer1 = init_trainer "Trainer1" jit_confuse jit_test jit_after_poison
