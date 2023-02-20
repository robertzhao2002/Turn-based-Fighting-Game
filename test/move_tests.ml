open OUnit2
open Game
open Move
open Typematchup
open Helper
open Values

let move_name_test name input expected_output =
  name >:: fun _ -> input.name |> assert_equal expected_output ~printer:(fun s -> s)

let move_type_test name input expected_output =
  name >:: fun _ -> input.move_type |> assert_equal expected_output ~printer:type_as_string

let move_power_test name input expected_output =
  name >:: fun _ -> input.base_power |> assert_equal expected_output ~printer:string_of_int

let move_uses_test name input expected_output =
  name >:: fun _ -> input.total_uses |> assert_equal expected_output ~printer:string_of_int

let no_more_uses_exn_test name input =
  name >:: fun _ -> assert_raises NoMoreUses (fun () -> use input)

let move_effects_test name input expected_output =
  name >:: fun _ -> input.move_effect |> assert_equal expected_output

let move_stat_changes_test name input expected_output =
  name >:: fun _ -> input.move_stat_change |> assert_equal expected_output

let move_used_test name input expected_output =
  name >:: fun _ -> input.current_uses |> assert_equal expected_output ~printer:string_of_int

let move_string_test name input expected_output =
  name >:: fun _ -> Move.move_string input |> assert_equal expected_output ~printer:id

let yell_tests =
  [
    move_name_test "Name of Move is Yell" yell "yell";
    move_type_test "Type of Yell is type1" yell Type1;
    move_power_test "Yell has base power of 100" yell 100;
    move_uses_test "Yell has 2 uses" yell 2;
    move_used_test "Yell used twice has 0 uses left" yell_2 0;
    no_more_uses_exn_test "Yell has no more uses" yell_2;
    move_effects_test "Yell can poison and confuse 20 percent of the time" yell
      [ Poison 0.2; Confuse 0.2 ];
    move_stat_changes_test
      "Yell can lower the opponent's attack by half (with 50 percent probability) and/or \
       increase the user's defense by 50% (with 20% probability)."
      yell
      [ Attack (0.5, 0.5, false); Defense (1.5, 0.2, true) ];
    move_string_test "Yell string" yell
      {|yell
Type: type1
Uses: 2/2
Base Power: 100; Accuracy: 70.0%;
Status Effects: 20.0% chance to poison; 20.0% chance to confuse;
Stat Changes:  50.0% chance to reduce opponent attack by 50.0%; 20.0% chance to increase user defense by 50.0%;|};
  ]

let nutty_tests =
  [
    move_name_test "Name of Move is nutty" nutty "nutty";
    move_type_test "Type of nutty is type2" nutty Type2;
    move_power_test "Nutty has base power of 50" nutty 50;
    move_uses_test "Nutty has 5 uses" nutty 5;
    no_more_uses_exn_test "Nutty has no more uses" nutty_5;
    move_effects_test "Nutty can paralyze 10% of the time" nutty [ Paralyze 0.1 ];
    move_stat_changes_test
      "Nutty lowers opponent's accuracy by 10% and improves user's evasiveness by 20%." nutty
      [ AccuracyS (0.9, 0.2, false); Evasiveness (1.2, 0.1, true) ];
    move_string_test "Nutty string" nutty
      {|nutty
Type: type2
Uses: 5/5
Base Power: 50; Accuracy: Always hits;
Status Effects: 10.0% chance to paralyze;
Stat Changes:  20.0% chance to reduce opponent accuracy by 10.0%; 10.0% chance to increase user evasiveness by 20.0%;|};
  ]

let chug_jug_tests =
  [
    move_string_test "Chug Jug string" chug_jug
      {|chug jug
Type: type3
Uses: 2/2
Base Power: 100; Accuracy: 70.0%;|};
  ]

let suite =
  "test suite for Move module" >::: List.flatten [ yell_tests; nutty_tests; chug_jug_tests ]

let _ = run_test_tt_main suite
