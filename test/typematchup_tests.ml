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

let same_type_bonus_test name move_type creature_types expected_output =
  name >:: fun _ ->
  same_type_bonus move_type creature_types
  |> assert_equal expected_output ~printer:string_of_float

let effectiveness_as_string_test name value expected =
  name >:: fun _ -> effectiveness_as_string value |> assert_equal expected ~printer:id

let type_matchup_factor_tests =
  [ type_matchup_factor_test "Type1 vs. Type1" (Type1, Type1) 0.5 ]

let multiple_type_matchup_tests =
  [
    multiple_type_matchup_test "Type1 on a (Type1, Type2, Type3)" Type1
      (Type1, Some Type2, Some Type3) 0.25;
    multiple_type_matchup_test "Type2 on a (Type3, Type5, Type1) should be 0" Type2
      (Type3, Some Type5, Some Type1) 0.;
  ]

let same_type_bonus_tests =
  [
    same_type_bonus_test "Type1 with (Type1, None, None)" Type1 (Type1, None, None) 1.25;
    same_type_bonus_test "Type1 with (Type2, None, None)" Type1 (Type2, None, None) 1.;
    same_type_bonus_test "Type2 with (Type1, Some Type2, None)" Type2 (Type1, Some Type2, None)
      1.25;
    same_type_bonus_test "Type6 with (Type1, Some Type2, None)" Type6 (Type1, Some Type2, None)
      1.;
    same_type_bonus_test "Type6 with (Type1, Some Type2, Some Type3)" Type6
      (Type1, Some Type2, Some Type3) 1.;
    same_type_bonus_test "Type3 with (Type1, Some Type2, Some Type3)" Type3
      (Type1, Some Type2, Some Type3) 1.25;
  ]

let effectiveness_as_string_tests =
  [
    effectiveness_as_string_test "2 should be super effective" 2.0 "super effective";
    effectiveness_as_string_test "4 should be super effective" 4.0 "super effective";
    effectiveness_as_string_test "8 should be super effective" 8.0 "super effective";
    effectiveness_as_string_test "1/8 should be not very effective" 0.125 "not very effective";
    effectiveness_as_string_test "1/4 should be not very effective" 0.25 "not very effective";
    effectiveness_as_string_test "1/2 should be not very effective" 0.5 "not very effective";
    effectiveness_as_string_test "0 should be no effect" 0. "no effect";
    effectiveness_as_string_test "1 should be " 1. "";
  ]

let suite =
  "test suite for Typematchup module"
  >::: List.flatten
         [
           type_matchup_factor_tests;
           multiple_type_matchup_tests;
           same_type_bonus_tests;
           effectiveness_as_string_tests;
         ]

let _ = run_test_tt_main suite