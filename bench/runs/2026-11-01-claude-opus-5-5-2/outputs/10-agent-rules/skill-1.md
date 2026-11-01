I wrote the file below from the draft, then checked it against the code and ran a cold read with a fresh agent. Some of the draft's rules were unclear or clashed with each other, so I made these choices. Please check them before you commit:

- **Bug-fix exception for defaults (rule 2):** I dropped it. The `--max-row-bytes` incident was an agent treating a failing test as a reason to change a default. Now a default that looks wrong gets raised with a maintainer instead of changed.
- **Changelog for refactors:** the draft says internal refactors need no changelog line. But `CHANGELOG.md` already has one ("Internal: move column counting into `split.py`"). I kept the draft's rule.
- **`--help`:** I said it's fine for `--help` to print to stdout, because that's argparse's default. The draft doesn't mention it; this is my reading.
- **Who counts as a maintainer:** the file doesn't name anyone, because the repo doesn't say who the maintainers are.

```markdown
# AGENTS.md

These rules exist because agents have broken things here before. One renamed
the chunk files in a "cleanup" PR and broke a user's pipeline. Another changed
the `--max-row-bytes` default from 65536 to 1048576 to make a failing test
pass. When a rule blocks the change you want to make, stop and ask a maintainer
rather than looking for a way around it. If the person you're working with is a
maintainer, their request counts.

## Output File Names

splitlane writes chunks as `part-0001.csv`, `part-0002.csv`, and so on, inside
the `--out` directory (`src/splitlane/split.py`). Users' scripts depend on
these names, so don't change them, including the padding width.

A maintainer may ask for a rename, as one did for the zero-padded names in
0.4.0. When a maintainer asks, update the Usage section of `README.md` and add
a line to `CHANGELOG.md` in the same change.

## CLI Defaults

Don't change the default of any CLI option. These are the defaults, as
documented in `README.md`:

- `--rows`: 100000, set in `src/splitlane/cli.py`
- `--out`: `out`, set in `src/splitlane/cli.py`
- `--max-row-bytes`: 65536, set as `DEFAULT_MAX_ROW_BYTES` in
  `src/splitlane/split.py`
- `--encoding`: `utf-8`, set in `src/splitlane/cli.py`

The one exception is `--rows`, whose default may change once a maintainer
agrees to it. A failing test is never a reason to change a default, so fix the
code or the test instead. If you think a default is itself a bug, say so and
leave the decision to a maintainer.

## Dependencies

Don't add third-party dependencies. Anything from the standard library is
fine. `pytest` is allowed for tests only, so code under `src/` must never
import it.

## Changelog

Add a line to the `Unreleased` section of `CHANGELOG.md` for every change a
user could notice, written in the style of the entries already there. Two
kinds of change need no line:

- a refactor that leaves behavior unchanged
- a change that only touches tests

A refactor that changes behavior, even slightly, does need a line.

## Output Streams

Every message splitlane prints goes to stderr, never stdout, and starts with
`splitlane: `, as in `src/splitlane/cli.py`. argparse's own `--help` output
goes to stdout, and that's fine.

`--version` will be an exception once it exists, and it will print to stdout.
It doesn't exist yet, so don't add it unless someone asks for it.

## `read_row()` Performance

`read_row()` in `src/splitlane/split.py` reads its input one character at a
time, so its inner loop runs for every character of the input. Don't make it
slower. Keep that loop as lean as it is now, and ask a maintainer before adding
work to it, even for a bug fix.
```
