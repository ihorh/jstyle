# splitlane

splitlane splits a large CSV file into smaller files. Every output file starts with the input's header row, so each one can be opened or imported by itself.

```
$ splitlane customers.csv --rows 50000 --out chunks
splitlane: processing customers.csv
splitlane: wrote 4 chunk(s) to chunks/
```

```
chunks/part-0001.csv   header + rows 1–50000
chunks/part-0002.csv   header + rows 50001–100000
...
```

- **Quoted line breaks stay in their row.** A field like `"called twice⏎asked for refund"` is kept as one row, following RFC 4180. Spreadsheet and CRM exports often contain fields like this.
- **One bad quote can't take over the whole file.** If a stray `"` makes a row run past the size limit, splitlane cuts that row off, counts it and carries on. You get one damaged row and the rest of the file is split normally. See [Truncated rows](#truncated-rows).
- **Problems are reported.** It prints the number of truncated rows when the run ends. Usage errors and decoding errors each have their own exit code.
- **No dependencies.** It uses only the Python standard library.

> **Status:** This README describes `main`, which will become **0.4.0** (not yet released). 0.4.0 renames the output files and changes how quoted fields are handled. If you're on 0.3.x, see [Upgrading from 0.3.x](#upgrading-from-03x).

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
|---|---|---|
| `--rows N` | `100000` | Data rows per chunk, not counting the header. Must be at least 1. |
| `--out DIR` | `out` | Output directory. Created if it doesn't exist. |
| `--max-row-bytes N` | `65536` | Longest row, in bytes, that is kept whole. Longer rows are truncated. |
| `--encoding NAME` | `utf-8` | Encoding of the input file. Any Python codec name works, e.g. `latin-1` or `cp1252`. |

Output files are named `part-0001.csv`, `part-0002.csv` and so on, and are always written as UTF-8 whatever the input encoding is. Rows are copied as they are and are not re-quoted or reformatted. splitlane only looks at line breaks and double quotes, so any delimiter works: commas, semicolons or tabs.

All messages go to stderr. stdout stays empty.

### Exit codes

| Code | Meaning |
|---|---|
| `0` | Success. This includes runs where some rows were truncated, so check stderr for the warning. |
| `2` | Invalid arguments, e.g. `--rows 0`. |
| `3` | The input could not be decoded with `--encoding`. |

## Truncated rows

When a row is longer than `--max-row-bytes`, splitlane:

1. writes the first `--max-row-bytes` bytes of the row to the chunk,
2. skips ahead to the next line break,
3. counts the row as truncated and keeps going.

At the end of the run it prints a warning:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

A truncated row is shortened, not removed, and it probably has the wrong number of columns. **If your pipeline needs complete data, check for this warning in stderr.** The exit code is still `0`.

This usually means one of two things:

- **The file has a stray, unmatched `"`.** That row is damaged, and the rows around it may be too (see below).
- **The file has rows that really are very long.** Raise `--max-row-bytes`.

Known limitation: after truncating, splitlane skips to the next line break even if that line break is inside a quoted field. In rare cases it can start reading again in the middle of a multi-line field, which damages a row or two more before it gets back on track.

## Things to know before you rely on it

- **Use an empty output directory.** splitlane overwrites `part-NNNN.csv` files that are already there, but it doesn't delete leftovers. Say an earlier run wrote 10 chunks to `chunks/` and the new run writes 6. Then `part-0007.csv` to `part-0010.csv` are still there from the old run.
- **A failed run leaves partial output.** Chunks are written as the input is read. If decoding fails partway through (exit code `3`), the chunks written before the failure stay on disk. Delete them, then run again with the right `--encoding`. A file that `file` reports as `ISO-8859 text` usually needs `--encoding latin-1`.
- **Windows: close the chunk files first.** If a chunk from an earlier run is open in another program, such as Excel, splitlane crashes with `PermissionError` when it tries to overwrite it. The earlier chunks have already been replaced by then, so the directory holds a mix of new and old files, and the error doesn't say which file failed. Close the files or use a new output directory. This is a known issue (#57).
- **An input with no data rows produces no files.** That includes an empty file and a file that has only a header.
- **Over 9999 chunks, names stop sorting cleanly.** Names are zero-padded to four digits, so the 10000th chunk is `part-10000.csv`, which sorts in the wrong place.

## Use as a library

```python
from splitlane.split import split_file

written, truncated = split_file(
    "customers.csv",
    rows_per_chunk=50000,
    out_dir="chunks",
    max_row_bytes=65536,
    encoding="utf-8",
)
# written:   list of chunk file paths, in order
# truncated: number of rows cut at max_row_bytes
```

`split_file` raises `UnicodeDecodeError` if the input doesn't match `encoding`. Unlike the CLI, it doesn't check `rows_per_chunk`, so make sure it is at least 1.

## Upgrading from 0.3.x

- **Output files have new names.** 0.3.x wrote `chunk_1.csv`, `chunk_2.csv` and so on. 0.4.0 writes `part-0001.csv`, `part-0002.csv` and so on. Update any scripts that look for the old names.
- **Quoted line breaks are now kept.** In 0.3.x, a line break inside a quoted field ended the row and split one record into two broken rows (#42). Row counts per chunk can change for files that contain such fields.
- **New exit codes.** `--rows 0` used to loop forever and now exits with `2`. Decoding errors now exit with `3` and print a message.
- **New truncation warning** at the end of a run.

See [CHANGELOG.md](CHANGELOG.md) for the full list.
