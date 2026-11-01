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

A newline inside a quoted field stays in its row, so a multi-line note is not
split. To stop a stray quote from swallowing the rest of the file, splitlane
limits how long a row can grow.

A row longer than `--max-row-bytes` (counted in UTF-8 bytes) is cut at the
limit. The cut row is still written to its chunk, but the rest of it is
discarded, up to the next newline. That newline can sit inside quotes, so after
a cut, splitlane may resume in the middle of a real multi-line field.

At the end of the run, splitlane prints a warning to stderr with the number of
cut rows:

```
splitlane: warning: 2 row(s) longer than 65536 bytes were truncated
```

The output files carry no marker, so a cut row looks like any other row. If
your data has legitimately long rows, raise `--max-row-bytes`. If you load the
chunks automatically, check stderr for this warning.
