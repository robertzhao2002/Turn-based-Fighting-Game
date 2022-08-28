type t =
  | Attack of float * float * bool
  | Defense of float * float * bool
  | Speed of float * float * bool

val stat_change_as_string : t -> string

val stat_changes_as_string : t list -> string

module Adapter : sig
  val to_object : Yojson.Basic.t -> t
end
