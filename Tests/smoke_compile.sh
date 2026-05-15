#!/usr/bin/env bash
set -euo pipefail

PLUGIN_REPO="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_RUNTIME="${DORA_PLUGIN_RUNTIME:-$HOME/Library/Application Support/IppClub/DoraSSR/Download/dora-visual-editor}"
DORA_CLI="${DORA_CLI:-/Users/wangyue/dora/Dora-SSR/Tools/dora-cli/dora.py}"

if [ ! -f "$DORA_CLI" ]; then
  echo "[compile] skipped: DORA_CLI not found at $DORA_CLI"
  exit 0
fi

rsync -a --delete --exclude='.git' --exclude='Imported/' "$PLUGIN_REPO/" "$PLUGIN_RUNTIME/"
rm -rf "$PLUGIN_RUNTIME/API" "$PLUGIN_RUNTIME/tsconfig.json"

DORA_TIMEOUT="${DORA_TIMEOUT:-60}" python3 "$DORA_CLI" ts build -p "$PLUGIN_RUNTIME" -f "Script/Tools/SceneEditor"
DORA_TIMEOUT="${DORA_TIMEOUT:-60}" python3 "$DORA_CLI" ts build -p "$PLUGIN_RUNTIME" -f "Script/Tools/SceneImGuiEditor.ts"

echo "[compile] ok"
