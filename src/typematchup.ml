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
  | Type2, Type5 -> 1.0
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
