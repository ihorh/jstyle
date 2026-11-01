# AGENTS.md

splitlane splits a large CSV file into smaller files. Each smaller file keeps the input's header row. Users run it inside their own pipelines, so its output names, CLI defaults and output streams act as a public interface. These rules exist because agents broke that interface twice. One agent renamed the chunk files in a "cleanup" PR, which broke a user's pipeline. Another changed the `--max-row-bytes` default to make a failing test pass.

## Layout

- `src/splitlane/cli.py`: argument parsing, messages and exit codes (0 ok, 2 usage error, 3 decode error).
- `src/splitlane/split.py`: `read_row()` and `split_file()`.
- `CHANGELOG.md`: new entries go under `## Unreleased`.
- `README.md`: documents the output names and every CLI option with its default.

## Rules

### Output file names

Chunks are written as `<out>/part-0001.csv`, `<out>/part-0002.csv`, and so on (`part-{n:04d}.csv`). Don't change this scheme or the output directory layout unless a maintainer explicitly asks. If a maintainer does ask, update `README.md` and add a `CHANGELOG.md` entry in the same change.

### CLI defaults

Don't change the default of any CLI option:

| Option | Default |
|---|---|
| `--rows` | `100000` |
| `--out` | `out` |
| `--max-row-bytes` | `65536` (`DEFAULT_MAX_ROW_BYTES` in `split.py`) |
| `--encoding` | `utf-8` |

- A failing test is never a reason to change a default. Fix the code or the test instead.
- If you think a default is itself a bug, stop and ask a maintainer. Don't change it yourself.
- Only `--rows` may change, and only after a maintainer agrees. When it changes, update `README.md` and `CHANGELOG.md` too.

### Dependencies

- Code under `src/` may use only the Python standard library.
- `pytest` is allowed only in tests.
- Don't add any other dependency.

### Changelog

Add a line under `## Unreleased` in `CHANGELOG.md` for any change to behavior that users can see. Write bug fixes as `Fix: ...` and mention the issue number if there is one, e.g. `(#42)`.

You can skip the entry when the change is:

- an internal refactor that doesn't change behavior, or
- a change to tests only.

If a refactor changes behavior in any way, it needs an entry.

### stdout and stderr

- Never write to stdout. Users pipe splitlane's output, so all messages go to stderr: `print(..., file=sys.stderr)`.
- Start every message with `splitlane: `, like the existing ones.
- The one planned exception is `--version`, which doesn't exist yet. When it's added, it may print to stdout.

### `read_row()` performance

`read_row()` in `split.py` runs once for every character of input, so it's the hot path. Don't make it slower. That means:

- no extra passes over the input,
- no extra per-character work that you can avoid,
- no reading the stream more than once.

If you can't avoid a change that might slow it down, say so in your summary and explain why.

## When a rule gets in your way

Stop and ask a maintainer. Don't work around the rule, and don't decide on your own that an exception applies.
