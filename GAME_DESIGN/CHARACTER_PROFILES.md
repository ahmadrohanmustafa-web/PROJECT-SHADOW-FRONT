# Character Profiles — PROJECT: SHADOW FRONT

## Elias Rook
**Role:** Squad communications and systems specialist  
**First appearance:** Mission 01 — Northstar: First Contact  
**Function in the story:** The player's first squad partner and a recurring source of context, observations, and character-driven dialogue.

### Character
Elias is patient, detail-oriented, and quietly funny. He prefers to verify information before acting on it. He is good at noticing inconsistencies in reports and technical records, but he sometimes struggles to trust people when evidence is incomplete.

### Relationship with the player
Elias is assigned as the player's partner during the Northstar operation. Their early exchanges should establish mutual respect rather than instant friendship. Over the campaign, their trust develops through shared discoveries, difficult decisions, and moments of disagreement.

### Gameplay presence
- Keeps a comfortable distance behind or beside the player.
- Catches up when the player moves too far ahead.
- Offers short contextual check-ins when the player presses E nearby.
- Does not block doorways or movement.
- Uses lightweight placeholder geometry in the first prototype; final character art, animation, voice, and cinematic scenes are future work.

### Voice direction
Measured, observant, understated. Avoid constant chatter. Dialogue should be short and situational, with occasional dry humour.

### Initial prototype radio lines
- "I'm with you. Let's bring that data home."
- "Keep moving. The rendezvous is back across the yard."
- "Terminal is behind us. Stay close until we're clear."

### Production notes
The current follower is a prototype implementation. It uses a simple distance-based follow behaviour on the flat greybox floor. It does not yet use navigation meshes, obstacle avoidance, animation, pathfinding, voice audio, or advanced squad commands. These must be added and tested before the companion is considered production-ready.

## Character continuity rules
- Keep dialogue consistent with each character's established personality.
- Let squad members disagree respectfully and for understandable reasons.
- Avoid making companions invulnerable or omniscient.
- Use the squad to deepen the story, not merely to provide exposition.
