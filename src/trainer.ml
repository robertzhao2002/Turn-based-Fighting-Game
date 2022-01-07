open Creature

exception NoMoreRevives

exception CreatureNotDead of Creature.t

exception InvalidSwitch

exception InvalidCreature

exception NoCreaturesDead

type t = {
  name : string;
  creature1 : Creature.t;
  creature2 : Creature.t;
  creature3 : Creature.t;
  revive_used : bool;
}

let init_trainer name c1 c2 c3 =
  { name; creature1 = c1; creature2 = c2; creature3 = c3; revive_used = false }

let name trainer = trainer.name

let all_alive trainer =
  dead trainer.creature1 |> not
  && dead trainer.creature2 |> not
  && dead trainer.creature3 |> not

let all_dead trainer =
  dead trainer.creature1 && dead trainer.creature2 && dead trainer.creature3

let has_creature trainer creature =
  trainer.creature1 = creature || trainer.creature2 = creature || trainer.creature3 = creature

let creature_with_name trainer n =
  if String.lowercase_ascii trainer.creature1.name = n then trainer.creature1
  else if String.lowercase_ascii trainer.creature2.name = n then trainer.creature2
  else if String.lowercase_ascii trainer.creature3.name = n then trainer.creature3
  else raise InvalidCreature

let other_creature_with_name trainer n =
  if String.lowercase_ascii trainer.creature2.name = n then (trainer.creature2, 2)
  else if String.lowercase_ascii trainer.creature3.name = n then (trainer.creature3, 3)
  else raise InvalidCreature

let creature_of trainer = trainer.creature1

let use_move trainer move =
  { trainer with creature1 = Creature.use_move_with_name trainer.creature1 move }

let switch trainer creature_name =
  let new_battling_creature, order =
    try other_creature_with_name trainer creature_name with
    | InvalidCreature -> raise InvalidCreature
  in
  let switched_out = Creature.reset_stats trainer.creature1 true in
  match order with
  | 2 -> { trainer with creature1 = new_battling_creature; creature2 = switched_out }
  | 3 -> { trainer with creature1 = new_battling_creature; creature3 = switched_out }
  | _ -> raise InvalidCreature

let revive (trainer : t) revived_name =
  match trainer.revive_used with
  | true -> raise NoMoreRevives
  | false ->
      let c1name = trainer.creature1.name in
      let c2name = trainer.creature2.name in
      let c3name = trainer.creature3.name in
      if all_alive trainer then raise NoCreaturesDead
      else if revived_name = c1name then
        if dead trainer.creature1 then
          {
            trainer with
            creature1 =
              {
                (init_creature_with_name trainer.creature1.name) with
                hp = base_hp trainer.creature1 /. 2.;
                revived = true;
              };
            revive_used = true;
          }
        else raise (CreatureNotDead trainer.creature1)
      else if revived_name = c2name then
        if dead trainer.creature2 then
          {
            trainer with
            creature2 =
              {
                (init_creature_with_name trainer.creature2.name) with
                hp = base_hp trainer.creature2 /. 2.;
                revived = true;
              };
            revive_used = true;
          }
        else raise (CreatureNotDead trainer.creature2)
      else if revived_name = c3name then
        if dead trainer.creature3 then
          {
            trainer with
            creature3 =
              {
                (init_creature_with_name trainer.creature3.name) with
                hp = base_hp trainer.creature3 /. 2.;
                revived = true;
              };
            revive_used = true;
          }
        else raise (CreatureNotDead trainer.creature3)
      else raise InvalidCreature

let trainer_string trainer =
  Printf.sprintf "%s%s%s%s%s%s" trainer.name
    (if trainer.revive_used then "" else "\nREVIVE")
    ("\n" ^ creature_string trainer.creature1 ^ " (IN BATTLE)")
    (if dead trainer.creature2 && trainer.revive_used then ""
    else "\n" ^ creature_string trainer.creature2)
    (if dead trainer.creature3 && trainer.revive_used then ""
    else "\n" ^ creature_string trainer.creature3)
    ("\n" ^ Creature.creature_moves_string trainer.creature1)
