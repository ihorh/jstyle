# AGENTS.md

splitlane is a CLI that splits a large CSV file into smaller files, and each output file keeps the input's header row.

- `src/splitlane/cli.py`: argument parsing, messages and exit codes (`EXIT_OK = 0`, `EXIT_USAGE = 2`, `EXIT_ENCODING = 3`).
- `src/splitlane/split.py`: `read_row()`, `split_file()`, `count_columns()` and `DEFAULT_MAX_ROW_BYTES`.
- `README.md`: user-facing usage and option defaults.
- `CHANGELOG.md`: release notes. New entries go under `## Unreleased`.

These rules exist because agents have broken things here before. One renamed the chunk files in a "cleanup" PR, and that broke a user's pipeline. Another changed the `--max-row-bytes` default from 65536 to 1048576 to make a failing test pass. If a task seems to need breaking one of these rules, stop and ask a maintainer. Don't look for a way around the rule.

## 1. Don't change output file names

Chunks are written as `<out>/part-0001.csv`, `<out>/part-0002.csv` and so on, numbered from 1 and zero-padded to 4 digits. Users' scripts depend on these names.

- Change the names only when a maintainer explicitly asks for it. Cleanup, consistency and refactoring are not reasons.
- If a maintainer does ask, update `README.md` and add a line to `CHANGELOG.md` in the same change.

## 2. Don't change CLI option defaults

The current defaults are:

| Option | Default |
|---|---|
| `--rows` | `100000` |
| `--out` | `out` |
| `--max-row-bytes` | `65536` (`DEFAULT_MAX_ROW_BYTES` in `split.py`) |
| `--encoding` | `utf-8` |

- Never change a default to make a test pass. Fix the code or the test.
- You may change the `--rows` default only after a maintainer agrees to it.
- If you think a default is itself a bug, don't change it. Explain the problem and ask a maintainer to confirm first.
- If a default does change, update `README.md` and `CHANGELOG.md` too.

## 3. Don't add dependencies

- The Python standard library is always fine.
- `pytest` is allowed for tests only. Never import it from `src/`.
- Ask before adding anything else, including dev tools.

## 4. Add a changelog line for every user-visible change

Put each new entry under `## Unreleased` in `CHANGELOG.md`, and follow the style of the entries already there. Start bug fixes with `Fix:` and add the issue number when there is one, for example `(#42)`.

- **Needs a line:** anything that changes behavior users can see. That includes output, messages, exit codes, options, defaults and file names.
- **Needs a line:** a refactor that changes behavior, even slightly.
- **No line needed:** a refactor with no behavior change. If you add a line anyway, start it with `Internal:`.
- **No line needed:** changes that only touch tests.

## 5. Never print to stdout

- All messages go to stderr: `print(..., file=sys.stderr)`.
- Start every message with `splitlane: `. Start warnings with `splitlane: warning: `.
- Return errors through the exit-code constants in `cli.py`. Don't use bare numbers.
- The one planned exception is a `--version` option, which would print to stdout. It doesn't exist yet. Don't add it unless asked.

## 6. Don't make `read_row()` slower

`read_row()` in `split.py` is the hot loop. It reads one character at a time, and it handles quoted newlines and `--max-row-bytes` truncation (#42).

- Any change must keep it at least as fast as it is now.
- Never make it read more than one character per step.
- Don't add work to the per-character loop, such as extra calls, allocations or logging.
- Keep its current behavior: a newline inside quotes stays in the row, and a row longer than `max_row_bytes` is cut off and reported as truncated.
