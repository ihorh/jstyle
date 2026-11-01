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
  [Long rows](#long-rows) below.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

A quoted field can contain newlines, as RFC 4180 allows. The field stays in
one row. Each row is limited to `--max-row-bytes`, measured in UTF-8 bytes
and not counting the newline at the end. The limit stops one stray `"` from
turning the rest of the file into a single field.

When a row goes over the limit, splitlane:

1. Keeps the first `--max-row-bytes` bytes of the row and writes them to the
   chunk as a normal row. The rest of the row is dropped, so the written row
   can have missing columns or an unclosed quote.
2. Skips ahead to the next newline, even if that newline is inside quotes, and
   starts reading the next row there. If the long row had a quoted multi-line
   field, the lines after the cut can come out as extra, broken rows.
3. Keeps going. At the end of the run it prints a warning to stderr:

   ```
   splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
   ```

The exit status is still 0 when rows are truncated. If your pipeline must not
lose data, check stderr for this warning, or raise `--max-row-bytes` above
your longest legitimate row. The header row has the same limit, but a cut
header is not included in the warning count.
