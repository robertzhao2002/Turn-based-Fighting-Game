let apply_paralysis paralyzed = if paralyzed then Util.Rng.random_bool else false

let apply_poison poisoned health max_health =
  if poisoned then health -. (0.05 *. max_health) else health

let apply_confusion health max_health = function
  | None -> (health, None)
  | Some turns -> (
      let prob_snap_out = if turns < 5 then 0.5 +. (float_of_int turns *. 0.1) else 0.999 in
      let rng_snap_out = Util.Rng.random_float 0. 1. in
      match rng_snap_out < prob_snap_out with
      | true -> (health, None)
      | false -> (
          let rng_attack_yourself = Util.Rng.random_bool in
          match rng_attack_yourself with
          | true -> (health -. (0.1 *. max_health), Some (turns + 1))
          | false -> (health, Some (turns + 1))))

let psn_par_string status condition =
  match status with
  | true -> condition
  | false -> ""

let confuse_string confuse =
  match confuse with
  | Some _ -> " CONFUSE;"
  | None -> ""