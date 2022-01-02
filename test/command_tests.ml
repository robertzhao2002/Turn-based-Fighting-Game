open OUnit2
open Game.Command

let parse_test name input expected_output =
  name >:: fun _ -> parse input |> assert_equal expected_output

let parse_tests =
  [
    parse_test "    qUiT    will parse to Quit" "    qUiT   " Quit;
    parse_test "suRRenDer    will parse to Quit" "suRRenDer   " Surrender;
  ]

let suite = "test suite for Command module" >::: List.flatten [ parse_tests ]

let _ = run_test_tt_main suite
