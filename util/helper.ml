let percent_string f =
  let percent_sign_string = "%" in
  percent_sign_string |> ( ^ ) (Printf.sprintf "%.1f" (f *. 100.))

let identity a = a