#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

node Tests/unit/node_capabilities.test.mjs
node Tests/unit/scene_graph.test.mjs
node Tests/unit/scene_fixtures.test.mjs

echo "[unit] all unit tests passed"
