type t =
  | Type1
  | Type2
  | Type3
  | Type4
  | Type5
  | Type6

val type_from_string : string -> t
val type_as_string : t -> string
