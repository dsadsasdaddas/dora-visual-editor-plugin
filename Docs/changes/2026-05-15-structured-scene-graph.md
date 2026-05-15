# 2026-05-15 structured scene graph

## What
- Added `NodeCatalog` for node kind metadata instead of scattered hard-coded labels.
- Added `SceneGraph` for parent-child normalization, reparent validation, path building, world position, and tree rows.
- Scene Tree now renders from structured rows with indentation, connectors, fold state, and valid-drop checks.
- Add Node popup now reads node categories and descriptions from the catalog.

## Why
- Parent-child behavior should be production-grade data flow, not temporary string rendering.
- Reparenting must reject root moves, self cycles, child-to-parent cycles, and invalid parent types.

## Test
- [x] `bash Tests/run_all.sh`
- [x] `RUN_DORA_SMOKE=1 bash Tests/run_all.sh`
- [x] Dora editor opened manually; 2D mode renders the structured hierarchy.
