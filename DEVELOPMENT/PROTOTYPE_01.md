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
- Crouch toggle with C and hold with Ctrl
- Escape to release/capture the mouse; click to recapture
- Lightweight greybox room with basic collision
- On-screen control reminder

## Deliberately not included
- Weapons or real-world handling simulation
- Combat, AI squad members, campaign missions, or cinematic sequences
- Final art, final audio, save system, settings menu, or controller support

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
Implemented in source. Not yet engine-validated, automated-tested, or playtested. No performance claim is made until the exported build is measured on the target laptop.
