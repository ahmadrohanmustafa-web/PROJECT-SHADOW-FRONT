# Development Roadmap

## Release target
A standalone Windows single-player campaign that the player can download, install, and launch without opening a development editor.

Target hardware: Intel Core i5-6200U class CPU, Intel HD Graphics 520 class integrated GPU, 16 GB RAM, SSD. Initial baseline: 1280x720 on low settings.

Storage budget: approximately 15 GB desired; 20 GB absolute ceiling. Do not inflate the build with unnecessary content.

## Phase 0 — Foundation
- [x] Create repository and initial project documentation.
- [x] Establish original-IP and safety boundaries.
- [x] Select Godot 4.x Compatibility renderer as engine direction.
- [ ] Pin exact stable engine version and export templates.
- [ ] Record asset licensing and contribution conventions.

## Phase 1 — Playable technical prototype
- [x] Create a reproducible Godot Windows project.
- [x] Implement first-person movement, camera, and input actions.
- [ ] Add remappable controls; mouse sensitivity, field of view, invert-Y, and low-detail settings are configurable and saved locally.
- [x] Create a small greybox test environment.
- [x] Add interaction prompts and basic objective flow.
- [ ] Add audio buses and subtitle presentation; basic graphics and mouse settings persistence is implemented.
- [ ] Export a Windows build and measure performance on target hardware.

## Phase 2 — Vertical slice
- [x] Build a first source-level mission flow from briefing to debrief (manual playtest still pending).
- [x] Add one prototype companion with follow, raycast-based lightweight obstacle steering, and objective-context check-in dialogue (full navigation/pathfinding pending).
- [x] Add local save/load for Northstar objective progress and checkpoint recovery; mission transitions remain pending.
- [ ] Add original placeholder art, animation, and licensed/original audio.
- [ ] Run automated checks and structured playtests.
- [ ] Measure frame rate, memory, loading, and stability on the actual laptop.

## Phase 3 — Campaign production
- [ ] Lock story bible and mission beat sheets.
- [ ] Build reusable mission, dialogue, cinematic, save, and companion systems; local save/settings foundations are implemented.
- [ ] Produce missions in small, testable increments.
- [ ] Track narrative continuity and asset provenance.
- [ ] Playtest every mission and the full campaign.

## Phase 4 — Polish and release
- [ ] Controls, accessibility, subtitle, and audio-mix review.
- [ ] Graphics presets and performance tuning.
- [ ] Save-data, stability, and regression testing.
- [ ] Full-campaign playthroughs.
- [ ] Package a standalone Windows installer/archive within the 20 GB ceiling.
- [ ] Publish release notes and known issues.

## Current vertical-slice evidence
- Northstar has a deployment briefing, ordered objectives, a warehouse checkpoint, an interactive terminal evidence screen, an extraction objective, and a mission debrief.
- Elias Rook has a lightweight follower with raycast-based obstacle steering and objective-context check-in dialogue. This is not production-grade navigation or animation.
- Northstar progress and checkpoint position are persisted locally through Godot ConfigFile under `user://`; save/load still needs runtime playtesting.
- A pause menu now exposes resume, confirmed mission restart, manual progress save, low-detail mode, mouse sensitivity, field of view, and invert-Y settings, with settings persisted locally.
- Mission 02, **The Quiet District**, has a complete narrative/gameplay beat sheet and acceptance tests; it is designed, not yet playable.
- Godot headless validation has passed for the terminal/debrief implementation before the latest prompt/documentation-only updates. Latest CI status should be checked before treating the newest commit as validated.
- No manual gameplay test or Intel HD 520 performance measurement has been completed.

## Milestone rule
Do not call a feature complete merely because code exists. Track it as Designed, Implemented, Automated-tested, Playtested, and Polished. State clearly which evidence exists.
