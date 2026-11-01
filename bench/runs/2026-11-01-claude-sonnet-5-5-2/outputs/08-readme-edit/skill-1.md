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
- `--max-row-bytes N`: longest row kept whole. Default 65536.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

A row longer than `--max-row-bytes` is cut off, not kept whole. The limit is
measured in UTF-8 bytes. A quoted field that contains newlines is part of its
row, so those bytes count too.

When a row goes over the limit, splitlane:

- writes the first `--max-row-bytes` bytes of the row to its chunk,
- drops the rest of the row, up to the next newline, even if that newline is
  inside quotes, and
- carries on with the next row.

The cut can land in the middle of a field, so a truncated row may end with an
unclosed quote or fewer columns than the header.

Truncation does not stop the run or change the exit status. At the end,
splitlane prints a warning to stderr with the number of truncated rows:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

If your data has legitimately long rows, raise `--max-row-bytes`. The limit
also stops a stray unterminated quote from swallowing the rest of the file.
The header row is held to the same limit, but it is not included in the
warning count.
