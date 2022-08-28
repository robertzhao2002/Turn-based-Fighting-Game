type prob =
  | PoisonProbability of float
  | StunProbability of float
  | ParalyzeProbability of float
  | ConfuseProbability of float

val effect_as_string : prob -> string

val effects_as_string : prob list -> string

module Adapter : sig
  val to_object : Yojson.Basic.t -> prob
end
