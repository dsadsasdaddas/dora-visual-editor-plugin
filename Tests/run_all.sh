#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"

bash "$DIR/check_static.sh"

if [ "${RUN_DORA_SMOKE:-0}" = "1" ]; then
  bash "$DIR/smoke_compile.sh"
  bash "$DIR/smoke_run.sh"
else
  echo "[tests] Dora smoke tests skipped. Run with RUN_DORA_SMOKE=1 to compile/run against a local Dora app."
fi

echo "[tests] all required checks passed"
