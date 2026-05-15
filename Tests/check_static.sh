#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0
check_absent() {
  local label="$1"
  local pattern="$2"
  shift 2
  echo "[static] $label"
  if grep -R -n -E "$pattern" "$@"; then
    echo "[static] failed: $label" >&2
    fail=1
  fi
}

check_absent "no TypeScript any" '\bany\b' Script --include='*.ts' --include='*.tsx'
check_absent "no TypeScript null" '\bnull\b' Script --include='*.ts' --include='*.tsx'
check_absent "no generated one-arg callback with hidden self" 'function\(____, path\)' Script --include='*.lua'
check_absent "no openFileDialog arrow callback" 'openFileDialog\([^\n]*=>' Script --include='*.ts' --include='*.tsx'
check_absent "no Lua object-style SceneModel calls" 'SceneModel:' Script/Tools --include='*.lua'

node Tests/scripts/check_structure.mjs
node Tests/scripts/check_lua_sync.mjs
bash Tests/run_unit.sh

if [ "$fail" -ne 0 ]; then
  exit 1
fi

echo "[static] ok"
