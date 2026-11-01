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
- `--max-row-bytes N`: longest row kept whole, measured in UTF-8 bytes. Longer
  rows are truncated (see below). Default 65536.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

A newline inside a quoted field stays part of its row, so multi-line notes
survive. To keep an unclosed quote from swallowing the rest of the file,
splitlane limits how long a row can grow.

If a row passes `--max-row-bytes`, splitlane cuts it at the limit and drops the
rest of it, up to the next newline. The shortened row is still written to its
chunk, so it looks like any other row, and your importer won't notice it. At
the end of the run, splitlane prints a warning to stderr with the number of
truncated rows:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

If your data has legitimately long rows, raise `--max-row-bytes`. If your
scripts must not accept damaged rows, check for this warning.

The skip after a cut stops at the next newline even when that newline is inside
quotes. In rare cases, splitlane may resume reading in the middle of a real
multi-line field.
