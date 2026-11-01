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
- `--max-row-bytes N`: longest row kept whole. Longer rows are truncated, not
  rejected. See [Long rows](#long-rows). Default 65536.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

A row can span several lines if a quoted field contains line breaks. A row
longer than `--max-row-bytes` is truncated, and some of its data is lost.
splitlane:

1. Keeps the first `--max-row-bytes` bytes of the row (measured as UTF-8, not
   counting the line break that ends the row) and writes that to the chunk.
2. Drops the rest of the row, up to the next line break. That line break counts
   even if it is inside a quoted field.
3. Carries on reading from the line after that.

Things to know:

- **The run still succeeds.** splitlane exits with status 0. At the end it
  prints a warning to stderr like this:

  ```
  splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
  ```

  If your pipeline can't accept shortened rows, check stderr for this warning.
  The exit status won't tell you.
- **A truncated row may be malformed.** It can end in the middle of a field or
  inside an open quote. It can also have fewer columns than the header.
- **A stray `"` usually shows up as a truncated row.** An unterminated quote
  makes the rest of the input look like one field. That field grows until it
  reaches the limit, so you lose one row and not the rest of the file.
- **The rows after a truncated row can be damaged too.** Step 2 stops at the
  next line break even inside quotes. If that break was inside a real
  multi-line field, the rest of that field is read as new rows.
- **The header is limited too.** A header longer than the limit is truncated in
  every chunk, and it doesn't count toward the warning.

If your real rows are long, for example exports with large notes fields, raise
the limit:

```bash
splitlane data/export.csv --max-row-bytes 1048576
```
