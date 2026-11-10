# Development Log

## 2026-11-09 — Repository initialization
- Confirmed GitHub repository access and push permission.
- Confirmed default branch: `main`.
- Added the original design, story, gameplay, roadmap, and quality-gate documentation.
- Selected Godot 4.7.2 stable with the Compatibility renderer for Windows.
- Added the initial Godot project configuration and a greybox first-person movement prototype.
- Added player movement, mouse look, sprint, crouch, jump, and a simple collision test area.
- Added a prototype scope and manual validation checklist.
- Added a GitHub Actions validation workflow using the pinned Godot 4.7.2 standard build.
- Confirmed a successful headless import/parse and 120-frame main-scene startup run on the prototype commit.
- Updated jump input to trigger on a fresh key press rather than continuously while Space is held; the headless validation workflow passed again after this change.
- Added a Windows desktop export preset and a GitHub Actions workflow to export the prototype and upload its EXE/PCK artifact.
- The first Windows export workflow is pending. No interactive gameplay test or target-laptop playtest has passed yet.

### Next action
Complete and inspect the first Windows export artifact, then arrange a real interactive test on the target laptop.


## 2026-11-10 — Controls and pause-flow improvements
- Added persistent field-of-view and invert-Y controls to the pause menu.
- Added a pause-allowed gate so modal briefing/intel/debrief states can prevent accidental pause-menu opening.
- Kept settings within the lightweight Compatibility-renderer prototype.
- Previous restart/save update passed Godot headless validation and Windows export; this controls batch is awaiting CI.
- Interactive gameplay and target-laptop testing remain outstanding.
