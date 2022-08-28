type t =
  | Effective of float
  | SuperEffective of float
  | NotVeryEffective of float
  | NoEffect of float

let type_matchup = function
  | Core.Type1, Core.Type1 -> NotVeryEffective 0.5
  | Core.Type1, Core.Type2 -> Effective 1.0
  | Core.Type2, Core.Type1 -> SuperEffective 2.0
  | Core.Type1, Core.Type3 -> NotVeryEffective 0.5
  | Core.Type3, Core.Type1 -> SuperEffective 2.0
  | Core.Type1, Core.Type4 -> SuperEffective 2.0
  | Core.Type4, Core.Type1 -> Effective 1.0
  | Core.Type1, Core.Type5 -> NotVeryEffective 0.5
  | Core.Type5, Core.Type1 -> Effective 1.0
  | Core.Type1, Core.Type6 -> NoEffect 0.0
  | Core.Type6, Core.Type1 -> Effective 1.0
  | Core.Type2, Core.Type2 -> NotVeryEffective 0.5
  | Core.Type2, Core.Type3 -> Effective 1.0
  | Core.Type3, Core.Type2 -> Effective 1.0
  | Core.Type2, Core.Type4 -> Effective 1.0
  | Core.Type4, Core.Type2 -> Effective 1.0
  | Core.Type2, Core.Type5 -> NotVeryEffective 0.5
  | Core.Type5, Core.Type2 -> Effective 1.0
  | Core.Type2, Core.Type6 -> SuperEffective 2.0
  | Core.Type6, Core.Type2 -> Effective 1.0
  | Core.Type3, Core.Type3 -> Effective 1.0
  | Core.Type3, Core.Type4 -> Effective 1.0
  | Core.Type4, Core.Type3 -> Effective 1.0
  | Core.Type3, Core.Type5 -> NoEffect 0.0
  | Core.Type5, Core.Type3 -> SuperEffective 2.0
  | Core.Type3, Core.Type6 -> Effective 1.0
  | Core.Type6, Core.Type3 -> Effective 1.0
  | Core.Type4, Core.Type4 -> Effective 1.0
  | Core.Type4, Core.Type5 -> SuperEffective 2.0
  | Core.Type5, Core.Type4 -> Effective 1.0
  | Core.Type4, Core.Type6 -> Effective 1.0
  | Core.Type6, Core.Type4 -> NotVeryEffective 0.5
  | Core.Type5, Core.Type5 -> Effective 1.0
  | Core.Type5, Core.Type6 -> Effective 1.0
  | Core.Type6, Core.Type5 -> Effective 1.0
  | Core.Type6, Core.Type6 -> Effective 1.0

let ( >>= ) core_type f =
  match core_type with
  | Effective factor -> factor
  | NotVeryEffective factor -> factor
  | SuperEffective factor -> factor
  | NoEffect factor -> factor

let effectiveness type1 type2 =
  type_matchup (type1, type2) >>= fun effectiveness_factor -> effectiveness_factor

let incoming_move_effectiveness_on_creature opp_type = function
  | type1, Some t2, Some t3 ->
      effectiveness opp_type type1 *. effectiveness opp_type t2 *. effectiveness opp_type t3
  | type1, Some t2, None -> effectiveness opp_type type1 *. effectiveness opp_type t2
  | type1, None, None -> effectiveness opp_type type1
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
