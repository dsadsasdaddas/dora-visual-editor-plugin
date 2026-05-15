# Dora Visual Editor Development Workflow

This project uses document-driven development. Every code change should leave a small written record so regressions can be traced and tested later.

## Daily workflow

```bash
# 1. Start from main
git checkout main
git pull origin main

# 2. Create a focused branch
git checkout -b fix/short-description

# 3. Edit source files
# TS is the source. Lua is generated from TS.

# 4. Run required checks
bash Tests/run_all.sh

# Optional, when Dora is running locally:
RUN_DORA_SMOKE=1 bash Tests/run_all.sh

# 5. Write a change record
cp Docs/changes/TEMPLATE.md Docs/changes/YYYY-MM-DD-short-description.md

# 6. Commit and push
git add .
git commit -m "Short description"
git push -u origin fix/short-description

# 7. Open PR and wait for CI
```

## Source rules

- TypeScript is the source of truth.
- Lua files are generated runtime files and must be synced after TS changes.
- Do not use `null`; Lua only has `nil`, which maps to TypeScript `undefined`.
- Do not use `any`; prefer `unknown` plus narrowing or explicit interfaces.
- Dora callbacks that receive one argument should use `function(this: void, value: Type) { ... }`, not arrow callbacks, to avoid hidden Lua `self` parameter bugs.
- Do not hand-edit generated Lua as the final fix unless it is an emergency hotfix. Always port the fix back to TS.

## Required checks before push

```bash
bash Tests/run_all.sh
```

Run Dora smoke tests when the change touches runtime/editor behavior:

```bash
RUN_DORA_SMOKE=1 bash Tests/run_all.sh
```

## When to create a change record

Create one under `Docs/changes/` for every meaningful change:

- bug fix
- UI behavior change
- persistence/save format change
- runtime/rendering change
- CI/test change
- plugin packaging change

Small typo-only commits can skip it.

## Change record naming

Use:

```text
Docs/changes/YYYY-MM-DD-short-topic.md
```

Example:

```text
Docs/changes/2026-05-15-scene-tree-parent-path.md
```

## What the change record must answer

1. What changed?
2. Why was it changed?
3. Which files changed?
4. What risks exist?
5. How was it tested?
6. What should be checked manually?

## PR rule

A PR should not merge unless:

- CI is green
- local `bash Tests/run_all.sh` passed
- change record exists or the PR explains why it is not needed
- generated Lua is in sync when TS changed
