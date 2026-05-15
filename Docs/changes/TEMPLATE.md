# Change: <short title>

Date: YYYY-MM-DD
Branch: <branch-name>

## Summary

Describe the change in 2-4 sentences.

## Reason

Why this change is needed.

## Files changed

- `path/to/file.ts` — what changed
- `path/to/file.lua` — generated from TS if applicable

## Behavior before

What happened before this change.

## Behavior after

What should happen after this change.

## Risks

- Risk 1
- Risk 2

## Tests

Commands run:

```bash
bash Tests/run_all.sh
```

If Dora runtime was tested:

```bash
RUN_DORA_SMOKE=1 bash Tests/run_all.sh
```

Manual checks:

- [ ] Editor opens
- [ ] 2D mode does not crash
- [ ] Save works
- [ ] Run works if touched
- [ ] Related UI is visually checked

## Follow-ups

- [ ] Optional future work
