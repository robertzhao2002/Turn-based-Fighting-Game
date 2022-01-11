open OUnit2
open Game.Command

let parse_test name input expected_output =
  name >:: fun _ -> parse input |> assert_equal expected_output

let parse_phrase_test name input expected_output =
  name >:: fun _ -> parse_phrase input |> assert_equal expected_output

let parse_excep_test name str exn = name >:: fun _ -> assert_raises exn (fun () -> parse str)

let parse_tests =
  [
    parse_test "    qUiT    will parse to Quit" "    qUiT   " Quit;
    parse_test "suRRenDer    will parse to Quit" "suRRenDer   " Surrender;
    parse_test "    sUmMary       CREATURE" "    sUmMary       CREATURE" (Summary "creature");
    parse_test "info this     attack" "info this     attack" (Info "this attack");
    parse_test "use       attack" "use       attack" (UseMove "attack");
    parse_test "switch creature2" "switch creature2" (Command_Switch "creature2");
    parse_test "revive this creature now" "revive this creature now"
      (Command_Revive "this creature now");
  ]

let parse_excep_tests =
  [
    parse_excep_test "       " "       " Malformed;
    parse_excep_test "sdfgkljsdfgklsdjfnglksdjfng" "sdfgkljsdfgklsdjfnglksdjfng" Malformed;
    parse_excep_test "info" "info" Malformed;
    parse_excep_test "use" "use" Malformed;
    parse_excep_test "revive" "revive" Malformed;
    parse_excep_test "switch" "switch" Malformed;
    parse_excep_test "    summary   " "    summary   " Malformed;
    parse_excep_test "quitsbdfbsddf" "quitsbdfbsddf" Malformed;
    parse_excep_test "surrender sbdfbsddf" "surrender sbdfbsddf" Malformed;
  ]

let parse_phrase_tests =
  [
    parse_phrase_test "     hello       world    " "     hello       world    " "hello world";
    parse_phrase_test "  hElLo     " "  hElLo     " "hello";
  ]

let suite =
  "test suite for Command module"
  >::: List.flatten [ parse_tests; parse_excep_tests; parse_phrase_tests ]

let _ = run_test_tt_main suite
