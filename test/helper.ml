open Game.Move

let rec use_times m = function
  | 0 -> m
  | n -> use_times (use m) (n - 1)
