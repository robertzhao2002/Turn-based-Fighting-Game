exception Malformed
(** [Malformed] represents any command that cannot be properly parsed into a defined
    [Command.t] type defined below. *)

(** [info_type] represents the types of move information commands. [InfoCurrent] represents
    looking at the move information of the current creature in battle. [InfoOther] represents
    looking at the move information of another creature of the trainer. *)
type info_type =
  | InfoCurrent of string
  | InfoOther of string * string

(** This is the type [t] that represents what a command can be translated into.

    - [Summary "creature"] gives a breakdown of the creature's moves and stat changes
    - [Info "move1" | Info "creature2;move2"] gives information about the moves of the creature
      in battle or out of battle
    - [Command_Switch "creature2"] represents switching to another creature
    - [Command_Revive "creature_dead"] represents reviving the dead creature
    - [Surrender] means forfetting the match and giving the opponent the victory
    - [Quit] means abruptly ending the game *)
type t =
  | Summary of string
  | Info of info_type
  | UseMove of string
  | Command_Switch of string
  | Command_Revive of string
  | Surrender
  | Quit

val parse_phrase : string -> string
(** [parse_phrase s] is [s] that has been trimmer and evenly spaced out. Assume that [s]
    doesn't have any punctuation marks. *)

val parse : string -> t
(** [parse s] is the command that can be extracted from the input string [s]. [Malformed] will
    be raised if [s] does not properly translate into a valid command. *)
