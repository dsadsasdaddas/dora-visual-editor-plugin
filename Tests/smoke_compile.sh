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

# Dora serves TypeScript builds through the running engine process. After rsync,
# give its file watcher a short moment to drop stale cached source text before
# asking the engine to compile.
sleep "${DORA_FS_SYNC_SLEEP:-1}"

run_build() {
  local target="$1"
  local output
  local attempt
  local status
  for attempt in 1 2 3; do
    set +e
    output=$(DORA_TIMEOUT="${DORA_TIMEOUT:-60}" python3 "$DORA_CLI" ts build -p "$PLUGIN_RUNTIME" -f "$target" 2>&1)
    status=$?
    set -e
    printf '%s\n' "$output"
    if [ "$status" -eq 0 ] && ! printf '%s\n' "$output" | grep -E "Compiling error|\[error\]" >/dev/null; then
      return
    fi
    if [ "$attempt" -lt 3 ]; then
      echo "[compile] retrying $target after Dora compiler cache refresh..." >&2
      sleep "${DORA_BUILD_RETRY_SLEEP:-2}"
    fi
  done
  echo "[compile] failed: TypeScript build reported errors for $target" >&2
  exit 1
}

run_build "Script/Tools/SceneEditor"
sleep "${DORA_BUILD_CHAIN_SLEEP:-1}"
run_build "Script/Tools/SceneImGuiEditor.ts"

echo "[compile] ok"
