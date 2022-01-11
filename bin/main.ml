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

let print_move_info_string env name =
  let trainer = trainer_from_turn env in
  let move =
    try move_with_name (creature_of trainer) name with
    | InvalidMove -> raise Not_found
  in
  ANSITerminal.print_string [ determine_print_color env ] (move_string move ^ "\n")

let print_surrender_string winner loser env =
  ANSITerminal.print_string [ determine_print_color env ]
    (loser ^ " has surrendered! " ^ winner ^ " has won the match!\n")

let print_died name revivable =
  ANSITerminal.print_string [ ANSITerminal.green ]
    (name ^ " has died. Please send in a new creature"
    ^ if revivable then " or revive\n" else "\n")

(* Game *)

let jit = init_creature_with_name "Jit"

let spider = init_creature_with_name "Spider"

let init_trainer1 = init_trainer "trainer1" jit spider jit

let init_trainer2 = init_trainer "trainer2" spider jit jit

let init_env = init init_trainer1 init_trainer2

let input_helper () =
  try parse (read_line ()) with
  | Malformed -> Summary "\n"

let rec get_current_env env turn_changed =
  match env.match_result with
  | CreatureDead ->
      let trainer = trainer_from_turn env in
      print_died (Game.Creature.name (creature_of trainer)) (has_revive trainer);
      exit 0
  | Trainer1Win (winner, loser)
  | Trainer2Win (winner, loser) ->
      print_surrender_string winner loser env;
      exit 0
  | Battle -> begin
      if turn_changed then print_trainer env;
      match input_helper () with
      | Summary creature_name ->
          (if creature_name = "\n" then print_invalid_input ()
          else
            try print_summary_string env creature_name with
            | Not_found -> print_invalid_creature ());
          get_current_env env false
      | Info move_name ->
          (try print_move_info_string env move_name with
          | Not_found -> print_invalid_move ());
          get_current_env env false
      | UseMove move_name ->
          let new_env = next env (MoveUsed move_name) in
          get_current_env new_env true
      | Command_Revive revive_creature ->
          let new_env = next env (Revive revive_creature) in
          get_current_env new_env true
      | Command_Switch new_creature ->
          let new_env = next env (Switch new_creature) in
          get_current_env new_env true
      | Surrender ->
          let new_env = next env Surrender in
          get_current_env new_env true
      | Quit ->
          print_quitting ();
          exit 0
    end

let main () =
  ANSITerminal.print_string [ ANSITerminal.cyan ] "Turn-Based Fighting Game Engine\n";
  let env = get_current_env init_env true in
  trainer_string (fst env.trainer1) |> print_endline

let () = main ()
