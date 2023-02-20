type t =
  | Effective of float
  | SuperEffective of float
  | NotVeryEffective of float
  | NoEffect of float

  val incoming_move_effectiveness_on_creature: Core.t -> Core.t * Core.t option * Core.t option -> float

  