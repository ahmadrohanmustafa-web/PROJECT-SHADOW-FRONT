# Prototype 01 — First-Person Movement

## Engine pin
- Godot 4.7.2 stable
- Standard (non-.NET) build
- Compatibility renderer (OpenGL)
- Windows 10 64-bit target

## Included
- First-person mouse look with pitch limits
- WASD movement
- Sprint with a modest field-of-view transition
- Jump
- C crouch toggle and Ctrl crouch hold
- Escape to release/capture the mouse; click to recapture
- Lightweight greybox room with basic collision
- On-screen control reminder

## Automated validation
GitHub Actions runs the following checks on pushes and pull requests to `main`:
1. Install the pinned Godot 4.7.2 standard build.
2. Import and parse the project in headless editor mode.
3. Launch the main scene headlessly for 120 frames.

A passing workflow verifies import/parse and basic scene startup. It does not prove visual correctness, input feel, frame rate, or compatibility on the target laptop.

## Manual validation checklist
- [ ] Project opens in Godot 4.7.2 without parse/import errors
- [ ] Main scene launches
- [ ] Player remains on the floor and collides with blocks
- [ ] WASD movement and mouse look work
- [ ] Sprint changes movement speed and returns to normal
- [ ] Jump works only while grounded
- [ ] C and Ctrl crouch; standing height returns correctly
- [ ] Escape releases the mouse and click captures it
- [ ] 1280x720 low-cost scene is usable on Intel HD 520
- [ ] Exported Windows build launches outside the editor

## Status
Source implemented and committed. Automated validation workflow is configured; the first GitHub Actions runs are currently in progress. No successful automated test, gameplay test, or target-laptop performance claim is recorded yet.
