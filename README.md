# NMHub

A polished, all-in-one Roblox script hub built with the Sirius (Rayfield) UI Library. Features movement enhancements (NoClip, Flight, Infinite Jump) and a comprehensive ESP system with per-feature toggles.

---

## Features

### Movement & Combat
- **NoClip** — Walk through walls and terrain. Re-fetches character each frame for reliable respawn support.
- **Flight** — Camera-relative directional flight with adjustable speed (20–200 studs/s).
- **Infinite Jump** — Press Space mid-air for extra jumps. Single-jump-per-press; no jetpack behavior.

### Visuals (ESP)
- **Box ESP** — Bounding box around each player, calculated from actual projected body bounds (head to feet).
- **Corner Box ESP** — Clean corner-only box variant using the same bounds as Box ESP.
- **Name ESP** — Player name above the box.
- **Distance ESP** — Distance from camera in studs.
- **Health ESP** — Health text + health bar alongside the box.
- **Skeleton ESP** — Bone-based skeleton overlay (supports R6 and R15).
- **Tracers** — Line from screen bottom to each player.
- **Head Dot** — Circle indicator at head position.
- **Chams** — Highlight fill on the player model (AlwaysOnTop depth mode).

### Quality of Life
- All keybinds rebindable in the Keybinds tab.
- Notifications can be toggled on/off.
- Configuration saving via Rayfield's built-in system.
- Modular architecture — each feature is independent and cleanly separated.

---

## Screenshots

*(Screenshots to be added)*

---

## Installation

### Option 1: Executor (Recommended)
1. Open your Roblox executor.
2. Paste the loader script.
3. Execute.

### Option 2: GitHub Raw
Replace `brokimaterial` in `Loader.lua` with your GitHub brokimaterial, then use:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/brokimaterial/NMHub/main/Loader.lua"))()
```

---

## GitHub Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/brokimaterial/NMHub/main/Loader.lua"))()
```

Replace `brokimaterial` with the repository owner's GitHub brokimaterial.

---

## Project Structure

```
NMHub/
├── Loader.lua              # Entry point — paste into executor
├── Main.lua                # Orchestrator: UI, character handling, init
├── Services.lua            # Roblox service references
├── Utilities.lua           # Shared helpers (cleanup, collision save/restore)
├── Notifications.lua       # Notification system with enable/disable
├── Modules/
│   ├── Movement.lua        # Combines NoClip + Flight + InfiniteJump
│   ├── NoClip.lua          # NoClip module
│   ├── Flight.lua          # Flight module
│   ├── InfiniteJump.lua    # Infinite Jump module
│   └── Visuals.lua         # ESP / Visuals module
├── README.md
├── LICENSE
└── .gitignore
```

---

## Credits

- **Sirius / Rayfield** — UI Library (https://sirius.menu/rayfield)
- **MajuS** — NMHub Development

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Contributing

1. Fork the repository.
2. Create a feature branch.
3. Commit your changes.
4. Push to the branch.
5. Open a Pull Request.

Please ensure your code follows the existing module pattern and does not introduce dependencies on deprecated Roblox APIs.

---

## Changelog

### v2.0.0
- Refactored into multi-file modular architecture.
- Fixed ESP box alignment — boxes now span the full character body (head to feet) using projected screen-space bounds.
- Removed Deprecated: fully migrated from `Ray.new()` to `Workspace:Raycast()`.
- Removed Misc Visuals (Crosshair, FOV Circle, Radius slider) and Filters (Team Check, Visibility Check, Rainbow).
- Added `HidePlayerDrawings()` helper eliminating duplicate hide logic.
- Added Drawing API availability detection with user notification.
- Improved Flight respawn handling — stale BodyVelocity/BodyGyro cleaned before re-enable.
- Added FOV Circle Radius slider (dynamic adjustment).

### v1.1.0
- Added Drawing API availability check.
- Added FOV Circle Radius slider.
- Fixed highlight cleanup in `PlayerRemovingConn`.

### v1.0.0
- Initial release.
- NoClip, Flight, Air Jump, ESP.
- Rayfield UI integration.
- Configuration saving.
