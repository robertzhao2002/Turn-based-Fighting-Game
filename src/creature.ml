open Yojson.Basic.Util

type status =
  | Poison
  | Confuse
  | Paralyze

type t = {
  name : string;
  hp : int;
  attack : int;
  defense : int;
  speed : int;
  status : status option;
  moves : Move.t list;
}

let name c = c.name

let hp c = c.hp

let attack c = c.attack

let defense c = c.defense

let speed c = c.speed

let status_of c = c.status
