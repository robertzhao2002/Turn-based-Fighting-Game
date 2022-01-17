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
  | AccuracyS of float * float * bool
  | Evasiveness of float * float * bool

(** The type representing the possible accuracies of a move: either a changing accuracy after
    opponents may use accuracy-reducing moves, or [Guarantee], which means that a move will
    always land, regarldess if anyone uses any accuracy/evasiveness-changing moves. *)
type accuracy =
  | Accuracy of float
  | Guarantee

type t = {
  name : string;
  mtype : Typematchup.t;
  power : int;
  accuracy : accuracy;
  uses : int;
  meffect : effect list;
  mstat_change : stat_change list;
}
(** The type representing the current state of a move. *)

val init_move_with_name : string -> t
(** [init_move_with_name n] creates a [Move] type with name [n]. It will have the maximum
    number of uses. *)

val name : t -> string
(** [name m] is the name of move [m]. *)

val move_type_of : t -> Typematchup.t
(** [move_type_of m] is the type of move [m] (e.g. [Type1], [Type2], [Type3], etc.). *)

val base_power : t -> int
(** [base_power m] is the base power of move [m]. This determines how much damage [m] can
    potentially do. Moves with higher base power will do more damage when used by the same
    creature. *)

val base_accuracy : t -> float
(** [base_accuracy m] is the base accuracy of move [m], which is a floating point number
    between 0 and 1. This determines how likely the move will hit the target. If it hits the
    target, it will do damage based on the base power and base attack stat of the creature. If
    it does not hit (misses), then 0 damage is done. *)

val total_uses : t -> int
(** [total_uses m] is the number of times move [m] can be used in a battle. Each move has a
    predetermined number of uses. Every time u use [m], this number decrements. Whenever
    [uses m] is 0, then [m] cannot be used anymore. When a creature has no more moves to use,
    it automatically dies, even if it is at full hp. *)

val effects : t -> effect list
(** [effects m] are the possible status effects, along with their probabilities in a list. *)

val stat_changes : t -> stat_change list
(** [stat_changes m] are the possible base stat changes, along with their amounts,
    probabilities, and targets in a list. *)

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
        Base Power: 100; Accuracy: 70.0%;
        Status Effects: 20.0% chance to poison; 20.0% chance to confuse;
        Stat Changes:  50.0% chance to reduce opponent attack by 50.0%; 20.0% chance to increase user defense by 50.0%;
      ]}
    - {[
        attack 2
        Type: type2
        Uses: 2/4
        Base Power: 100; Accuracy: 70.0%;
      ]} *)
