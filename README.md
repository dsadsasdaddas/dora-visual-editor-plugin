# Dora Visual Editor Plugin

[![CI](https://github.com/dsadsasdaddas/dora-visual-editor-plugin/actions/workflows/ci.yml/badge.svg)](https://github.com/dsadsasdaddas/dora-visual-editor-plugin/actions/workflows/ci.yml)


Native ImGui-based 2D visual editor plugin for Dora SSR.

## Features

- Scene tree editing (Node/Sprite/Label/Camera)
- 2D viewport (zoom/pan/select/move nodes)
- Asset management (import images/scripts/audio/etc.)
- Inspector property editing
- Script editing with Web IDE integration
- Game preview

## Project Structure

```text
init.lua                              # Entry point
Script/Tools/
├── SceneImGuiEditor.lua/.ts          # Editor entry
└── SceneEditor/
    ├── Model.lua/.ts                 # Data model (nodes/assets/scene)
    ├── Panels.lua/.ts                # Panel module
    ├── Panels/                       # Sub-panels
    │   ├── HeaderPanel.lua/.ts       #   Top toolbar
    │   ├── SceneTreePanel.lua/.ts    #   Scene tree
    │   ├── AssetsPanel.lua/.ts       #   Asset panel
    │   ├── InspectorPanel.lua/.ts    #   Inspector
    │   ├── ConsolePanel.lua/.ts      #   Console
    │   └── AddNodePopup.lua/.ts      #   Add node popup
    ├── Runtime.lua/.ts               # Viewport rendering
    ├── Player.lua/.ts                # Game preview
    ├── Theme.lua/.ts                 # Theme config
    └── Types.lua/.ts                 # Type definitions
```

## Usage

### Download as Plugin

1. Open Dora SSR → Download / ResourceDownloader
2. Set resource URL to this repository
3. Download and run

### Run Directly

Copy `Script/` directory into your Dora project, then run `init.lua`.

## Development

Source code is in `Script/Tools/`, maintained in both Lua and TypeScript.

See [`Docs/DEVELOPMENT.md`](Docs/DEVELOPMENT.md) for the document-driven development workflow.

## Testing

Run repository-safe checks:

```bash
bash Tests/run_all.sh
```

Run local Dora compile/run smoke checks when Dora is open and the Web IDE is available:

```bash
RUN_DORA_SMOKE=1 bash Tests/run_all.sh
```

GitHub Actions runs the static/structure checks on every push and PR. Tag builds (`v*`) also package a distributable plugin zip.


**TSTL Note**: Do not use `null` — Lua has no null concept. Use `undefined` in TypeScript.

## Related Repositories

- Main repo: https://github.com/IppClub/Dora-SSR
- Web IDE: `Dora-SSR/Tools/dora-dora/`
