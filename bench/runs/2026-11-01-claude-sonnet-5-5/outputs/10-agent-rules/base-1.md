# AGENTS.md

Rules for coding agents working in this repository. Two earlier agent changes broke things:
- An agent renamed the chunk files in a "cleanup" PR, which broke a user's pipeline.
- An agent changed the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass.

## Output file names

- Never change output file names.
- Exception: a maintainer explicitly asks for it, as with the 0.4.0 rename. In that case, also update the README and the changelog.

## CLI defaults

- Never change the default value of a CLI option.
- Exceptions:
  - The change is a bug fix.
  - The option is `--rows` and a maintainer agrees.
- Never change a default to make a failing test pass.

## Dependencies

- Don't add dependencies.
- The standard library is always fine.
- `pytest` is allowed, for tests only.

## Changelog

- Add a changelog line for every change, with these exceptions:
  - Internal refactors that don't change behavior. If a refactor does change behavior, add a line.
  - Test-only changes.

## Output streams

- Never print to stdout. Send all messages to stderr.
- Exception: `--version`, once it is added.

## Performance

- Keep `read_row()` fast. Don't make it slower. It currently reads one character at a time, so don't change how much it reads per call in a way that slows it down.
