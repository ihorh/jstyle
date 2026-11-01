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

A row can span several lines when a quoted field contains a newline, and it
stays one row. Row length is measured in UTF-8 bytes, not counting the line
ending that ends the row.

A row longer than `--max-row-bytes` is truncated, not skipped:

- The first `--max-row-bytes` bytes of the row are written to the chunk, and
  the rest is dropped. A truncated row may have fewer columns than the header,
  or an unclosed quote.
- splitlane drops input up to the next newline, even a newline inside quotes,
  and starts the next row there. If the cut happens inside a multi-line quoted
  field, the remaining lines of that field can show up as extra, broken rows.
- At the end of the run, splitlane prints this warning to stderr:

  ```
  splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
  ```

  The exit status is still 0. If your data must not be cut, check stderr
  for this warning in your scripts, or raise `--max-row-bytes` above your
  longest row.
- The header row has the same limit, but a truncated header is not counted
  in the warning.

A stray `"` in the input makes the reader think the rest of the file is one
quoted field. The limit stops this: the row hits `--max-row-bytes`, is counted
as truncated, and reading picks up again on the next line. So keep the limit
well above your longest real row, but not so high that one bad quote can turn
a large part of the file into a single row.
