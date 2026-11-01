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
  [Long rows](#long-rows) for what happens to longer rows.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

A quoted field can contain newlines, and it stays in one row. A row can
therefore span several lines. `--max-row-bytes` limits how long one row can
get. Without a limit, a single stray `"` could make the rest of the file read
as one field.

A row that is longer than `--max-row-bytes` is **truncated, not rejected**:

- splitlane keeps the first `--max-row-bytes` bytes of the row and writes that
  shortened row to the chunk. The shortened row still counts toward `--rows`.
- The rest of the row is thrown away, up to the next newline. splitlane does
  not check whether that newline is inside quotes. If the long row is a real
  multi-line field, reading can pick up again partway through that field, and
  the next row may come out damaged as well.
- The size is counted in UTF-8 bytes of the text that was read, whatever the
  `--encoding` is. Newlines inside quoted fields count too.

When the run finishes, splitlane prints a warning to stderr:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The exit status is still 0. If your pipeline must not accept shortened rows,
check stderr for this warning. Exit status alone won't catch them. If your data
really has rows this long, raise `--max-row-bytes`.

The header row has the same limit, but a truncated header is not counted in
the warning.
