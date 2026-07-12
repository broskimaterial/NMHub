# Changelog

## v1.0.0 (Stable)
- Initial public release.
- NoClip, Flight, Infinite Jump, ESP (Box, Corner Box, Name, Distance, Health, Skeleton, Tracers, Head Dot, Chams).
- Screen-space bounding box using `Model:GetBoundingBox()` — accurate for R6, R15, scaling avatars.
- Flight with acceleration smoothing (Vector3 lerp) for fluid camera-relative movement.
- ESP visual settings: line thickness, max distance, refresh rate, box outline, text outline, transparency, text size, tracer origin, distance fade.
- Configuration saving via Rayfield Flags (auto-saves all settings).
- Update checker with version notification.
- Multi-profile configuration system (create, delete, switch profiles).
- Notification queue (FIFO, max 3 visible, spam prevention).
- Theme manager with 25 Rayfield presets.
- Diagnostics panel (FPS, ping, memory).
- Plugin API for extensibility.
- Logger system (500-entry ring buffer, Info/Warn/Error/Debug).
- Quick navigation in Settings tab.
- Keybind summary with all default bindings.
- Modular architecture: per-feature modules, clean APIs.
- Character respawn handling — all features survive death.
- Drawing reuse — no per-frame allocations.
- Full connection/instance/Drawing cleanup on disable.
