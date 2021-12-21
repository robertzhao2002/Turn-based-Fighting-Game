open OUnit2
open Game
open Move

let yell_test = init_move_with_name "yell"

let yell_2 = yell_test |> use |> use

let move_name_test name input expected_output =
  name >:: fun _ -> Move.name input |> assert_equal expected_output ~printer:(fun s -> s)

let move_type_test name input expected_output =
  name >:: fun _ -> Move.move_type_of input |> assert_equal expected_output

let move_power_test name input expected_output =
  name >:: fun _ -> Move.power input |> assert_equal expected_output ~printer:string_of_int

let move_accuracy_test name input expected_output =
  name >:: fun _ ->
  Move.accuracy input |> assert_equal expected_output ~printer:string_of_float

let move_uses_test name input expected_output =
  name >:: fun _ -> Move.uses input |> assert_equal expected_output ~printer:string_of_int

let no_more_uses_exn_test name input =
  name >:: fun _ -> assert_raises NoMoreUses (fun () -> use input)

let move_effects_test name input expected_output =
  name >:: fun _ -> Move.effects input |> assert_equal expected_output

let move_stat_changes_test name input expected_output =
  name >:: fun _ -> Move.stat_changes input |> assert_equal expected_output

let yell_tests =
  [
    move_name_test "Name of Move is Yell" yell_test "yell";
    move_type_test "Type of Yell is Water" yell_test Water;
    move_power_test "Yell has base power of 100" yell_test 100;
    move_accuracy_test "Yell has base accuracy of 70%" yell_test 0.7;
    move_uses_test "Yell has 2 uses" yell_test 2;
    move_uses_test "Yell used twice has 0 uses left" yell_2 0;
    no_more_uses_exn_test "Yell has no more uses" yell_2;
    move_effects_test "Yell can poison and confuse 20 percent of the time" yell_test
      [ Poison 0.2; Confuse 0.2 ];
    move_stat_changes_test
      "Yell can lower the opponent's attack by half (with 50 percent probability) and/or \
       increase the user's defense by 50% (with 20% probability)."
      yell_test
      [ Attack (0.5, 0.5, false); Defense (1.5, 0.2, true) ];
  ]

let suite = "test suite for Move module" >::: List.flatten [ yell_tests ]

let _ = run_test_tt_main suite