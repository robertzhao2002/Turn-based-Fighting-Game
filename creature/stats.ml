let rec plus_minus ch = function
  | 0 -> ""
  | n -> ch ^ plus_minus ch (n - 1)

let stat_change_string stat base str =
  let ratio = stat /. base in
  if stat = 0. then ""
  else if stat > base then
    let int_multiple = int_of_float ratio in
    " " ^ plus_minus "+" int_multiple ^ str ^ ";"
  else if stat < base then
    let int_multiple = int_of_float (1. /. ratio) in
    " " ^ plus_minus "-" int_multiple ^ str ^ ";"
  else ""