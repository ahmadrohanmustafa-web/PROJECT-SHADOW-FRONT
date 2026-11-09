# PROJECT: SHADOW FRONT

An original single-player first-person cinematic action campaign.

## Player-facing goal
The finished Windows release should be downloadable, installable, and playable without the player needing to open an editor or write code.

## Target machine
- CPU: Intel Core i5-6200U class
- RAM: 16 GB
- GPU: Intel HD Graphics 520 class integrated graphics
- Storage: SSD
- Initial target resolution: 1280x720
- Graphics: scalable low settings, with a performance-first default

## Download and installation budget
- Desired installed/download footprint: approximately 15 GB.
- Absolute package ceiling: 20 GB.
- This is a ceiling, not a requirement to fill the disk with unused assets. Use compression and quality tiers.

## Engine
Godot 4.7.2 stable, standard edition, Compatibility renderer. The engine patch is pinned for the first prototype milestone.

## Current development status
The repository now contains the first source-level playable prototype:
- First-person mouse look
- WASD movement
- Sprint and jump
- Crouch toggle and hold
- A lightweight greybox test area with collision

**Important:** source code has been committed, but it has not yet been validated in the Godot editor or run in-game. There is no Windows installer or finished campaign build yet.

## Project principles
- Original fictional setting, characters, story, factions, locations, and equipment.
- Story-first single-player campaign.
- Responsive configurable controls and accessible presentation.
- Believable squad characters and cinematic audio.
- Performance and stability on the stated target PC.
- Original or properly licensed assets only.

See [GAME_DESIGN](GAME_DESIGN/) and [DEVELOPMENT](DEVELOPMENT/) for the design and production plan.
