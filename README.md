# CLI Turn-based Fighting Game #

## About ##

This program reads data from a JSON document containing creature and move data and uses that data to create a turn-based 2-player game. Each player takes turns performing an action (using a move, reviving another creature, or switching to another creature) until either a player surrenders or all of the creatures dies. When both players choose to use a move, the creature with the faster speed stat will go first.

## Game Mechanics ##

### Player Actions ###

Players will take turns choosing an action. There are 4 possible actions that can be taken: switching, reviving, using a move, or surrendering. Once both players have performed an action, the game engine will determine a result based on various factors, which include status effects and the creatures' speeds.

### 2-Player Mode ###

This game involves 2 players taking turns performing actions (more on these below). The game ends when a player surrenders, or when all of a player's 3 creatures die. Players have 1 revive to use per match, but they cannot revive when all 3 creatures have died.

### Vs. Computer aka Single-Player [WIP] ###

This game mode involves the player playing against the computer. You simply pick your action, and the computer will automatically act based on what you pick. The goal is to defeat the computer by killing all 3 of the computer's creatures. The computer will pick creatures based on optimal type matchups and speed.

## Commands ##

### Informational ###

- `summary [creature]`: gives a breakdown of the creature's stats (attack, defense, speed) and moveset
- `info [current-creature-move]`: gives information of the move of the current creature
- `info [other-creature];[other-creature-mmove]`: gives information of the move of the creature indicated

### User Action ###

- `switch [creature-name]`: changes the current creature in battle to the creature indicated
- `revive [creature-name]`: revives the given creature
- `use [move-name]`: makes the creature in battle use the given move, which decrements its remaining uses by 1
- `surrender`: forfeits the match and declares the other player as the winner

**NOTE**: switching and reviving will always be done first after both players choose their action. After this is done, moves are used. When both players choose to use moves, the player with the faster creature in battle will move first.

### Death Action ###

Whenever a creature dies during a turn, that player must choose to revive that creature or switch into a creature that is not dead.

```[creature-name] has died. Please send in a new creature:```

A player can type in the name of the recently dead creature to revive it (if they still have their revive), or type the name of another creature to switch into it. A new turn will proceed after this.

## Creating Your Own Creatures and Moves ##

To create your own creatures and moves, follow the sample **JSON** files in the `moves_data` and `creatures_data` folders.

- [Move JSON](/moves_data)
- [Creature JSON](/creatures_data)

## Installation and Playing the Game ##

To install this game, you need to have OCaml installed on a Linux Computer. To run the game, run the command `make play` to play the game.
