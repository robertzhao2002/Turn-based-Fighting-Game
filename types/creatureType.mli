type t = Core.t * Core.t option * Core.t option

val type_as_string : t -> string
val from_string_list : string list -> t

val same_type_bonus: Core.t -> Core.t * Core.t option * Core.t option -> float
