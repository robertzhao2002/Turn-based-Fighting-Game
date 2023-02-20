type t =
  | Stun
  | Paralyze of bool
  | Confuse of int option
  | Poison of bool

type prob =
  | PoisonProbability of float
  | StunProbability of float
  | ParalyzeProbability of float
  | ConfuseProbability of float

let probability_as_string = function
  | PoisonProbability chance -> Util.Helper.percent_string chance ^ " chance to poison"
  | ConfuseProbability chance -> Util.Helper.percent_string chance ^ " chance to confuse"
  | ParalyzeProbability chance -> Util.Helper.percent_string chance ^ " chance to paralyze"
  | StunProbability chance -> Util.Helper.percent_string chance ^ " chance to stun"

let probabilities_as_string = function
  | [] -> ""
  | effects ->
      let rec e_to_s_tr acc = function
        | [] -> acc
        | h :: t -> e_to_s_tr (acc ^ " " ^ probability_as_string h ^ ";") t
      in
      e_to_s_tr "\nStatus Effects:" effects

module Adapter = struct
  let to_object json_object =
    let effect = Util.Json.value_from_json json_object "effect" Yojson.Basic.Util.to_string in
    let probability =
      Util.Json.value_from_json json_object "probability" Yojson.Basic.Util.to_float
    in
    match effect with
    | "stun" -> StunProbability probability
    | "paralyze" -> ParalyzeProbability probability
    | "confuse" -> ConfuseProbability probability
    | "poison" -> PoisonProbability probability
    | _ -> raise (Failure ("Invalid Effect: " ^ effect))
end
