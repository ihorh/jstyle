# Rules for Coding Agents (draft)

devi, 2026-10-25. Collected after agents broke things twice.

1. Never change output file names.
   - Except when a maintainer asks for it, like the 0.4.0 rename.
   - Then also update the README and the changelog.
2. Never change a default value of a CLI option.
   - Except `--rows`, if a maintainer agrees.
   - Unless the change is a bug fix.
3. Don't add dependencies.
   - `pytest` is fine, but only for tests.
   - Something from the standard library is always fine, obviously.
4. Always add a changelog line.
   - Not for internal refactors.
   - Unless the refactor changes behavior.
   - Or a test only.
5. Never print to stdout. All messages go to stderr.
   - Except `--version`, when we add it.
6. Keep `read_row()` fast.
   - Don't read more than one character at a time. Actually that's what it does
     now, so: don't make it slower.

Background: an agent renamed the chunk files in a "cleanup" PR, and a user's
pipeline broke. Another one changed the `--max-row-bytes` default from 65536 to
1048576 because a test was failing.
