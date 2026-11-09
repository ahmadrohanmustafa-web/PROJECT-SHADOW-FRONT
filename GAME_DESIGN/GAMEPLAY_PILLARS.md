# Gameplay Pillars — PROJECT: SHADOW FRONT

## First-person controls
The final mapping depends on the selected engine and platform. The target PC layout should support:
- Move, look, jump, crouch, sprint, interact, and contextual actions.
- A configurable input menu with rebinding, sensitivity, invert-look, and accessibility settings.
- Separate controller layout and vibration options if supported.
- Clear UI prompts that always reflect the active bindings.
- Optional reduced camera motion and adjustable field of view where supported.

## Movement feel
Priorities are responsiveness, readable animation, consistent acceleration, stable camera behaviour, and smooth transitions between idle, walk, sprint, crouch, and traversal states. Movement should feel polished rather than artificially difficult.

## Squad companions
Companions are narrative characters, not disposable units. Their game behaviours should be understandable and dependable:
- Follow the player while maintaining sensible spacing.
- Regroup when the player moves to a new story area.
- React to mission events and dialogue context.
- Provide non-instructional contextual support in scripted encounters.
- Avoid blocking doors, objectives, camera views, or the player's movement.
- Recover gracefully if navigation fails, with debug visibility for developers.
- Use authored barks sparingly and avoid repetitive dialogue.

## Fictional equipment
Use invented equipment names and fictionalized categories. Each item should have a clear gameplay role, readable feedback, distinct audio/visual identity, and balanced progression. Keep mechanics abstract and entertainment-focused; do not model real-world weapon operation or provide real-world tactical instruction.

## Audio direction
- Separate dialogue, ambience, music, UI, and gameplay sound buses.
- Support subtitles, dialogue volume, music volume, effects volume, and dynamic range options.
- Use spatial audio where supported.
- Ensure important dialogue remains intelligible.
- Avoid excessive repetition; use cooldowns and contextual variation.
- Provide original or properly licensed audio assets with documented sources.

## Camera and presentation
- Cinematic transitions must not unexpectedly take control away from the player.
- Provide subtitles and accessibility options for important story information.
- Avoid excessive shake, forced blur, or motion effects.
- Use in-engine sequences where practical so characters and environments remain visually consistent.

## Progression
Progression should reward campaign completion, exploration, optional objectives, and character moments. Avoid pay-to-win systems; the intended experience is a complete single-player campaign.

## Quality principles
Every feature must be testable, configurable where appropriate, and designed to work on the target hardware.
