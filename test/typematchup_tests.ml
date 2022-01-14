open OUnit2
open Helper
open Values
open Game.Typematchup

let type_matchup_factor_test name input expected_output =
  name >:: fun _ ->
  type_matchup_factor input |> assert_equal expected_output ~printer:string_of_float

let multiple_type_matchup_test name opp_type creature_types expected_output =
  name >:: fun _ ->
  multiple_type_matchup opp_type creature_types
  |> assert_equal expected_output ~printer:string_of_float

let type_matchup_factor_tests =
  [ type_matchup_factor_test "Type1 vs. Type1" (Type1, Type1) 0.5 ]

let multiple_type_matchup_tests =
  [
    multiple_type_matchup_test "Type1 on a (Type1, Type2, Type3)" Type1
      (Type1, Some Type2, Some Type3) 0.25;
  ]

let suite =
  "test suite for Typematchup module"
  >::: List.flatten [ type_matchup_factor_tests; multiple_type_matchup_tests ]

let _ = run_test_tt_main suite