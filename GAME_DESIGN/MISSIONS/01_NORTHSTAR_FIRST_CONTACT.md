# Mission 01 — Northstar: First Contact

## Purpose
Introduce the player to the campaign, establish Elias Rook as the first squad partner, teach the core movement and interaction loop, and reveal the first contradiction behind the Veyra emergency broadcasts.

## Mission flow
1. **Deployment briefing** — The player receives the assignment before control is enabled.
2. **Approach the warehouse** — Move through the Northstar yard and reach the loading bay.
3. **Checkpoint** — The warehouse entrance becomes the recovery point.
4. **Recover the incident log** — Approach the terminal and press E. The player reads a short record showing that the emergency alert was authenticated after the relief convoy had checked in safely.
5. **Squad check-in** — Elias offers short contextual lines when the player presses E nearby.
6. **Return to rendezvous** — Reach the marked extraction point.
7. **Mission debrief** — A completion screen records that the data is secured and introduces the question that drives the next mission.

## Narrative evidence
The incident log establishes a timeline inconsistency without immediately explaining who created it. A second entry references an external relay tagged VEYRA-7. The sender identity is missing from the recovered copy.

The clue should create a question for the player, not solve the campaign mystery in the opening mission.

## Character direction
Elias Rook is observant and evidence-focused. His line about the timestamp should be restrained: he identifies the discrepancy and avoids guessing who is responsible.

## Prototype implementation status
- [x] Deployment briefing overlay
- [x] Three-stage objective flow
- [x] Warehouse checkpoint
- [x] Lightweight Elias follower
- [x] Basic squad check-in dialogue
- [x] Interactive terminal intel overlay
- [x] Extraction objective
- [x] Mission completion debrief overlay
- [ ] Final character model and animation
- [ ] Voice performance and original audio
- [ ] Navigation mesh and obstacle-aware companion movement
- [ ] Cinematic opening and transition shots
- [ ] Save/load and mission replay
- [ ] Manual playtest on the target laptop

## Acceptance tests
- The terminal objective must not complete merely by walking near the terminal.
- Pressing E near the terminal opens the intel record only while the data-recovery objective is active.
- Pressing Enter closes the record, completes the recovery objective, and updates the objective to extraction.
- Pressing E near Elias displays one dialogue line, not multiple lines from a single key press.
- Reaching the extraction marker completes the mission exactly once.
- The completion overlay appears after the final objective.
- The player and companion remain controllable after the briefing and intel overlay close.
- The mission remains playable at 1280x720 with low-cost rendering settings; actual laptop performance still requires manual measurement.
