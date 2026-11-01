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
- `--max-row-bytes N`: longest row kept whole. Default 65536. Read
  [Long rows](#long-rows) before you rely on the default.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

A quoted field can contain a line break, so one row can span several lines.
splitlane keeps a row like that together. `--max-row-bytes` sets how long a
single row can get. splitlane measures a row in UTF-8 bytes and doesn't count
its line ending.

If a row goes over the limit, splitlane keeps as much of it as fits and writes
that shortened row to the chunk. It skips the rest of the input up to the next
line break and continues from there. The run still exits with status 0. At the
end, splitlane prints a warning to stderr:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

A truncated row is usually missing fields, and nothing in the chunk marks it as
truncated. If your pipeline needs whole rows, check stderr for this warning, or
set `--max-row-bytes` higher than your longest row.

The limit also guards against a stray `"` that never gets closed. Without the
limit, everything after the stray quote would read as one field. With it, only
the row with the stray quote gets truncated. The skip stops at the first line
break even when that break is inside a quoted field, so the lines right after a
truncated row may come out as broken rows.

The header row has the same limit. If the header gets truncated, the warning
doesn't count it.
