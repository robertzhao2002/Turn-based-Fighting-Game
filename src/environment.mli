type t

val go : t -> t
(** [go env] is the state of the game environment after 1 turn. Either a winner is determined
    or the game continues. *)
