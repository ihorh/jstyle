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
  [Long rows](#long-rows) before you rely on the default.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

splitlane cuts a row that is longer than `--max-row-bytes` and still writes it.
It does not skip the row. The chunk gets the first `--max-row-bytes` bytes of
the row, and splitlane drops the rest of the row up to the next line break. The
cut usually falls in the middle of a field. The row that gets written can then
have too few columns or an unclosed quote. An importer may reject it, or accept
the shortened row without noticing.

splitlane measures a row's length as the bytes of the row encoded as UTF-8,
without its final line break. A quoted field can contain line breaks. Those
line breaks belong to the row and count toward its length.

At the end of a run, splitlane prints on standard error how many rows it cut:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The exit status is still 0. A script that only checks the exit status will
miss this warning, so check standard error for it as well. The warning doesn't
say which rows were cut. If you see it, run splitlane again with a
`--max-row-bytes` larger than your longest row.

The limit also contains the damage from a stray `"`. Without a limit, an
unclosed quote would turn the rest of the file into one field. With the limit,
that row stops growing at `--max-row-bytes` and counts as cut. One caveat
applies. After a cut, splitlane skips to the next line break even when that
line break is inside a quoted field. Whatever follows it is read as a new row,
so a single cut can also leave one or more broken rows after it.
