# AGENTS.md

Rules for coding agents working in splitlane. Each rule is here because an agent broke something. One agent renamed the chunk files in a "cleanup" PR, which broke a user's pipeline. Another changed the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass.

## Output file names

Chunks are written as `<out>/part-0001.csv`, `part-0002.csv`, and so on (`split_file()` in `src/splitlane/split.py`). Users' pipelines depend on these names.

- Don't change output file names unless a maintainer explicitly asks you to.
- If a maintainer asks for a rename, also update `README.md` and `CHANGELOG.md` in the same change.

## CLI option defaults

The defaults are in `src/splitlane/cli.py` and `DEFAULT_MAX_ROW_BYTES` in `split.py`, and they're documented in `README.md`.

- Don't change a CLI option's default value.
- `--rows` is the only exception. You may change its default, but only if a maintainer agrees.
- A failing test is never a reason to change a default. Fix the code or the test, or ask.
- If you think a default is itself a bug, stop and ask a maintainer. Don't change it yourself.

## Dependencies

- Don't add third-party dependencies.
- You can always use the Python standard library.
- `pytest` is allowed, but only in tests. Runtime code must not import it.

## Changelog

- Add a line under `## Unreleased` in `CHANGELOG.md` for every change that affects behavior.
- Skip the changelog line for internal refactors that don't change behavior and for test-only changes.
- If a refactor changes behavior, it needs a changelog line.

## stdout and stderr

- Never print to stdout. All messages go to stderr: `print(..., file=sys.stderr)`, with the `splitlane: ` prefix.
- The one planned exception is a future `--version` flag, which may print to stdout. That flag doesn't exist yet.

## `read_row()` performance

- `read_row()` in `src/splitlane/split.py` reads one character at a time on purpose so it can track quotes and enforce `--max-row-bytes`. Don't make it any slower.
