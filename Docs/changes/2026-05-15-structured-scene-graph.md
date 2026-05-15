# 2026-05-15 structured scene graph

## What
- Added `NodeCatalog` for node kind metadata instead of scattered hard-coded labels.
- Added `NodeCapabilities` for capability lookups such as texture binding, script binding, viewport picking, text editing, and follow-target support.
- Added `NodeFactory` for node defaults, spawn position, text defaults, and Dora buffers.
- Added `SceneNodeRenderer` for shared editor/play node visual creation and transform updates.
- Added `SceneGraph` for parent-child normalization, reparent validation, path building, world position, and tree rows.
- Scene Tree now renders from structured rows with indentation, connectors, fold state, and valid-drop checks.
- Add Node popup now reads node categories and descriptions from the catalog.

## Why
- Parent-child behavior should be production-grade data flow, not temporary string rendering.
- Node type rules should live in a catalog/capability/factory/renderer layer instead of scattered panel `if` checks.
- Reparenting must reject root moves, self cycles, child-to-parent cycles, and invalid parent types.

## Test
- [x] `bash Tests/run_all.sh`
- [x] `RUN_DORA_SMOKE=1 bash Tests/run_all.sh`
- [x] Dora editor opened manually; 2D mode renders the structured hierarchy.
