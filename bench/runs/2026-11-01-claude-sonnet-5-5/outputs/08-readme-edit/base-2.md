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

Newlines inside quoted fields stay part of their row. To keep a stray
unmatched quote from swallowing the rest of the file, a row is limited to
`--max-row-bytes` bytes (counted as UTF-8).

A row that goes past the limit is cut at the limit and written to the chunk
in shortened form. The rest of that row is skipped up to the next newline,
and reading continues from there. The cut row still counts toward `--rows`.

Truncation does not stop the run. When it finishes, splitlane prints a
warning to stderr with the number of truncated rows:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

If your data has legitimately long rows, raise `--max-row-bytes`. Scripts
that need to know about truncation should check for this warning.

The skip after a cut goes to the next newline even if that newline is inside
quotes. After a truncation, the reader may resume in the middle of a real
multi-line field.
