# splitlane

splitlane splits a large CSV file into smaller files. Each output file starts with the input's header row.

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. Each chunk holds up to 50,000 data rows plus the header.

## What it does and doesn't do

- **Every chunk gets the header.** The first row of the input is the header, and it is copied to the top of every chunk.
- **Quoted newlines stay in their row.** A field in double quotes can contain line breaks, as RFC 4180 allows. That whole field stays in one row and is never split across two rows or two chunks. For example, this input has two data rows, not three:

  ```
  id,name,notes
  7,Ana,"called twice
  asked for refund"
  8,Bo,ok
  ```

- **Rows are copied as they are.** splitlane doesn't parse fields, re-quote them or check column counts. The only things it looks at are double quotes and newlines.
- **One pass, row by row.** The input is never loaded into memory all at once.
- **Output is always UTF-8.** You can choose the input encoding with `--encoding`, but chunks are always written as UTF-8.
- **No dependencies** beyond the Python standard library.

## Install

From a checkout:

```bash
pip install .
```

## Usage

```bash
splitlane INPUT [--rows N] [--out DIR] [--max-row-bytes N] [--encoding NAME]
```

| Option | Default | Meaning |
| --- | --- | --- |
| `--rows N` | `100000` | Data rows per chunk, not counting the header. Must be at least 1. |
| `--out DIR` | `out` | Output directory. Created if it doesn't exist. |
| `--max-row-bytes N` | `65536` | Longest row kept whole. Longer rows are truncated (see below). |
| `--encoding NAME` | `utf-8` | Encoding of the input file, for example `latin-1`. |

All messages go to stderr. Nothing is printed to stdout.

### Exit status

| Status | Meaning |
| --- | --- |
| `0` | Success. This includes runs that truncated rows, so check stderr for the warning. |
| `2` | Bad arguments, for example `--rows 0`. |
| `3` | The input could not be decoded with the given `--encoding`. |

## Long rows and stray quotes

A single unmatched `"` would make a quote-aware reader treat the rest of the file as one field. splitlane uses `--max-row-bytes` to limit that damage. A row that grows past the limit is cut at the limit, and everything after that up to the next newline is discarded. Reading then continues from the next line.

So a stray quote usually damages one row instead of the whole file. A real multi-line field is normally far below the 64 KiB default and isn't affected.

Truncation is never silent. If any rows were cut, the run ends with a message like this:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The exit status is still `0` when this happens. If your pipeline can't accept truncated rows, check stderr for this line. If your data really has rows longer than the limit, raise `--max-row-bytes`.

Two things to know about this:

- A truncated row is usually malformed, because it may be missing its closing quote or some columns.
- After a cut, reading resumes at the next newline, even if that newline is inside a quoted field. If a stray quote comes right before a real multi-line field, a few more rows near it can be damaged.

## Things to watch out for

- **Use a fresh output directory.** splitlane overwrites chunk files with the same names but never deletes old ones. Say an earlier run wrote 10 chunks and the new run writes 6. Then `part-0007.csv` to `part-0010.csv` from the earlier run are still in the directory.
- **A failed run leaves partial output.** If decoding fails partway through (exit status `3`), the chunks written before the error stay on disk. Delete them before you retry. Files exported from older tools or from Excel are often Latin-1 or Windows-1252, not UTF-8:

  ```bash
  splitlane export.csv --encoding latin-1 --out chunks
  ```

- **Windows: files open in another program (#57).** On Windows, if a chunk file from an earlier run is open in another program such as Excel, splitlane crashes with `PermissionError` when it tries to overwrite that file. The chunks before it have already been replaced and the ones after it haven't, so you end up with a mix of new and old chunks. The error doesn't say which file caused it. Until this is fixed, close any open chunk files or write to a new directory.
- **Empty input.** If the input is empty or has only a header row, no chunks are written.

## Using it as a library

```python
from splitlane.split import split_file

written, truncated = split_file("export.csv", 50000, "chunks",
                                max_row_bytes=65536, encoding="utf-8")
# written:   list of chunk file paths, in order
# truncated: number of rows that were cut at max_row_bytes
```

`split_file` raises `UnicodeDecodeError` if the input doesn't match `encoding`.

## Upgrading from 0.3.x

The 0.4.0 changes are listed under "Unreleased" in [CHANGELOG.md](CHANGELOG.md). These are the ones that may affect scripts:

- **Output files have new names.** `chunk_1.csv`, `chunk_2.csv`, … became `part-0001.csv`, `part-0002.csv`, …. Update any scripts or globs that look for the old names.
- **Quoted newlines are now handled** (#42). Files with multi-line fields now give fewer, correct rows. Before, those rows were split in two.
- `--rows 0` now exits with status 2 instead of looping.
- Decoding errors now exit with status 3.
- Runs that truncate rows now print how many were truncated.

See [CHANGELOG.md](CHANGELOG.md) for the full history.
