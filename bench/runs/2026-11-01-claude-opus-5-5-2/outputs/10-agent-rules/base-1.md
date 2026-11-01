# AGENTS.md

splitlane splits a large CSV file into smaller chunk files. Each chunk gets the same header row. The code is in `src/splitlane/`: `cli.py` handles argument parsing and messages, and `split.py` holds `read_row()` and `split_file()`.

These rules exist because agents have broken things here before. In one "cleanup" PR an agent renamed the chunk files, and a user's pipeline broke. Another agent changed the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass. If a task seems to require breaking one of these rules, stop and ask a maintainer.

## Output file names

- Don't change output file names. Chunks are written as `<out>/part-0001.csv`, `<out>/part-0002.csv`, and so on (`split_file()` in `split.py`). Users' pipelines depend on these names.
- Rename only when a maintainer explicitly asks, as with the 0.4.0 rename. When you do, update `README.md` and `CHANGELOG.md` in the same change.

## CLI option defaults

- Don't change the default value of any CLI option. The current defaults are `--rows` 100000, `--out` `out`, `--max-row-bytes` 65536 and `--encoding` `utf-8`.
- The only exception is `--rows`, and only after a maintainer agrees.
- A failing test is not a reason to change a default. Fix the code or the test. If you think a default is itself a bug, ask a maintainer instead of changing it.

## Dependencies

- Don't add third-party dependencies.
- The Python standard library is always fine.
- `pytest` is allowed, but only for tests. Never import it from `src/`.

## Changelog

- Add a line under `## Unreleased` in `CHANGELOG.md` for every change that affects behavior, including bug fixes. Follow the style of the existing entries, e.g. `- Fix: ...`.
- You don't need a line for test-only changes, or for internal refactors that leave behavior unchanged. If a refactor changes behavior, it needs a line.

## Output streams

- Send every message to stderr (`print(..., file=sys.stderr)`). Never print to stdout.
- The one planned exception is `--version`, which should print to stdout once it's added. It doesn't exist yet.

## `read_row()` performance

- Don't make `read_row()` in `split.py` slower. It already reads one character at a time, so don't add extra reads or expensive per-character work to its loop.
