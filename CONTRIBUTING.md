# Contributing to NMHub

## Development Setup

1. Fork the repository.
2. Clone your fork locally.
3. Create a feature branch: `git checkout -b feat/your-feature`.
4. Make changes following the existing patterns.

## Code Standards

- Each feature is a `return function(env)` module in `Modules/`.
- Use the shared `env.Services`, `env.Utilities`, `env.Logger` instead of duplicating logic.
- All Drawing objects must be created once and reused every frame.
- Every connection must be inserted into `Utilities.Connections`.
- Every instance must be inserted into `Utilities.Instances`.
- Every module must implement `:Cleanup()` and `:Reset()` methods.
- No deprecated Roblox APIs (e.g., `Ray.new()`).
- Test all changes in-game before submitting.

## Pull Request Process

1. Update `CHANGELOG.md` with your changes.
2. Ensure all existing functionality still works.
3. Open a PR against the `main` branch.
4. Describe what your change does and why.

## Commit Style

Use conventional commits:

- `feat(x):` — new feature
- `fix(x):` — bug fix
- `perf(x):` — performance improvement
- `docs(x):` — documentation only

Example: `feat(esp): add transparency slider`
