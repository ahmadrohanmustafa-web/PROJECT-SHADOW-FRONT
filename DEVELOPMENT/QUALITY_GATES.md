# Quality Gates

## Evidence labels
- **Designed:** requirements and acceptance criteria are documented.
- **Implemented:** code/assets exist in the project.
- **Automated-tested:** a repeatable automated test passed.
- **Playtested:** a human played the feature in the target build and recorded observations.
- **Polished:** known critical issues are resolved and the feature passed regression checks.

Never describe an untested feature as working.

## Required checks for each mission
- Mission can start and finish from a clean save.
- Objectives update in the correct order.
- Checkpoints and reloads preserve expected progress.
- Dialogue and subtitles display correctly.
- Companions do not block progression.
- Audio levels and subtitle timing are acceptable.
- No progression-blocking errors are present.
- Performance is measured on the selected target hardware.

## Required checks for shared systems
- Input rebinding updates prompts and gameplay.
- Settings persist after restart.
- Save/load survives application restart.
- Audio sliders affect the correct buses.
- UI remains readable at supported resolutions.
- Graceful handling exists for missing or invalid assets.

## Reporting format
For every development update, record:
1. What changed (commit/file references).
2. What was tested and exact result.
3. What was not tested.
4. Known bugs and blockers.
5. Next smallest useful task.
