# AGENTS.md

These rules apply to every change you make in splitlane, the CLI that splits a large CSV file into smaller files that each keep the header. Users run splitlane inside their own pipelines, so file names, option defaults and stdout are all part of its interface. Two earlier changes by agents broke things for users:

- A "cleanup" PR renamed the chunk files, and a user's pipeline broke.
- An agent changed the `--max-row-bytes` default from 65536 to 1048576 to get a failing test to pass.

If a task seems to need a change these rules forbid, stop and ask a maintainer. Don't look for a way around the rule.

## Output file names

Don't change the names of the files splitlane writes. Today the chunks are `part-0001.csv`, `part-0002.csv` and so on, inside the `--out` directory (see `split_file()` in `src/splitlane/split.py`).

Only a maintainer can ask for a rename, as they did for the 0.4.0 naming scheme. If you do a rename, update the file names in `README.md` and add a line to `CHANGELOG.md` in the same change.

## CLI option defaults

Don't change the default value of any CLI option. The defaults are set in `src/splitlane/cli.py` and `DEFAULT_MAX_ROW_BYTES` in `src/splitlane/split.py`, and `README.md` lists them too.

- `--rows` is the one exception, and only when a maintainer agrees.
- A real bug fix may change a default. A failing test doesn't show that a default is wrong, though. Fix the code or the test, or ask.

## Dependencies

Don't add third-party dependencies. You can always use the Python standard library. `pytest` is allowed for tests only. Never import it from `src/` or list it as a runtime dependency.

## Changelog

Add a line to the `## Unreleased` section of `CHANGELOG.md` for every change a user could notice. Follow the style of the lines already there, for example "Fix: …" for bug fixes.

You don't need a changelog line for:

- an internal refactor that doesn't change behavior. If the refactor does change behavior, add a line.
- a change that only touches tests.

## stdout and stderr

Never print to stdout. All of splitlane's messages go to stderr, including progress, warnings and errors, as in `cli.py`: `print(..., file=sys.stderr)`.

The one planned exception is `--version`, which will print to stdout once it's added. It doesn't exist yet.

## `read_row()` performance

Don't make `read_row()` in `src/splitlane/split.py` any slower. It runs once for every row of the input, and it reads the stream one character at a time. Avoid adding work to its inner loop, such as extra function calls, encoding or allocations per character.
