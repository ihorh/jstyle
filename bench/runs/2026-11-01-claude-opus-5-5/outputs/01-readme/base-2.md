# splitlane

splitlane splits a large CSV file into smaller files. Every output file starts with the input's header row, so you can open, import or process each one by itself.

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

```
chunks/part-0001.csv   header + rows 1–50000
chunks/part-0002.csv   header + rows 50001–100000
...
```

It's a small command-line tool with no dependencies outside the Python standard library. You can also import it as a library.

## What it handles

- **Quoted fields that contain line breaks.** A field such as `"called twice⏎asked for refund"` stays in one row, as RFC 4180 specifies and as spreadsheets expect.
- **Malformed quotes.** A stray `"` doesn't make the rest of the file read as one huge field. Each row is capped at `--max-row-bytes` (default 64 KiB). A row that goes past the cap is cut off there, and reading picks up again at the next line. You lose part of one row, not the whole file.
- **No silent data loss.** When rows are cut off, splitlane tells you how many at the end of the run:

  ```
  splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
  ```

- **Non-UTF-8 input.** You can set the input encoding with `--encoding`. If the file can't be decoded, splitlane stops with exit status 3 and doesn't write garbage.

## Install

From a checkout:

```bash
pip install .
```

## Usage

```bash
splitlane INPUT [--rows N] [--out DIR] [--max-row-bytes N] [--encoding NAME]
```

| Option | Default | Meaning |
|---|---|---|
| `--rows N` | `100000` | Data rows per chunk, not counting the header. Must be at least 1. |
| `--out DIR` | `out` | Output directory. Created if it doesn't exist. |
| `--max-row-bytes N` | `65536` | Longest row kept whole, measured in UTF-8 bytes. Longer rows are truncated and counted. |
| `--encoding NAME` | `utf-8` | Encoding of the input file, e.g. `latin-1` or `cp1252`. |

Output files are named `part-0001.csv`, `part-0002.csv`, and so on. They are always written as UTF-8, whatever the input encoding.

Every message goes to stderr, and nothing is printed to stdout.

### Exit status

| Status | Meaning |
|---|---|
| `0` | Success. Check stderr for a truncation warning. |
| `2` | Invalid arguments, e.g. `--rows 0`. |
| `3` | The input couldn't be decoded with the given `--encoding`. |

If you run splitlane from a script and truncated rows would be a problem downstream, check stderr for the `truncated` warning as well as the exit status.

### Example: a Latin-1 export

```bash
splitlane exports/customers.csv --encoding latin-1 --rows 20000 --out chunks
```

## Using it as a library

```python
from splitlane.split import split_file

written, truncated = split_file("data/export.csv", 50000, "chunks")
# written:   list of chunk file paths
# truncated: number of rows cut at max_row_bytes
```

`split_file()` takes the same settings as the CLI as optional arguments: `max_row_bytes` and `encoding`. To read one row at a time, use `read_row(stream, max_row_bytes)`. It returns `(row, was_truncated)`, or `(None, False)` at the end of the input.

## Known limitations

Check these before you use splitlane in a pipeline:

- **Old chunks aren't cleaned up.** splitlane overwrites chunk files with the same name, but it never deletes other files. Suppose an earlier run wrote 10 chunks into `chunks/` and the new run writes 6. Then `part-0007.csv` to `part-0010.csv` are left over from the old run. Use a fresh or empty `--out` directory for each run.
- **A failed run leaves partial output.** If splitlane stops partway, for example on a decode error (exit status 3), the chunks written before the error stay on disk. Don't use the output of a run that exited with a non-zero status.
- **Windows: overwriting a chunk that is open in another program crashes the run** ([#57](../../issues/57)). This happens if a chunk from an earlier run is open in Excel, for example. splitlane exits with a `PermissionError`, and the directory ends up holding a mix of new and old chunks. The error doesn't say which file caused it. Close the files first, or write to a new directory.
- **Recovery after a truncated row is best-effort.** After cutting a row off, splitlane skips to the next line break. In rare cases that line break is inside a real multi-line quoted field, and the next row or two come out wrong. The truncation warning tells you this may have happened.
- **Header-only or empty input produces no files.**
- **Output line endings:** each row is written followed by `\n`. A `\r` from CRLF input stays at the end of each row, so CRLF input still comes out as CRLF.

## Upgrading from 0.3.x

- Chunk files used to be named `chunk_1.csv`, `chunk_2.csv`, and so on. They are now `part-0001.csv`, `part-0002.csv`, and so on. Update any scripts that look for the old names.
- Quoted fields with line breaks used to be split into separate rows. They now stay in one row ([#42](../../issues/42)), so the row count per chunk may differ from what you got with 0.3.x on the same file.
- `--rows 0` now exits with status 2 instead of hanging.
- A decode error now exits with status 3.

See [CHANGELOG.md](CHANGELOG.md) for the full history.
