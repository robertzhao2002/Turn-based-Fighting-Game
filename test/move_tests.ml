open OUnit2
open Game
open Move
open Helper
open Values

let move_name_test name input expected_output =
  name >:: fun _ -> Move.name input |> assert_equal expected_output ~printer:(fun s -> s)

let move_type_test name input expected_output =
  name >:: fun _ -> Move.move_type_of input |> assert_equal expected_output

let move_power_test name input expected_output =
  name >:: fun _ ->
  Move.base_power input |> assert_equal expected_output ~printer:string_of_int

let move_accuracy_test name input expected_output =
  name >:: fun _ ->
  Move.base_accuracy input |> assert_equal expected_output ~printer:string_of_float

let move_uses_test name input expected_output =
  name >:: fun _ -> Move.uses input |> assert_equal expected_output ~printer:string_of_int

let no_more_uses_exn_test name input =
  name >:: fun _ -> assert_raises NoMoreUses (fun () -> use input)

let move_effects_test name input expected_output =
  name >:: fun _ -> Move.effects input |> assert_equal expected_output

let move_stat_changes_test name input expected_output =
  name >:: fun _ -> Move.stat_changes input |> assert_equal expected_output

let move_used_test name input expected_output =
  name >:: fun _ -> input.uses |> assert_equal expected_output ~printer:string_of_int

let yell_tests =
  [
    move_name_test "Name of Move is Yell" yell "yell";
    move_type_test "Type of Yell is Water" yell Water;
    move_power_test "Yell has base power of 100" yell 100;
    move_accuracy_test "Yell has base accuracy of 70%" yell 0.7;
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
  ]

let nutty_tests =
  [
    move_name_test "Name of Move is nutty" nutty "nutty";
    move_type_test "Type of nutty is Water" nutty Magic;
    move_power_test "Nutty has base power of 50" nutty 50;
    move_accuracy_test "Nutty has base accuracy of 100% (Guarantee)" nutty 1.;
    move_uses_test "Nutty has 5 uses" nutty 5;
    no_more_uses_exn_test "Nutty has no more uses" nutty_5;
    move_effects_test "Nutty can paralyze 10% of the time" nutty [ Paralyze 0.1 ];
    move_stat_changes_test
      "Nutty lowers opponent's accuracy by 10% and improves user's evasiveness by 20%." nutty
      [ AccuracyS (0.9, 0.2, false); Evasiveness (1.2, 0.1, true) ];
  ]

let suite = "test suite for Move module" >::: List.flatten [ yell_tests; nutty_tests ]

let _ = run_test_tt_main suite