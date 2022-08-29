type t =
  | Attack of float * float * bool
  | Defense of float * float * bool
  | Speed of float * float * bool

val bind : t -> (float * float * bool -> 'a) -> 'a

val single_as_string : t -> string

val as_string : t list -> string

module Adapter : sig
  val to_object : Yojson.Basic.t -> t
end
