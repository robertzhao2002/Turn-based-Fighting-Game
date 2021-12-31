open Game.Move

let id x = x

let rec use_times m = function
  | 0 -> m
  | n -> use_times (use m) (n - 1)
