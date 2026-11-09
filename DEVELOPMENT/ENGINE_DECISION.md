# Engine Decision — Selected Direction

## Selected engine
**Godot 4.7.2 stable — Compatibility renderer — Windows PC**

Godot 4.7.2 is the pinned stable engine version for the first prototype. Godot 4.8 is still in beta at the time of this decision, so the project will not use it for this milestone. The Compatibility renderer is selected to prioritize broad graphics compatibility and lower-end hardware over expensive rendering features.

Use the standard (non-.NET) editor and matching 4.7.2 export templates. Do not silently upgrade engine versions mid-milestone. Engine upgrades require a separate compatibility check.

## Target player machine
- CPU: Intel Core i5-6200U class
- GPU: Intel HD Graphics 520 class integrated graphics
- RAM: 16 GB
- Storage: SSD
- Initial target: Windows 10 64-bit
- Initial performance profile: 1280x720, low preset, performance-first defaults

## Visual strategy
Aim for grounded, convincing art direction through composition, material response, lighting discipline, animation, effects restraint, environmental storytelling, and sound—not expensive photorealistic rendering. Avoid relying on ray tracing, heavy global illumination, dense real-time shadows, or high-end GPU features.

## Player deliverable
The intended final deliverable is a standalone Windows build with a straightforward install/launch experience. The player should not need Godot, source code, or an editor installed.

## Storage budget
- Desired final footprint: approximately 15 GB.
- Absolute download/install ceiling: 20 GB.
- Treat this as a maximum budget, not a quota. Prefer efficient original assets, sensible texture/audio compression, and optional high-quality extras only if they fit.
- GitHub should store source, documentation, tests, and small licensed assets. Large release builds and asset bundles should use release artifacts or an appropriate external distribution method.

## Development constraints
The current laptop may struggle with both editor workload and game runtime. Keep scenes modular, use low-cost materials and lighting, provide scalability options, and test exported builds—not just editor previews. If the editor itself becomes impractical, use a stronger build machine or a cloud build workflow rather than pretending local tests passed.

## Decision status
Engine and exact stable patch version are pinned for Prototype 01. The prototype project uses the Compatibility renderer. Measured performance and Windows export validation remain outstanding.
