# AGENTS.md

Rules for coding agents working in splitlane. Agents have broken things here twice. One renamed the chunk files in a "cleanup" PR, and a user's pipeline broke. Another changed the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass. Fix the code or the test, not the contract users depend on.

## Output file names

Never change the names of output files. The exception is a maintainer asking for it, as with the 0.4.0 rename. When that happens, also update the README and the changelog.

## CLI defaults

Never change the default value of a CLI option. There are two exceptions:

- The change fixes a bug.
- The option is `--rows` and a maintainer agrees.

A failing test is not a bug in the default. Don't change a default to make a test pass.

## Dependencies

Don't add dependencies. The standard library is always fine. `pytest` is allowed, but only for tests.

## Changelog

Add a changelog line for every change, with these exceptions:

- An internal refactor needs no line, unless it changes behavior.
- A change that only touches tests needs no line.

## Output streams

Never print to stdout. Send all messages to stderr. The one exception is `--version`, once it exists.

## Performance

Keep `read_row()` fast. It currently reads one character at a time, so don't make it slower.
