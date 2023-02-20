let rec find_move_with_name move_name (move_list : Move.Core.t list) =
  match move_list with
  | [] -> raise Core.InvalidMove
  | h :: t ->
      if String.lowercase_ascii h.name = String.lowercase_ascii move_name then h
      else find_move_with_name move_name t

let has_move moves move_name =
  let rec has_move_helper name (move_list : Move.Core.t list) =
    match move_list with
    | [] -> false
    | h :: t ->
        if String.lowercase_ascii h.name = String.lowercase_ascii name && h.current_uses > 0
        then true
        else has_move_helper name t
  in
  has_move_helper move_name moves

let move_with_name moves move_name = find_move_with_name move_name moves
