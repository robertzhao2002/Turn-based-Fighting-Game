open Game.Environment
open Game.Trainer
open Game.Creature
open Game.Move
open Game.Command

(* Helper Functions *)
let determine_print_color env = if env.turn then ANSITerminal.yellow else ANSITerminal.magenta

(* Print Functions *)
let print_invalid_input () = ANSITerminal.print_string [ ANSITerminal.red ] "Invalid Input\n"

let print_invalid_creature () =
  ANSITerminal.print_string [ ANSITerminal.red ] "Invalid Creature\n"

let print_invalid_move () = ANSITerminal.print_string [ ANSITerminal.red ] "Invalid Move\n"

let print_quitting () = ANSITerminal.print_string [ ANSITerminal.blue ] "QUITTING....\n"

let print_trainer env =
  ANSITerminal.print_string [ determine_print_color env ]
    (trainer_string (trainer_from_turn env) ^ "\n")

let print_summary_string env name =
  let trainer = trainer_from_turn env in
  let creature =
    try creature_with_name trainer name with
    | InvalidCreature -> raise Not_found
  in
  ANSITerminal.print_string [ determine_print_color env ]
    (creature_stats_string creature ^ "\n" ^ creature_moves_string creature ^ "\n")

let print_move_info_string env name creature =
  let move =
    try move_with_name creature name with
    | InvalidMove -> raise Not_found
  in
  ANSITerminal.print_string [ determine_print_color env ] (move_string move ^ "\n")

let print_surrender_string winner loser env =
  ANSITerminal.print_string [ determine_print_color env ]
    (loser ^ " has surrendered! " ^ winner ^ " has won the match!\n")

let print_died name revivable =
  ANSITerminal.print_string [ ANSITerminal.green ]
    (name ^ " has died. Please send in a new creature"
    ^ if revivable then " or revive: " else ": ")

(* Game *)

let jit = init_creature_with_name "Jit"

let spider = init_creature_with_name "Spider"

let metty_betty = init_creature_with_name "Metty Betty"

let init_trainer1 = init_trainer "trainer1" jit spider metty_betty

let init_trainer2 = init_trainer "trainer2" spider jit metty_betty

let init_env = init init_trainer1 init_trainer2

let info_helper env info =
  let trainer = trainer_from_turn env in
  match info with
  | InfoCurrent a -> (
      try print_move_info_string env a (creature_of trainer) with
      | Not_found -> print_invalid_move ())
  | InfoOther (a, b) -> (
      try print_move_info_string env b (creature_with_name trainer a) with
      | InvalidCreature -> print_invalid_creature ()
      | Not_found -> print_invalid_move ())

let input_helper () =
  try parse (read_line ()) with
  | Malformed -> Summary "\n"

let rec send_in_helper trainer =
  try creature_with_name trainer (parse_phrase (read_line ())) with
  | Game.Trainer.InvalidCreature ->
      print_invalid_creature ();
      send_in_helper trainer

let rec get_current_env env turn_changed surrendered =
  match env.match_result with
  | CreatureDead _ ->
      let trainer = trainer_from_turn env in
      print_trainer env;
      print_died (Game.Creature.name (creature_of trainer)) (has_revive trainer);
      let creature = send_in_helper trainer in
      let new_env = dead_action env creature in
      get_current_env new_env true false
  | Trainer1Win (winner, loser)
  | Trainer2Win (winner, loser) ->
      if surrendered then print_surrender_string winner loser env;
      exit 0
  | Battle -> begin
      if turn_changed then print_trainer env;
      match input_helper () with
      | Summary creature_name ->
          (if creature_name = "\n" then print_invalid_input ()
          else
            try print_summary_string env creature_name with
            | Not_found -> print_invalid_creature ());
          get_current_env env false false
      | Info move_name ->
          info_helper env move_name;
          get_current_env env false false
      | UseMove move_name ->
          let new_env = next env (MoveUsed move_name) in
          get_current_env new_env true false
      | Command_Revive revive_creature ->
          let new_env = next env (Revive revive_creature) in
          get_current_env new_env true false
      | Command_Switch new_creature ->
          let new_env = next env (Switch new_creature) in
          get_current_env new_env true false
      | Surrender ->
          let new_env = next env Surrender in
          get_current_env new_env true true
      | Quit ->
          print_quitting ();
          exit 0
    end

let main () =
  ANSITerminal.print_string [ ANSITerminal.cyan ] "Turn-Based Fighting Game Engine\n";
  let env = get_current_env init_env true false in
  trainer_string (fst env.trainer1) |> print_endline

let () = main ()
