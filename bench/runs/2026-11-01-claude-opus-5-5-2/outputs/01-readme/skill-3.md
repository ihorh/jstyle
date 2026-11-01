# splitlane

splitlane splits a large CSV file into smaller files, called chunks, each with a fixed number of rows. Every chunk starts with a copy of the input's header row, so you can load each chunk on its own.

splitlane handles quoted fields the way RFC 4180 and spreadsheets do: a line break inside a quoted field stays part of that field. For example, if a CRM export has a `notes` column with line breaks in it, each customer still comes out as one row instead of two broken ones.

splitlane is a small Python command-line tool that uses only the standard library. It reads the input once, row by row, so a bigger file doesn't use more memory. It finds where each row ends but doesn't parse the fields. Each row is copied unchanged, with its original delimiter and line ending.

## Status

The code on `main` is version 0.4.0, which hasn't been released yet. Before you rely on it, read [Known issues](#known-issues), especially if you're on Windows.

The repository has no packaging metadata yet, so `pip install` won't work. Run splitlane from a checkout instead. The repository also doesn't include a license file yet.

## Running it

From the root of a checkout:

```bash
PYTHONPATH=src python3 -m splitlane.cli data/export.csv --rows 50000 --out chunks
```

In PowerShell:

```powershell
$env:PYTHONPATH = "src"; python -m splitlane.cli data/export.csv --rows 50000 --out chunks
```

This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. Each chunk holds up to 50,000 data rows plus the header, and the last chunk holds whatever rows are left. If the input has no data rows, splitlane writes no chunks.

| Option | Meaning | Default |
| --- | --- | --- |
| `--rows N` | Data rows per chunk, not counting the header. Must be at least 1. | `100000` |
| `--out DIR` | Output directory. splitlane creates it if it's missing. | `out` |
| `--max-row-bytes N` | The longest row splitlane keeps whole. See [Rows that are too long](#rows-that-are-too-long). | `65536` |
| `--encoding NAME` | Encoding of the input file, such as `latin-1` or `cp1252`. | `utf-8` |

Chunks are always written as UTF-8, whatever the input encoding is. If the input starts with a byte-order mark, as Excel's "CSV UTF-8" exports do, the default `utf-8` copies the mark into the header of every chunk. To drop it, use `--encoding utf-8-sig`.

Chunk numbers are padded to four digits. After `part-9999.csv`, a run continues with `part-10000.csv`, and that name sorts before `part-9999.csv`. If you need the name order to match the row order, raise `--rows` so the run stays under 10,000 chunks.

## Output directory

splitlane doesn't clear the output directory before a run. It overwrites chunks that have the same name and leaves every other file alone. If an earlier run wrote 12 chunks and the new one writes 8, chunks 9 to 12 from the earlier run are still there. Use an empty or new directory for each run.

## Messages and exit codes

splitlane prints all its messages to stderr and nothing to stdout.

| Exit status | Meaning |
| --- | --- |
| `0` | The run finished. Some rows may have been truncated. See [Rows that are too long](#rows-that-are-too-long). |
| `1` | An unexpected error, such as a missing input file. Python prints a traceback. |
| `2` | Bad arguments, such as `--rows 0`. |
| `3` | The input couldn't be decoded with the given `--encoding`. |

If decoding fails, the chunks written before the bad byte stay in the output directory, and the last of them is incomplete. Don't use that output. Choose the right encoding and run again into an empty directory. For example, a file that the Unix `file` command reports as `ISO-8859 text` needs `--encoding latin-1`.

## Rows that are too long

A stray, unmatched `"` can make a quote-aware reader treat the rest of the file as a single field. splitlane limits that damage with `--max-row-bytes`, which counts the row's size in UTF-8 bytes even when the input uses another encoding.

When a row grows past the limit, splitlane cuts it off there. It discards the rest of the input up to the next line break and starts reading the next row after that break. The search for that line break ignores quotes. In rare cases, splitlane can therefore resume in the middle of a legitimate multi-line field, and the row after the cut one also comes out wrong.

splitlane still writes the cut row, so that row usually has the wrong number of columns. At the end of the run, splitlane reports how many rows it cut:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The exit status is still `0`. If the chunks feed another system, make your scripts check stderr for this line.

If your data has genuinely long rows, set `--max-row-bytes` higher than the longest one.

## Known issues

- **On Windows, a chunk that's open in another program stops the run partway** ([#57](../../issues/57)). Suppose a chunk from an earlier run is open, for example in Excel. When splitlane tries to overwrite it, splitlane crashes with `PermissionError`. The chunks before it have already been rewritten, and the error doesn't say which ones, so the directory ends up with a mix of new and old chunks. Close the files first, or write to a new directory.

## Using it from Python

The splitting code is in `splitlane.split`:

```python
from splitlane.split import split_file

written, truncated = split_file("data/export.csv", 50000, "chunks",
                                max_row_bytes=65536, encoding="utf-8")
```

`written` is the list of chunk paths. `truncated` is the number of rows that were cut at `max_row_bytes`. If decoding fails, `split_file` raises `UnicodeDecodeError`. This module isn't a stable API yet, so pin a specific commit if you depend on it.

## Changes from 0.3

0.4.0 changes some behavior that your scripts may depend on:

- Chunks are named `part-0001.csv` instead of `chunk_1.csv`. Update any scripts that look for the old names.
- A line break inside a quoted field now stays in its field ([#42](../../issues/42)). In 0.3, such a line break split the record into two rows.
- splitlane now counts and reports truncated rows. `--rows 0` exits with status 2, and a decoding error exits with status 3.

The full list is in [CHANGELOG.md](CHANGELOG.md).
