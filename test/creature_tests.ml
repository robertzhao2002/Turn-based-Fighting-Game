open OUnit2
open Game
open Move
open Creature
open Typematchup
open Helper
open Values

let creature_name_test name input expected_output =
  name >:: fun _ -> input.name |> assert_equal expected_output ~printer:id

let creature_type_test name input expected_output =
  name >:: fun _ ->
  input.creature_type |> assert_equal expected_output ~printer:creature_type_as_string

let creature_base_hp_test name input expected_output =
  name >:: fun _ -> input.base_hp |> assert_equal expected_output ~printer:string_of_float

let creature_base_attack_test name input expected_output =
  name >:: fun _ -> input.base_attack |> assert_equal expected_output ~printer:string_of_float

let creature_base_defense_test name input expected_output =
  name >:: fun _ -> input.base_defense |> assert_equal expected_output ~printer:string_of_float

let creature_base_speed_test name input expected_output =
  name >:: fun _ -> input.base_speed |> assert_equal expected_output ~printer:string_of_float

let creature_dead_test name input expected_output =
  name >:: fun _ -> Creature.dead input |> assert_equal expected_output

let creature_apply_poison_test name input expected_output =
  name >:: fun _ -> Creature.apply_poison input |> assert_equal expected_output

let creature_apply_confusion_test name input expected_output =
  name >:: fun _ -> Creature.apply_confusion input |> assert_equal expected_output

let creature_string_test name input expected_output =
  name >:: fun _ -> Creature.creature_string input |> assert_equal expected_output ~printer:id

let creature_stats_string_test name input expected_output =
  name >:: fun _ ->
  Creature.creature_stats_string input |> assert_equal expected_output ~printer:id

let jit_tests =
  [
    creature_name_test "Jit's name is Jit" jit_test "Jit";
    creature_type_test "Jit's types are Type1, Type2, and Type5" jit_test
      (Type5, Some Type2, Some Type1);
    creature_base_hp_test "Jit has base hp 100" jit_test 100.;
    creature_base_attack_test "Jit has base attack 105" jit_test 105.;
    creature_base_defense_test "Jit has base defense 110" jit_test 110.;
    creature_base_speed_test "Jit has base speed 95" jit_test 95.;
    creature_dead_test "Jit is not dead" jit_test false;
    creature_apply_poison_test "Jit is not poisoned, so applying poison has no effect" jit_test
      jit_test;
    creature_apply_poison_test
      "Poisoned Jit is poisoned, so applying poison will take away 5% health, while \
       maintaining poisoned status"
      jit_poison jit_after_poison;
    creature_apply_confusion_test "Jit isn't confused, so won't be affected" jit_test
      (jit_test, false);
    (* creature_apply_confusion_test "Jit confused after 1 turn" jit_confuse
       (jit_confuse_1_turn, true); *)
    creature_string_test "Jit confused as a string" jit_confuse_1_turn
      "Jit (type5/type2/type1): 90.0% HP; CONFUSE;";
    creature_stats_string_test "Jit's stats as string" jit_defense_boost_attack_reduced
      {|Jit's Stats
- TYPE: type5/type2/type1
- HP: 100.0/100.0
- ATK: 105.0 -> 52.5
- DEF: 110.0 -> 165.0
- SPD: 95.0|};
  ]

let suite = "test suite for Move module" >::: List.flatten [ jit_tests ]
let _ = run_test_tt_main suite
