type t = Core.t * Core.t option * Core.t option

let type_as_string = function
  | type1, Some t2, Some t3 ->
      Core.type_as_string type1 ^ "/" ^ Core.type_as_string t2 ^ "/" ^ Core.type_as_string t3
  | type1, Some t2, None -> Core.type_as_string type1 ^ "/" ^ Core.type_as_string t2
  | type1, None, None -> Core.type_as_string type1
  | _ -> raise (Failure "Impossible")

let from_string_list = function
  | [] -> raise (Failure "Must have at least 1 type")
  | [ type1 ] -> (Core.type_from_string type1, None, None)
  | [ type1; type2 ] -> (Core.type_from_string type1, Some (Core.type_from_string type2), None)
  | [ type1; type2; type3 ] ->
      ( Core.type_from_string type1,
        Some (Core.type_from_string type2),
        Some (Core.type_from_string type3) )
  | _ -> raise (Failure "Cannot have more than 3 types")

let same_type_bonus move_type = function
  | type1, Some t2, Some t3 ->
      if move_type = type1 || move_type = t2 || move_type = t3 then 1.25 else 1.0
  | type1, Some t2, None -> if move_type = type1 || move_type = t2 then 1.25 else 1.0
  | type1, None, None -> if move_type = type1 then 1.25 else 1.0
  | _ -> raise (Failure "Impossible")