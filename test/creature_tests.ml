open OUnit2
open Game
open Move
open Creature

let jit_test = init_creature_with_name "Jit"

let creature_name_test name input expected_output =
  name >:: fun _ -> Creature.name input |> assert_equal expected_output ~printer:(fun x -> x)

let creature_hp_test name input expected_output =
  name >:: fun _ -> Creature.hp input |> assert_equal expected_output ~printer:string_of_float

let creature_attack_test name input expected_output =
  name >:: fun _ ->
  Creature.attack input |> assert_equal expected_output ~printer:string_of_float

let creature_defense_test name input expected_output =
  name >:: fun _ ->
  Creature.defense input |> assert_equal expected_output ~printer:string_of_float

let creature_speed_test name input expected_output =
  name >:: fun _ ->
  Creature.speed input |> assert_equal expected_output ~printer:string_of_float

let creature_dead_test name input expected_output =
  name >:: fun _ -> Creature.dead input |> assert_equal expected_output

let creature_apply_poison_test name input expected_output =
  name >:: fun _ -> Creature.apply_poison input |> assert_equal expected_output

let jit_tests =
  [
    creature_name_test "Jit's name is Jit" jit_test "Jit";
    creature_hp_test "Jit has base hp 100" jit_test 100.;
    creature_attack_test "Jit has base attack 105" jit_test 105.;
    creature_defense_test "Jit has base defense 110" jit_test 110.;
    creature_speed_test "Jit has base speed 95" jit_test 95.;
    creature_dead_test "Jit is not dead" jit_test false;
    creature_apply_poison_test "Jit is not poisoned, so applying poison has no effect" jit_test
      jit_test;
  ]

let status_tests = []

let suite = "test suite for Move module" >::: List.flatten [ jit_tests; status_tests ]

let _ = run_test_tt_main suite