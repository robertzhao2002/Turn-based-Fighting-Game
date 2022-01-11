exception Malformed

type t =
  | Summary of string
  | Info of string
  | UseMove of string
  | Command_Switch of string
  | Command_Revive of string
  | Surrender
  | Quit

let format str = str |> String.trim |> String.lowercase_ascii

let rec get_words_no_spaces str_lst = List.filter (( <> ) "") str_lst

let first_word = function
  | [] -> raise Malformed
  | h :: _ -> h

let rest_words = function
  | [] -> raise Malformed
  | _ :: t -> t

let parse_phrase s =
  let formatted = format s in
  let words_list = String.split_on_char ' ' formatted |> get_words_no_spaces in
  String.concat " " words_list

let parse s =
  let formatted = format s in
  let words_list = String.split_on_char ' ' formatted |> get_words_no_spaces in
  match formatted with
  | "quit" -> Quit
  | "surrender" -> Surrender
  | _ -> begin
      let fst_word = first_word words_list in
      let rest = rest_words words_list in
      if rest = [] then raise Malformed
      else
        match fst_word with
        | "summary" -> Summary (String.concat " " rest)
        | "info" -> Info (String.concat " " rest)
        | "use" -> UseMove (String.concat " " rest)
        | "switch" -> Command_Switch (String.concat " " rest)
        | "revive" -> Command_Revive (String.concat " " rest)
        | _ -> raise Malformed
    end
