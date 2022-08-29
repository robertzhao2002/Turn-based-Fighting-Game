val change : Effects.StatChange.t -> float * bool
(** [change stat_change] handles all RNG and returns a [float] representing the multiplier
    change for the stat and a [bool] representing if the stat change should be applied to the
    user or the opponent. *)

val as_string : float -> float -> string
(** [as_string base current] returns a [string] in the format ["base value -> current value"]
    if the current value of the stat has been changed by [3%] or more.

    Examples

    - {[ 10.0 -> 42.0 ]}
    - {[ 16.4 -> 6.9 ]}
    - {[ 20.5 -> 30.5 ]}*)

val as_string_abbreviated : float -> float -> string -> string
(** [as_string_abbreviated current base stat_string] returns a [string] in the format
    ["+/-CODE;"]. If there is no change, then the empty string will be returned. This means
    that no stat change needs to be displayed. The number of [+] or [-] prepended to the [CODE]
    is based on how many times more or less the stat has changed from its base value. If this
    value is less than 1, then we can think of the value as [1/n] of the base value. [n] will
    be truncated to an integer and that number of [-] will be prepended to the stat. If this
    value is greater than 1, then we can think of the value as [n] times the base value. [n]
    will be truncated to an integer and that number of [+] will be prepended to the stat.

    Codes

    - [ATK]: ATTACK
    - [DEF]: DEFENSE
    - [SPD]: SPEED

    Examples

    - {[ ++ATK; ]}
    - {[ -DEF ]} *)
