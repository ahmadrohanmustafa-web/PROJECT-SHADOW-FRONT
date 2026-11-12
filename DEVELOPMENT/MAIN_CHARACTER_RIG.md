# Main Character Rig

The uploaded root scene.gltf was inspected and contains no glTF skins and no animation clips. It is an unrigged, multi-material character.

## Generated character asset

The generated asset at assets/characters/player_character.glb is built from the original glTF by tools/rig_main_character.py. The generator preserves the material slots and source textures, normalizes the model to approximately 1.8 m with its feet at the origin, creates a humanoid skeleton, binds the mesh, and exports three generic locomotion clips: Idle, Walk, and Run.

This is an automated first rig pass. It must be visually inspected in Godot and adjusted if any clothing or equipment deforms incorrectly.

## Build

The GitHub Actions workflow named "Build and publish main-character rig" generates and commits the GLB whenever the source glTF, binary buffer, textures, or rig generator changes. Godot validation and Windows export also generate the asset in clean workspaces when needed.

## Camera and performance

The game currently uses a first-person camera. The full character mesh is placed on render layer 2 so it does not clip through the player's own camera; it remains available to cameras that include layer 2. The animation driver only switches between Idle, Walk, and Run with a short blend. No real-time IK or expensive animation systems are added.

## Required attribution

This character is based on "Solider" by FoFLaFe, licensed under CC-BY-4.0. Keep license.txt with the project and include this credit wherever the game is shared:

This work is based on "Solider" (https://sketchfab.com/3d-models/solider-3d546c9e0b2049828eab3f06d3199097) by FoFLaFe (https://sketchfab.com/FoFLaFe) licensed under CC-BY-4.0 (http://creativecommons.org/licenses/by/4.0/)
