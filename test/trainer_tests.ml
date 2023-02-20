open OUnit2
open Helper
open Values
open Game.Trainer

let trainer_string_test name input expected_output =
  name >:: fun _ -> trainer_string input |> assert_equal expected_output ~printer:id

let trainer1_tests =
  [
    trainer_string_test "trainer1 string" trainer1
      {|Trainer1
REVIVE
Jit (type5/type2/type1): 100.0% HP; CONFUSE; (IN BATTLE)
Jit (type5/type2/type1): 100.0% HP;
Jit (type5/type2/type1): 95.0% HP; PSN;
Jit's Moves
- yell (type1): 2/2 uses|};
  ]

let suite = "test suite for Trainer module" >::: List.flatten [ trainer1_tests ]
let _ = run_test_tt_main suite
