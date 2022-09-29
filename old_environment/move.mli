exception NoMoreUses
(** [NoMoreUses] is raised when someone attempts to use a move with [uses = 0]. *)

(** The type representing the status effect a move can inflict, each binded with a floating
    point number between 0 and 1 that represents the probability that the using a given move
    will cause that given status effect to happen.

    - [Poison]: takes 5% hp each turn
    - [Stun]: Guaranteed to not attack for a single turn
    - [Paralyze]: 50% chance that the creature will not move for that given turn. Speed is
      permanently reduced by 25%. Attacks will always hit.
    - [Confuse]: 50% chance that the creature will attack themselves. *)
type effect =
  | Poison of float
  | Stun of float
  | Paralyze of float
  | Confuse of float

(** The type representing possible increases or decreases to the base stats of a creature. The
    first float in the tuple is a positive floating point number that represents the change
    factor of that given base stat. The second float is a floating point number between 0 and 1
    that represents the probability that a given move will cause the stat change. The bool in
    the tuple represents the target of the stat change. [true] represents yourself, and [false]
    represents your opponent.

    Ex. [Attack (0.5, 0.3, false)] means a 30% chance to reduce the opponent's attack stat by
    50%. *)
type stat_change =
  | Attack of float * float * bool
  | Defense of float * float * bool
  | Speed of float * float * bool

type t = {
  name : string;
  move_type : Typematchup.t;
  base_power : int;
  current_uses : int;
  total_uses : int;
  move_effect : effect list;
  move_stat_change : stat_change list;
}
(** The type representing the current state of a move. *)

val init_move_with_name : string -> string -> t
(** [init_move_with_name name] creates a [Move] type with name [name] from a JSON file with
    name [file_name]. This file MUST live under the [moves_data] folder and follow the
    structure in the [schema.json]. Please omit the [.json] suffix or else the file will not be
    found. It will have the maximum number of uses. *)

val use : t -> t
(** [use m] is the state of the move after one use. Its [uses] property will decrease by 1.
    This function raises [NoMoreUses] if there are no uses left. *)

val move_string : t -> string
(** [move_string m] is all of the details of [m]. This includes its base power, type, current
    uses as a fraction, base accuracy, potential status effects and associated probabilities,
    potential stat changes and associated probabilities, and type.

    Examples

    - {[
        attack 1
        Type: type1
        Uses: 5/10
        Base Power: 100;
        Status Effects: 20.0% chance to poison; 20.0% chance to confuse;
        Stat Changes:  50.0% chance to reduce opponent attack by 50.0%; 20.0% chance to increase user defense by 50.0%;
      ]}
    - {[
        attack 2
        Type: type2
        Uses: 2/4
        Base Power: 100;
      ]} *)
