exception Malformed

(* The string here will represent the name of the creature or move *)

type t =
  | Summary of string
  | Info of string
  | UseMove of string
  | Switch of string
  | Revive of string
  | Surrender
  | Quit

let format str = str |> String.trim |> String.lowercase_ascii

let rec get_words_no_spaces str_lst = List.filter (( <> ) "") str_lst

let parse s =
  let formatted = format s in
  let words_list = String.split_on_char ' ' formatted in
  match formatted with
  | "quit" -> Quit
  | "surrender" -> Surrender
  | _ -> raise Malformed
