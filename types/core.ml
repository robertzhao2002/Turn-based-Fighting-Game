type t =
  | Type1
  | Type2
  | Type3
  | Type4
  | Type5
  | Type6

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
