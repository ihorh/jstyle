# AGENTS.md

These rules exist because agents broke things twice. One renamed the chunk files in a "cleanup" PR, and a user's pipeline broke. Another changed the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass.

## Output file names

Never change the names of output files. The exception is a maintainer asking for it, as with the 0.4.0 rename. When you rename a file at a maintainer's request, also update the README and the changelog.

## CLI option defaults

Never change the default value of a CLI option. There are two exceptions:

- The change fixes a bug.
- The option is `--rows` and a maintainer agrees to the change.

If a test fails because of a default, fix the code or the test. Don't change the default to make the test pass.

## Dependencies

Don't add dependencies. `pytest` is allowed, but only for tests. The standard library is always fine.

## Changelog

Add a changelog line for every change. Two kinds of change don't need one:

- A test-only change.
- An internal refactor that doesn't change behavior. If the refactor does change behavior, add the line.

## Output streams

Never print to stdout. Send all messages to stderr. The one exception is `--version`, once it exists.

## Performance of `read_row()`

Keep `read_row()` fast. It currently reads one character at a time, so don't make it slower. Don't read more than one character at a time.
