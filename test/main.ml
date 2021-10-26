open OUnit2

let basic_check name input expected_output =
  name >:: fun _ -> input |> assert_equal expected_output

let move_tests = [ basic_check "Temporary Test" true true ]

let suite = "test suite for Fighting Game" >::: List.flatten [ move_tests ]

let _ = run_test_tt_main suite