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
A GitHub Actions workflow runs the following checks on pushes and pull requests to `main`:
1. Install the pinned Godot 4.7.2 standard build.
2. Import and parse the project in headless editor mode.
3. Launch the main scene headlessly for 120 frames.

A separate Windows workflow exports a debug executable and uploads the EXE/PCK as a 14-day GitHub Actions artifact. This is a prototype build for testing, not a final installer.

A passing headless workflow verifies import/parse and basic scene startup. A successful export verifies packaging only; neither proves visual correctness, input feel, frame rate, or compatibility on the target laptop.

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
- [ ] Windows export workflow completes and its artifact is inspected

## Status
Source implemented and committed. GitHub Actions successfully installed Godot 4.7.2, imported/parsed the project, and launched the main scene headlessly for 120 frames, including after the jump-input fix. A Windows export preset and artifact workflow are now committed; their first build is pending. No interactive gameplay test or target-laptop performance claim is recorded yet.
