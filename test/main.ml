open OUnit2
open Game
open Move

let yell_test = init_move_with_name "yell"

let move_name_test name input expected_output =
  name >:: fun _ -> Move.name input |> assert_equal expected_output

let move_uses_test name input expected_output =
  name >:: fun _ -> Move.uses input |> assert_equal expected_output

let move_tests =
  [
    move_name_test "Name of Move is Yell" yell_test "yell";
    move_uses_test "Name of Move is Yell" yell_test 100;
  ]

let suite = "test suite for Fighting Game" >::: List.flatten [ move_tests ]

let _ = run_test_tt_main suite