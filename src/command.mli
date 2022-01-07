exception Malformed

(** This is the type [t] that represents what a command can be translated into. *)
type t =
  | Summary of string
  | Info of string
  | UseMove of string
  | Command_Switch of string
  | Command_Revive of string
  | Surrender
  | Quit

val parse : string -> t
(** [parse s] is the command that can be extracted from the input string [s]. [Malformed] will
    be raised if [s] does not properly translate into a valid command. *)
