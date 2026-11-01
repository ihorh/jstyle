# AGENTS.md

Rules for coding agents working in this repository.

1. **Don't change output file names.**
   - Exception: a maintainer explicitly asks for it, as with the 0.4.0 rename.
   - When you rename, also update the README and the changelog.

2. **Don't change the default value of a CLI option.**
   - Exception: bug fixes.
   - Exception: `--rows`, if a maintainer agrees.
   - Never change a default to make a failing test pass. Fix the code or the test instead.

3. **Don't add dependencies.**
   - Standard library modules are always fine.
   - `pytest` is allowed, for tests only.

4. **Add a changelog line for every change.**
   - Skip it for internal refactors that don't change behavior.
   - Skip it for test-only changes.
   - A refactor that changes behavior needs a changelog line.

5. **Never print to stdout. Send all messages to stderr.**
   - Exception: `--version`, once it is added.

6. **Keep `read_row()` fast.**
   - It currently reads one character at a time. Don't make it slower.

## Background

These rules exist because agents broke things twice:
- A "cleanup" PR renamed the chunk files, which broke a user's pipeline.
- An agent changed the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass.
