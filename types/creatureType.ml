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