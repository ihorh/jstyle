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
- `--max-row-bytes N`: longest row kept whole. Longer rows are truncated (see
  [Long rows](#long-rows)). Default 65536.
- `--encoding NAME`: input encoding. Default `utf-8`.

## Long rows

A quoted field can contain line breaks, and splitlane keeps those inside one
row. A row ends at the first line break that is not inside quotes.

To keep one stray `"` from turning the rest of the file into a single field,
splitlane limits how long a row can get. A row that grows past
`--max-row-bytes` (counted in UTF-8 bytes) is cut at that limit. The rest of
it is skipped up to the next line break, and reading continues from there. The
shortened row is still written to the output, so the chunk keeps its row
count, but its data is incomplete.

When a run finishes with truncated rows, splitlane prints a warning to stderr
with the count:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The warning doesn't say which rows were cut. If your data has legitimately long
rows, such as large multi-line notes, raise `--max-row-bytes`. If you load the
chunks into another system, check for this warning first, because a truncated
row looks like a normal row.

The skip after a truncation stops at the next line break even if that break is
inside quotes. In rare cases, reading can resume in the middle of a real
multi-line field.
