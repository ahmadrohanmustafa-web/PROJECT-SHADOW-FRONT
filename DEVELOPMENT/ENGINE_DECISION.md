# Engine Decision — Pending

The repository is currently engine-agnostic. Do not generate engine-specific gameplay code until the engine and target platform are confirmed.

## Options under consideration
- **Roblox Studio:** practical for rapid iteration and a low-spec development machine; the final game runs within Roblox's platform and technical constraints.
- **Unity:** suitable for a standalone 3D campaign with C#; project complexity and performance must be kept within the target PC's capabilities.
- **Unreal Engine 5:** offers high-end rendering and cinematic tooling but has a much heavier editor and hardware footprint.

## Known development constraint
The developer's current PC is an HP ProBook 450 G3 with Intel HD Graphics 520 and 16 GB RAM. The selected engine must be practical to open, edit, build, and test on this machine, or a separate stronger development machine/cloud workflow must be available.

## Decision required
Confirm:
1. Engine: Roblox Studio, Unity, Unreal Engine 5, or another engine.
2. Target: Windows PC only, or another platform too.
3. Development machine: current HP ProBook only, or access to a stronger PC.

## Decision status
Pending developer confirmation.
