# AGENTS.md

Rules for coding agents working in splitlane. Agents have broken things here before. One renamed the chunk files in a "cleanup" PR and broke a user's pipeline. Another raised the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass. If a rule here gets in the way of your task, stop and ask a maintainer. Don't work around it.

## Output file names

Do not change the names of output files. Today they are `part-0001.csv`, `part-0002.csv`, and so on (`src/splitlane/split.py`). Users' pipelines depend on these names.

The only exception is when a maintainer explicitly asks for a rename. In that case, update `README.md` and `CHANGELOG.md` in the same change.

## CLI option defaults

Do not change the default value of any CLI option in `src/splitlane/cli.py`. Some of these defaults come from `split.py`, such as `DEFAULT_MAX_ROW_BYTES`.

- Never change a default to make a failing test pass. Fix the code or the test, or report the failure.
- A maintainer may approve a change to the `--rows` default. Even if you think a default is a bug, ask a maintainer before changing it.
- If a default does change, update the options list in `README.md` and add a changelog line.

## Dependencies

Do not add third-party dependencies. You can always use the standard library. `pytest` is allowed, but only in tests. Never import it from `src/`.

## Changelog

Add a line under `## Unreleased` in `CHANGELOG.md` for every change that affects behavior, including bug fixes. Follow the style of the existing entries: start fixes with `Fix:` and reference issues as `(#NN)`.

You don't need a changelog line for:

- Internal refactors that don't change behavior.
- Changes that only touch tests.

If a refactor changes behavior, it needs a line.

## stdout and stderr

All messages go to stderr (`print(..., file=sys.stderr)`). Never print to stdout.

The one future exception is `--version`. It doesn't exist yet. Once it's added, it prints the version to stdout.

## `read_row()` performance

`read_row()` in `src/splitlane/split.py` is the hot path. It already reads one character at a time, so don't make it any slower. In particular, don't add per-character work beyond what is already there.
