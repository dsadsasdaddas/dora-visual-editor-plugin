# Change: Scene tree parent path and structured CI

Date: 2026-05-15
Branch: main/local-working-tree

## Summary

Improved the Scene Hierarchy panel so parent-child relationships are easier to read. Added structured tests and GitHub Actions CI to catch repeated TSTL/Lua and scene data regressions.

## Reason

The editor previously made it hard to see where newly added nodes would be attached. A root self-parent scene record also caused path traversal to loop forever when entering 2D mode.

## Files changed

- `Script/Tools/SceneEditor/Model.ts` — parent resolution, root parent normalization, path/cycle guards
- `Script/Tools/SceneEditor/Model.lua` — generated runtime Lua
- `Script/Tools/SceneEditor/Panels/AddNodePopup.ts` — structured add-node popup with target parent path
- `Script/Tools/SceneEditor/Panels/AddNodePopup.lua` — generated runtime Lua
- `Script/Tools/SceneEditor/Panels/SceneTreePanel.ts` — hierarchy connector display and current path
- `Script/Tools/SceneEditor/Panels/SceneTreePanel.lua` — generated runtime Lua
- `Script/Tools/SceneEditor/Panels.ts` — save root without self-parent
- `Script/Tools/SceneEditor/Panels.lua` — generated runtime Lua
- `Script/Tools/SceneEditor/Player.ts` — runtime world-position cycle guard
- `Script/Tools/SceneEditor/Player.lua` — generated runtime Lua
- `Tests/` — structured static, fixture, smoke test scripts
- `.github/workflows/` — CI and package workflows

## Behavior before

- Root could be serialized with `parentId: "root"`.
- `nodePath(root)` could loop forever.
- The add-node popup did not show the target parent clearly.
- No CI checked repeated TSTL/Lua pitfalls.

## Behavior after

- Root does not serialize a self-parent.
- Path and world-position traversal have cycle guards.
- Add-node popup shows where the node will be attached.
- CI catches `any`, `null`, bad callback generation, bad Lua module call style, and missing structural guards.

## Risks

- The visual hierarchy display is text-based and may need future polish.
- Dora runtime smoke tests still require a local Dora app and are not run in GitHub-hosted CI.

## Tests

Commands run:

```bash
bash Tests/run_all.sh
```

Manual checks:

- [x] Editor opens
- [x] 2D mode does not crash
- [x] Scene hierarchy displays parent-child path
- [x] CI static checks pass locally

## Follow-ups

- [ ] Add self-hosted Dora runtime CI if needed.
- [ ] Add more scene save/load fixture tests.
