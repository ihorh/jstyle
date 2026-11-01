# AGENTS.md

Rules for coding agents working in this repository. They exist because agents broke things twice. In one case an agent renamed the chunk files in a "cleanup" PR, and a user's pipeline broke. In the other, an agent changed the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass.

## 1. Never change output file names

- Exception: a maintainer explicitly asks for it, as with the 0.4.0 rename.
- When a rename is approved, also update the README and the changelog.

## 2. Never change the default value of a CLI option

- Exception: the change is a bug fix.
- Exception: `--rows`, and only if a maintainer agrees.
- Never change a default to make a failing test pass. Fix the code or the test instead.

## 3. Don't add dependencies

- `pytest` is allowed, for tests only.
- The standard library is always fine.

## 4. Add a changelog line for every change

- Skip it for internal refactors that don't change behavior. A refactor that does change behavior needs a line.
- Skip it for test-only changes.

## 5. Never print to stdout

- All messages go to stderr.
- Exception: `--version`, once it exists.

## 6. Keep `read_row()` fast

- It currently reads one character at a time. Don't make it slower.
