# Dora Visual Editor tests

This repo is a Dora plugin, so CI runs checks that do not need a local Dora app:

- static source checks for repeated TSTL/Lua pitfalls
- generated TS/Lua sync checks
- unit tests for node capabilities, scene graph rules, and scene fixture normalization
- scene fixture structural checks
- package payload checks from GitHub Actions

## Run normal checks

```bash
bash Tests/run_all.sh
```

## Run unit checks only

```bash
bash Tests/run_unit.sh
```

## Run local Dora smoke checks

These require a local Dora app with the Web IDE available on `127.0.0.1:8866`.

```bash
RUN_DORA_SMOKE=1 bash Tests/run_all.sh
```

Useful overrides:

```bash
DORA_CLI=/path/to/dora.py \
DORA_PLUGIN_RUNTIME="$HOME/Library/Application Support/IppClub/DoraSSR/Download/dora-visual-editor" \
RUN_DORA_SMOKE=1 bash Tests/run_all.sh
```
