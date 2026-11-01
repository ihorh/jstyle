# AGENTS.md

Rules for coding agents working in splitlane. They exist because agents have broken things here before: one renamed the chunk files in a "cleanup" PR and broke a user's pipeline, and another raised the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass.

If a rule seems to block your task, stop and ask a maintainer. Don't look for a way around it.

## Output file names

Don't change the names of output files. Right now that's `part-0001.csv`, `part-0002.csv` and so on, built in `split_file()` in `src/splitlane/split.py`. Users' pipelines depend on these names.

Only rename them when a maintainer asks you to, as happened with the 0.4.0 rename. If you do, update `README.md` and `CHANGELOG.md` in the same change.

## CLI option defaults

Don't change the default value of any CLI option (`--rows`, `--out`, `--max-row-bytes`, `--encoding`). The defaults are set in `src/splitlane/cli.py`, plus `DEFAULT_MAX_ROW_BYTES` in `src/splitlane/split.py`.

- A failing test is never a reason to change a default. Fix the code or the test.
- If you think a default is a bug, or a change to `--rows` would help, ask a maintainer and wait for their agreement before you change it.

## Dependencies

Don't add runtime dependencies. The standard library is always fine. `pytest` is allowed, but only as a test dependency. Never import it from `src/`.

## Changelog

Add a line to the `Unreleased` section of `CHANGELOG.md` for every change that affects behavior. Skip the line only when the change is:

- an internal refactor that doesn't change behavior, or
- a change to tests only.

If a refactor does change behavior, it needs a line.

## stdout and stderr

Never print to stdout. Every message, warning and error goes to stderr (`print(..., file=sys.stderr)`). The one planned exception is a future `--version` flag, which may print to stdout. It doesn't exist yet.

## `read_row()` performance

Don't make `read_row()` in `src/splitlane/split.py` any slower. It already reads one character at a time, so never add per-character work that costs more than what it does now, and never read the input more than once.
