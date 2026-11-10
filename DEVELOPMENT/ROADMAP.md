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
- [ ] Add remappable controls, sensitivity, and accessibility settings.
- [x] Create a small greybox test environment.
- [x] Add interaction prompts and basic objective flow.
- [ ] Add audio buses, subtitles, and settings persistence.
- [ ] Export a Windows build and measure performance on target hardware.

## Phase 2 — Vertical slice
- [x] Build a first source-level mission flow from briefing to debrief (manual playtest still pending).
- [x] Add one prototype companion with basic follow and check-in dialogue (navigation and obstacle avoidance pending).
- [ ] Add save/load and mission transitions; objective tracking, a checkpoint, and basic dialogue are implemented.
- [ ] Add original placeholder art, animation, and licensed/original audio.
- [ ] Run automated checks and structured playtests.
- [ ] Measure frame rate, memory, loading, and stability on the actual laptop.

## Phase 3 — Campaign production
- [ ] Lock story bible and mission beat sheets.
- [ ] Build reusable mission, dialogue, cinematic, save, and companion systems.
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
- Elias Rook has a lightweight follower controller and basic check-in dialogue. This is not yet production-grade navigation or animation.
- Godot headless validation has passed for the terminal/debrief implementation before the latest prompt/documentation-only updates. Latest CI status should be checked before treating the newest commit as validated.
- No manual gameplay test or Intel HD 520 performance measurement has been completed.

## Milestone rule
Do not call a feature complete merely because code exists. Track it as Designed, Implemented, Automated-tested, Playtested, and Polished. State clearly which evidence exists.
