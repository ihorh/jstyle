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

A row longer than `--max-row-bytes` doesn't stop the run. splitlane cuts the
row at that limit and writes the shortened row to the chunk as it is, with no
closing quote added. Everything after the cut is dropped, up to the next line
break in the file. splitlane measures a row in UTF-8 bytes, whatever
`--encoding` is, and doesn't count the line ending. The header row is cut the
same way if it's too long, but the warning below doesn't count it.

At the end of the run, splitlane prints to standard error how many rows it cut:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The exit status is still 0, so a script that needs every row intact should
look for this warning. If your rows really are longer than the limit, raise it,
for example with `--max-row-bytes 1048576`.

The limit exists because of quoting. A row can span several lines, because a
line break inside a quoted field stays in the row. That means a stray `"` with
no closing quote would otherwise turn the rest of the file into one field.
With the limit, the lines after a stray quote are merged into one row only
until that row reaches the limit. splitlane then cuts the row and carries on
from the next line.

The text dropped after a cut only runs to the next line break, even when that
line break is inside quotes. So if the row that was too long has a quoted
field with line breaks in it, the rest of that field after the line break is
written out as one or more extra rows. These extra rows count toward `--rows`,
and the warning doesn't include them.
