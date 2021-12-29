open Game.Move
open Game.Creature
open Helper

(* Moves *)
let yell = init_move_with_name "yell"

let yell_2 = use_times yell 2

let nutty = init_move_with_name "nutty"

let nutty_5 = use_times nutty 5

(* Creatures *)
let jit_test = init_creature_with_name "Jit"

let jit_poison = { jit_test with poison = true }

let jit_after_poison = { jit_poison with hp = jit_poison.hp *. 0.95 }

let jit_confuse = { jit_test with confuse = Some 0 }

let jit_confuse_1_turn = { jit_confuse with hp = jit_confuse.hp *. 0.9; confuse = Some 1 }
