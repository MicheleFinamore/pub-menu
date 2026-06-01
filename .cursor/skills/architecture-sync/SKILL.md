---
name: architecture-sync
description: Keeps architecture documentation aligned with structural code changes. Use when tasks include migrations, schema updates, route structure changes, service-boundary changes, shared package updates, or major refactors. Ensures `.cursor/rules/architecture.mdc` is read as core context and updates both architecture docs files before closing the task.
---

# Architecture Sync

## Goal

Keep project requirements and architecture docs accurate so future tasks can rely on a single source of truth instead of scanning many files.

## Mandatory Context Rule

For structural tasks, treat the working inputs in this order:

1. User request
2. `.cursor/rules/architecture.mdc` (mandatory second input)
3. `docs/architecture/ARCHITECTURE.md`
4. Only the minimal extra files needed for the change

If missing, create:

- `.cursor/rules/architecture.mdc`
- `docs/architecture/ARCHITECTURE.md`
- `docs/architecture/CHANGELOG.md`

## What Counts as Structural

- New/updated migration or schema change
- New domain service or service boundary change
- New shared module/package or import boundary update
- Route architecture changes (new route groups/layout boundaries)
- Auth, RLS, or data-flow model changes
- Refactor that changes responsibility boundaries across folders/modules

## End-of-Task Workflow

Before finalizing a structural task:

1. Open `.cursor/rules/architecture.mdc`.
2. Open `docs/architecture/ARCHITECTURE.md`.
3. Update `Last Updated` in `docs/architecture/ARCHITECTURE.md` with the current date (`YYYY-MM-DD`).
4. Update affected requirements/architecture sections (product context, surfaces, boundaries, schema, routes, migrations).
5. Append one concise entry to `docs/architecture/CHANGELOG.md`:
   - date
   - what changed
   - why the change matters
6. Verify architecture docs match the implemented code.

## Writing Style for Architecture Updates

- Keep entries concise and factual.
- Prefer boundaries and decisions over low-level implementation details.
- Avoid duplicating full code snippets unless they clarify architecture.
- Keep terminology consistent with existing rule files.

## Completion Guardrail

If the task is structural, do not consider it complete until all are updated in the same change set:

- `.cursor/rules/architecture.mdc` (if boundaries/policy changed)
- `docs/architecture/ARCHITECTURE.md`
- `docs/architecture/CHANGELOG.md`
