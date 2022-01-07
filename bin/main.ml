open Game.Environment
open Game.Trainer
open Game.Creature
open Game.Move
open Game.Command

let jit = init_creature_with_name "Jit"

let init_trainer1 = init_trainer "trainer1" jit jit jit

let init_trainer2 = init_trainer "trainer2" jit jit jit

let init_env = init init_trainer1 init_trainer2

let summary_string env name =
  let trainer = trainer_from_turn env in
  let creature = creature_with_name trainer name in
  creature_stats_string creature ^ "\n" ^ creature_moves_string creature

let move_info_string env name =
  let trainer = trainer_from_turn env in
  let move = move_with_name (creature_of trainer) name in
  move_string move

let surrender_string env =
  let trainer = trainer_from_turn env in
  Game.Trainer.name trainer ^ " has surrendered! "
  ^ Game.Trainer.name (other_trainer env)
  ^ " has won the match!"

let rec get_current_env env =
  match parse (read_line ()) with
  | Summary creature_name ->
      print_endline (summary_string env creature_name);
      get_current_env env
  | Info move_name ->
      print_endline (move_info_string env move_name);
      get_current_env env
  | UseMove _ -> get_current_env env
  | Command_Revive _ -> get_current_env env
  | Command_Switch new_creature ->
      let new_env = next env (Switch new_creature) in
      get_current_env new_env
  | Surrender ->
      print_endline (surrender_string env);
      exit 0
  | Quit -> exit 0

let main () =
  ANSITerminal.print_string [ ANSITerminal.red ] "Turn-Based Fighting Game Engine\n";
  let env = get_current_env init_env in
  trainer_string env.trainer1 |> print_endline

let () = main ()
