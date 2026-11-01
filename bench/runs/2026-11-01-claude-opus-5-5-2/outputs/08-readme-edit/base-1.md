# README.md

```markdown
# splitlane

Split a large CSV file into smaller files with the same header.

## Install

From a checkout:

```bash
pip install .
```

## Usage

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. Each
chunk starts with the input's header row.

Options:

- `--rows N`: rows per chunk, not counting the header. Default 100000.
- `--out DIR`: output directory, created if missing. Default `out`.
- `--max-row-bytes N`: longest row kept whole. Default 65536. See
  [Long rows](#long-rows).
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

A quoted field can contain newlines, and the row stays whole, as RFC 4180
says. Rows that run past `--max-row-bytes` are **truncated, not rejected**:

- The row is cut at `--max-row-bytes`. The size is counted in UTF-8 bytes,
  without the line ending. The cut row is still written to the chunk. The rest
  of the row is dropped up to the next newline, even if that newline is inside
  quotes.
- A truncated row can be malformed CSV, for example with a missing closing
  quote or too few columns. If the skip stops inside a multi-line field, the
  lines after it can come out as extra broken rows.
- A stray, unmatched `"` makes the reader treat the following lines as one
  field. That row reaches the limit and gets truncated, and reading continues
  on the next line. You lose one row, not the rest of the file.
- The run still exits with status 0. At the end, splitlane prints a warning to
  stderr:

  ```
  splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
  ```

  If your scripts need complete rows, check stderr for this warning.
- If the header row is too long, it is truncated as well, but it is not
  counted in the warning.

If your data has legitimately large rows, raise the limit, for example
`--max-row-bytes 1048576`.
```

I based this on the code in `src/splitlane/split.py` and `cli.py`, not just the changelog. Some points to check:

- **Header truncation:** a header longer than the limit is cut too, but it isn't counted in the warning. That looks like a gap in the code rather than a design choice. I documented it as the code works today, but you may want to fix the code instead.
- **Extra broken rows:** the README now covers how the skip can stop in the middle of a multi-line field. This is the follow-up tomasz raised at the end of issue #42.
