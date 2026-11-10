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
The repository now contains an expanded first-mission prototype:
- First-person movement, sprint, jump, and crouch
- Northstar Terminal greybox environment
- Deployment briefing and three-stage mission objectives
- Warehouse checkpoint
- Lightweight squad companion Elias Rook with basic follow behaviour and check-in dialogue
- Interactive terminal intel record and mission debrief overlay
- Extraction rendezvous and mission completion flow

**Validation status:** recent commits have passed Godot 4.7.2 headless import/parse and main-scene startup checks, and Windows prototype exports have succeeded. The latest terminal-interaction/debrief changes are awaiting their own CI results. Interactive gameplay and target-laptop performance are not yet tested. This remains a greybox prototype, not a finished campaign or installer.

## Project principles
- Original fictional setting, characters, story, factions, locations, and equipment.
- Story-first single-player campaign.
- Responsive configurable controls and accessible presentation.
- Believable squad characters and cinematic audio.
- Performance and stability on the stated target PC.
- Original or properly licensed assets only.

See [GAME_DESIGN](GAME_DESIGN/) and [DEVELOPMENT](DEVELOPMENT/) for the design and production plan.
