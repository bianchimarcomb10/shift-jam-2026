# Shift into Silence

Game Off 2026 entry: a mecha elegy.

The theme of the jam is SHIFT. In this game the Shift key is the whole thing: it turns your ship into a mecha, and the mecha back into a ship.

This is my very first game. I made it in GameMaker.

## How to play

You start on the ground, inside the mecha. The aliens come from every side. Fight as long as you can, and when they cover you, press SHIFT.

Then you fly. The waves follow the music, so they come always at the same moment. At the end there is the boss.

| Key | What it does |
| --- | --- |
| WASD or arrows | move |
| Z or Space | attack: the ship shoots, the mecha swings the scythe |
| SHIFT | change from ship to mecha, and back |
| P or Esc | pause |
| M | sound off and on |

Some things that are good to know:

- The mecha can parry the enemy bullets with the scythe. A parried bullet goes back against the enemies.
- When a wall of bullets comes, press SHIFT first, then Z or Space.
- You can take 3 hits. A heart repairs one.
- The special weapons (rockets, laser, spread) have ammo, and only the ship can use them.
- Near the end you get a drill. The parried bullets that hit an enemy charge it. When it is full, press SHIFT while you are the mecha and the drill flies.
- If you die, you start again from the last checkpoint.

## Open the project

You need GameMaker (I used version 2026.0). Open `shift-jam/shift-jam.yyp` and press F5.

## What is in this repository

- `shift-jam/` is the GameMaker project.
- `tools/` has the small Python scripts I used to make some sounds and graphics: the siren, the sounds of the opening scene, the game sounds, the ground and the colors of the mecha. They need Python 3 and NumPy. The graphics ones need Pillow too.

## Credits

- Game by Marco Bianchi (Chelios)
- Music by Emanuele Luigi Andolfi (Cubesando)
- Mecha design by Francesco "Rocketbird" Passero
- Ships and enemies from the Void packs by Baldur for Foozle (CC0)
- Font: Press Start 2P by CodeMan38, under the SIL Open Font License 1.1 (the license is in `OFL-PressStart2P.txt`)
- Thank you to all the playtesters: my friends and the subscribers of Side Quest Podcast.

The full list, with links and licenses, is in [CREDITS.md](CREDITS.md).

Dedicated to my beloved Ginevra.

## License

The code is under the MIT license (see [LICENSE](LICENSE)). The music and the mecha sprites are not: they belong to their authors, and I use them with their permission. The cinematic explosion is a royalty-free sound from a third party. All the details are in CREDITS.md.
