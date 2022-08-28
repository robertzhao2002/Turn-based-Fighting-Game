let () = Random.self_init ()

let random_bool = Random.bool ()

let random_int lower upper =
  if upper <= lower then
    raise (Failure "Upper bound must be strictly greater than lower bound")
  else Random.int (upper - lower) + lower

let random_float lower upper =
  if upper <= lower then
    raise (Failure "Upper bound must be strictly greater than lower bound")
  else Random.float (upper -. lower) +. lower
