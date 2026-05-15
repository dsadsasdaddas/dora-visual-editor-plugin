#!/usr/bin/env bash
set -euo pipefail

PLUGIN_RUNTIME="${DORA_PLUGIN_RUNTIME:-$HOME/Library/Application Support/IppClub/DoraSSR/Download/dora-visual-editor}"
DORA_CLI="${DORA_CLI:-/Users/wangyue/dora/Dora-SSR/Tools/dora-cli/dora.py}"
LOG="${DORA_LOG:-$HOME/Library/Application Support/IppClub/DoraSSR/log.txt}"

if [ ! -f "$DORA_CLI" ]; then
  echo "[run] skipped: DORA_CLI not found at $DORA_CLI"
  exit 0
fi

python3 "$DORA_CLI" ts run -p "$PLUGIN_RUNTIME" --entry init.lua
sleep "${DORA_SMOKE_SLEEP:-3}"

if [ -f "$LOG" ] && tail -n 120 "$LOG" | grep -iE "\[error\]|stack traceback|attempt to|bad argument"; then
  echo "[run] failed: Dora log contains runtime errors" >&2
  exit 1
fi

echo "[run] ok"
