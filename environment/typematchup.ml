type t =
  | Type1
  | Type2
  | Type3
  | Type4
  | Type5
  | Type6

type creature_type = t * t option * t option

let type_matchup_factor = function
  | Type1, Type1 -> 0.5
  | Type1, Type2 -> 1.0
  | Type2, Type1 -> 2.0
  | Type1, Type3 -> 0.5
  | Type3, Type1 -> 2.0
  | Type1, Type4 -> 2.0
  | Type4, Type1 -> 1.0
  | Type1, Type5 -> 0.5
  | Type5, Type1 -> 1.0
  | Type1, Type6 -> 2.0
  | Type6, Type1 -> 1.0
  | Type2, Type2 -> 0.5
  | Type2, Type3 -> 1.0
  | Type3, Type2 -> 1.0
  | Type2, Type4 -> 1.0
  | Type4, Type2 -> 1.0
  | Type2, Type5 -> 0.
  | Type5, Type2 -> 1.0
  | Type2, Type6 -> 2.0
  | Type6, Type2 -> 1.0
  | Type3, Type3 -> 1.0
  | Type3, Type4 -> 1.0
  | Type4, Type3 -> 1.0
  | Type3, Type5 -> 1.0
  | Type5, Type3 -> 2.0
  | Type3, Type6 -> 1.0
  | Type6, Type3 -> 1.0
  | Type4, Type4 -> 1.0
  | Type4, Type5 -> 2.0
  | Type5, Type4 -> 1.0
  | Type4, Type6 -> 1.0
  | Type6, Type4 -> 0.5
  | Type5, Type5 -> 1.0
  | Type5, Type6 -> 1.0
  | Type6, Type5 -> 1.0
  | Type6, Type6 -> 1.0

let multiple_type_matchup opp_type = function
  | type1, Some t2, Some t3 ->
      type_matchup_factor (opp_type, type1)
      *. type_matchup_factor (opp_type, t2)
      *. type_matchup_factor (opp_type, t3)
  | type1, Some t2, None ->
      type_matchup_factor (opp_type, type1) *. type_matchup_factor (opp_type, t2)
  | type1, None, None -> type_matchup_factor (opp_type, type1)
  | _ -> raise (Failure "Impossible")

let same_type_bonus move_type = function
  | type1, Some t2, Some t3 ->
      if move_type = type1 || move_type = t2 || move_type = t3 then 1.25 else 1.0
  | type1, Some t2, None -> if move_type = type1 || move_type = t2 then 1.25 else 1.0
  | type1, None, None -> if move_type = type1 then 1.25 else 1.0
  | _ -> raise (Failure "Impossible")

let effectiveness_as_string value =
  if value >= 2.0 then "super effective"
  else if value = 0. then "no effect"
  else if value <= 0.5 then "not very effective"
  else ""

let type_from_string s =
  match String.lowercase_ascii s with
  | "type1" -> Type1
  | "type2" -> Type2
  | "type3" -> Type3
  | "type4" -> Type4
  | "type5" -> Type5
  | "type6" -> Type6
  | _ -> raise (Failure "Impossible")

let type_as_string = function
  | Type1 -> "type1"
  | Type2 -> "type2"
  | Type3 -> "type3"
  | Type4 -> "type4"
  | Type5 -> "type5"
  | Type6 -> "type6"

let creature_type_as_string = function
  | type1, Some t2, Some t3 ->
      type_as_string type1 ^ "/" ^ type_as_string t2 ^ "/" ^ type_as_string t3
  | type1, Some t2, None -> type_as_string type1 ^ "/" ^ type_as_string t2
  | type1, None, None -> type_as_string type1
  | _ -> raise (Failure "Impossible")
