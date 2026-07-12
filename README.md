# NMHub

A polished, all-in-one Roblox script hub built with the Sirius (Rayfield) UI Library. Features movement enhancements (NoClip, Flight, Infinite Jump) and a comprehensive ESP system with per-feature toggles.

**Version:** 1.0.0 Stable

---

## Features

### Movement & Combat
- **NoClip** — Walk through walls and terrain. Saves and restores original collision states per-part using attributes.
- **Flight** — Camera-relative directional flight with adjustable speed (20–200 studs/s) and acceleration smoothing for fluid movement.
- **Infinite Jump** — Press Space mid-air for extra jumps. One jump per press — no jetpack behavior.

### Visuals (ESP)
- **Box ESP** — Screen-space bounding box around each player using `Model:GetBoundingBox()`. Supports R6, R15, scaling avatars, all animations.
- **Corner Box ESP** — 8-segment corner-only box variant using identical bounds.
- **Name ESP** — Player name above the box.
- **Distance ESP** — Distance from camera (configurable max range).
- **Health ESP** — Health text + health bar alongside the box.
- **Skeleton ESP** — Bone-based skeleton overlay (R6 and R15).
- **Tracers** — Line from screen bottom center to each player.
- **Head Dot** — Circle indicator at head position.
- **Chams** — Highlight fill on the player model (AlwaysOnTop depth mode).

### Visual Settings
- Line thickness (1–5px) applies to Box, Corner Box, Tracers, and Skeleton.
- Max distance filter (100–5000 studs).
- Refresh rate control (1–10 frames between updates).
- Box outline toggle, text outline toggle.

### Quality of Life
- All keybinds rebindable in the Keybinds tab.
- Notifications can be toggled on/off.
- Configuration saving via Rayfield's built-in system (auto-saves all toggles, sliders, keybinds).
- Update checker — notifies when a new version is available.
- Modular architecture — each feature is independent and cleanly separated.
- All features survive character respawns.

---

## Installation

### Quick Start (Recommended)
Paste this into your Roblox executor:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/broskimaterial/NMHub/main/Loader.lua"))()
```

### Self-Hosted
1. Fork or clone the repository.
2. Update the `BASE_URL` in `Loader.lua` and `Main.lua` to point to your own raw server.
3. Execute the loader.

---

## Loader

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/broskimaterial/NMHub/main/Main.lua"))()
```

---

## Project Structure

```
NMHub/
├── Loader.lua              # Entry point — paste into executor
├── Main.lua                # Orchestrator: UI, character handling, init, update checker
├── Services.lua            # Roblox service references
├── Utilities.lua           # Shared helpers (cleanup, collision save/restore)
├── Notifications.lua       # Notification system with enable/disable
├── Version.lua             # Version metadata
├── Version.txt             # Latest version string for update checker
├── Modules/
│   ├── NoClip.lua          # NoClip module
│   ├── Flight.lua          # Flight module with acceleration smoothing
│   ├── InfiniteJump.lua    # Infinite Jump module
│   ├── Movement.lua        # Legacy combined module (compatibility)
│   └── Visuals.lua         # ESP / Visuals module
├── README.md
├── LICENSE
└── .gitignore
```

---

## Keybinds

| Feature       | Default Key |
|---------------|-------------|
| NoClip        | N           |
| Flight        | F           |
| Air Jump      | J           |
| ESP           | P           |

All keybinds are rebindable in the Keybinds tab.

---

## Credits

- **Sirius / Rayfield** — UI Library (https://sirius.menu/rayfield)
- **MajuS** — Development

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

Please ensure your code follows the existing module pattern (each feature is a `return function(env)` module) and does not introduce dependencies on deprecated Roblox APIs.

---

## Changelog

### v1.0.0 (Stable)
- Initial public release.
- NoClip, Flight, Infinite Jump, ESP (Box, Corner Box, Name, Distance, Health, Skeleton, Tracers, Head Dot, Chams).
- Screen-space bounding box using `Model:GetBoundingBox()` — accurate for R6, R15, scaling avatars.
- Flight with acceleration smoothing (Vector3 lerp) for fluid camera-relative movement.
- ESP visual settings: line thickness, max distance, refresh rate, box outline, text outline.
- Configuration saving via Rayfield Flags (auto-saves all settings).
- Update checker with version notification.
- Modular architecture: `Services.lua`, `Utilities.lua`, `Notifications.lua`, per-feature modules.
- Character respawn handling — all features survive death.
- Drawing reuse — no per-frame allocations.
- Full connection/instance/Drawing cleanup on disable.
