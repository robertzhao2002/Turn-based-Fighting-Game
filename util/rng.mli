val random_bool : bool
(** [random_bool] is [true] 50% of the time and [false] 50% of the time. *)

val random_int : int -> int -> int
(** [random_int lower upper] is an [int] in the range [\[lower, upper)]. *)

val random_float : float -> float -> float
(** [random_float lower upper] is a [float] in the range [\[lower, upper)]. *)
