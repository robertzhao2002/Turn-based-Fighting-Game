val move_with_name : Move.Core.t list -> string -> Move.Core.t
(** [move_with_name moves name] returns the [Move.Core.t] called [name] if it exists in the
    list. Raises [Core.InvalidMove] if it doesn't exist.*)

val has_move : Move.Core.t list -> string -> bool
(** [has_move moves name] return [true] if a [Move.Core.t] called [name] exists in [moves]. It
    returns [false] otherwise.*)
