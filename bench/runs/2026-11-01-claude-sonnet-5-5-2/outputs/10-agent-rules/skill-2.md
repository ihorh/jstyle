# AGENTS.md

Follow these rules in every change. Two earlier agent changes broke things for users: a "cleanup" PR renamed the chunk files and broke a user's pipeline, and another change raised the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass.

## Output file names

- Don't change the names of output files.
- If a maintainer asks for a rename, as with the 0.4.0 rename, also update the README and the changelog.

## CLI defaults

- Don't change the default value of a CLI option.
- A maintainer may agree to a change to the `--rows` default. Ask first.
- A change that fixes a bug is also allowed. A failing test doesn't make a default a bug. Fix the code, or ask a maintainer.

## Dependencies

- Don't add dependencies.
- The standard library is always fine.
- `pytest` is fine for tests only.

## Changelog

- Add a changelog line for every change.
- Skip the line for a test-only change.
- Skip it for an internal refactor that doesn't change behavior. A refactor that does change behavior needs a line.

## Output streams

- Never print to stdout. Send all messages to stderr.
- The one exception is `--version`, once it exists.

## Performance

- Keep `read_row()` fast. It reads one character at a time today, so don't make it slower.
