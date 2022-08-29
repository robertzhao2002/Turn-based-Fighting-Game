(* let rec change_stats c1 c2 = function | [] -> (c1, c2) | h :: t -> begin match h with |
   Effects.StatChange.Attack (prob, prop, apply_to) -> if Random.float 1. < prob then if
   apply_to then change_stats { c1 with current_attack = c1.current_attack *. prop } c2 t else
   change_stats c1 { c2 with current_attack = c2.current_attack *. prop } t else change_stats
   c1 c2 t | Effects.StatChange.Defense (prob, prop, apply_to) -> if Random.float 1. < prob
   then if apply_to then change_stats { c1 with current_defense = c1.current_defense *. prop }
   c2 t else change_stats c1 { c2 with current_defense = c2.current_defense *. prop } t else
   change_stats c1 c2 t | Effects.StatChange.Speed (prob, prop, apply_to) -> if Random.float 1.
   < prob then if apply_to then change_stats { c1 with current_speed = c1.current_speed *. prop
   } c2 t else change_stats c1 { c2 with current_speed = c2.current_speed *. prop } t else
   change_stats c1 c2 t end *)

let change stat =
  let stat_change_rng = Util.Rng.random_float 0. 1. in
  Effects.StatChange.bind stat (fun (multiplier, probability, self) ->
      if stat_change_rng < probability then (multiplier, self) else (1., self))

let as_string base current =
  let ratio = current /. base in
  if ratio <= 1.03 && ratio >= 0.97 then Printf.sprintf "%.1f" current
  else Printf.sprintf "%.1f -> %.1f" base current

let rec plus_minus ch = function
  | 1 -> ""
  | n -> ch ^ plus_minus ch (n - 1)

let as_string_abbreviated current base stat_string =
  let ratio = current /. base in
  if current = 0. then ""
  else if current > base then
    let int_multiple = int_of_float ratio in
    " " ^ plus_minus "+" int_multiple ^ stat_string ^ ";"
  else if current < base then
    let int_multiple = int_of_float (1. /. ratio) in
    " " ^ plus_minus "-" int_multiple ^ stat_string ^ ";"
  else ""