open Creature

exception NoMoreRevives

exception CreatureNotDead of Creature.t

exception InvalidCreature

exception NoCreaturesDead

type trainer_turn =
  | Switch of Creature.t
  | MoveUsed of Creature.t * Move.t
  | Revive of Creature.t
  | Surrender

type t = {
  name : string;
  creature1 : Creature.t;
  creature2 : Creature.t;
  creature3 : Creature.t;
  revive_used : bool;
}

let init_trainer name c1 c2 c3 =
  { name; creature1 = c1; creature2 = c2; creature3 = c3; revive_used = false }

let all_alive trainer =
  dead trainer.creature1 |> not
  && dead trainer.creature2 |> not
  && dead trainer.creature3 |> not

let use_move trainer creature move = MoveUsed (creature, move)

let revive (trainer : t) (creature : Creature.t) =
  match trainer.revive_used with
  | true -> raise NoMoreRevives
  | false ->
      let revived_name = creature.name in
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
                hp = hp trainer.creature1 /. 2.;
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
                hp = hp trainer.creature2 /. 2.;
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
                hp = hp trainer.creature3 /. 2.;
              };
            revive_used = true;
          }
        else raise (CreatureNotDead trainer.creature3)
      else raise InvalidCreature

let surrender t = Surrender
