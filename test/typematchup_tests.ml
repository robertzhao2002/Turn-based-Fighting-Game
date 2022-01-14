open OUnit2
open Helper

let test1 name input expected_output =
  name >:: fun _ -> input |> assert_equal expected_output ~printer:id

let tests = [ test1 "test1" "sdf" "sdf" ]

let suite = "test suite for Typematchup module" >::: List.flatten [ tests ]

let _ = run_test_tt_main suite