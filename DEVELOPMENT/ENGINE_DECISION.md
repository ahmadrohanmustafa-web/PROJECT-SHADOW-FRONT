# Engine Decision — Selected Direction

## Selected engine
**Godot 4.x — Compatibility renderer — Windows PC**

This is the best starting direction for the stated target hardware: an HP ProBook 450 G3 with Intel Core i5-6200U, 16 GB RAM, SSD, and Intel HD Graphics 520. The Compatibility renderer is chosen to prioritize broad graphics compatibility and lower-end hardware over expensive rendering features.

The exact stable Godot 4 release and matching export templates must be pinned in the project before the first build. Do not silently upgrade engine versions mid-milestone.

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
Engine direction selected. Exact engine patch version, project settings, and measured performance baseline remain to be recorded during prototype setup.
