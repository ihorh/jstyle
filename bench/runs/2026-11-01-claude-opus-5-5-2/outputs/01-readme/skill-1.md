# splitlane

splitlane splits a large CSV file into smaller files. Each file holds a fixed number of rows, and each starts with the input's header row. You can use it as a command-line tool or as a Python library. It uses only the Python standard library.

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

This command writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. Every file except the last holds 50,000 data rows plus the header.

> **Version note.** This README describes the `main` branch, which holds the unreleased 0.4.0. If you're coming from 0.3.x, two changes affect existing scripts. Output files are now named `part-0001.csv` instead of `chunk_1.csv`, and quoted fields can now contain line breaks. [CHANGELOG.md](CHANGELOG.md) lists every change.

## Install

splitlane isn't published to a package index, so install it from a checkout:

```bash
git clone <repository-url>
cd splitlane
pip install .
```

## Usage

```
splitlane INPUT [--rows N] [--out DIR] [--max-row-bytes N] [--encoding NAME]
```

| Option | Meaning | Default |
| --- | --- | --- |
| `--rows N` | Data rows per output file, not counting the header. Must be at least 1. | `100000` |
| `--out DIR` | Output directory. splitlane creates it if it's missing. | `out` |
| `--max-row-bytes N` | The longest row splitlane keeps whole. Longer rows are cut off, as described under [Long rows and stray quotes](#long-rows-and-stray-quotes). | `65536` |
| `--encoding NAME` | Encoding of the input file, such as `latin-1` or `cp1252`. | `utf-8` |

All messages, including the summary at the end of a run, go to stderr. Nothing is printed to stdout.

### Exit status

| Status | Meaning |
| --- | --- |
| `0` | The split finished. Check stderr for a truncation warning anyway (see below). |
| `2` | The arguments were invalid, for example `--rows 0`. |
| `3` | The input couldn't be decoded with `--encoding`. |

If decoding fails partway through, the output files written before the failure stay in place. Delete them and run again with the right `--encoding`. For example, a file exported as ISO-8859-1 needs `--encoding latin-1`.

## How splitlane reads CSV

### Quoted fields with line breaks

A line break inside a quoted field stays in that field, as RFC 4180 specifies. For example, this input has two data rows, not three:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

### Long rows and stray quotes

A single unmatched `"` in a file would normally make everything after it look like one long field. splitlane limits the damage with `--max-row-bytes`. When a row grows past that limit, splitlane:

1. writes the first `--max-row-bytes` bytes of the row and drops the rest,
2. skips ahead to the next line break, and
3. continues reading normal rows from there.

A stray quote damages one row instead of the rest of the file. The cost is that **a truncated row is written in its shortened form**, so its data is incomplete. At the end of the run, splitlane reports how many rows it truncated:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

If your pipeline can't accept incomplete rows, check stderr for this warning. If your file has legitimately long rows, raise `--max-row-bytes` above the longest one.

When skipping ahead, splitlane stops at the next line break even if that line break sits inside a quoted field. In rare cases, it can therefore pick up reading in the middle of a real multi-line field.

### Encoding and line endings

splitlane reads the input in the encoding given by `--encoding` and always writes the output as UTF-8. Line endings are copied as they are, so a file with CRLF line endings produces output files with CRLF line endings.

## Things to know before you rely on it

- **splitlane doesn't clear the output directory.** It overwrites files with the same names. Files left over from an earlier, longer run stay where they are. For example, if an earlier run wrote `part-0005.csv` and this run writes only four files, the old `part-0005.csv` remains. Use a new or empty directory for each run.
- **Input files with no data rows produce no output files.** This includes an empty file and a file that holds only a header.
- **Known issue on Windows (#57).** If an output file from an earlier run is open in another program, such as Excel, splitlane stops with a `PermissionError` when it tries to overwrite that file. The files written before the error hold new data and the rest hold old data, and the error doesn't say which file failed. Close the files, or write to a new directory.

## Use as a library

```python
from splitlane.split import split_file

written, truncated = split_file(
    "data/export.csv",
    rows_per_chunk=50000,
    out_dir="chunks",
    max_row_bytes=65536,
    encoding="utf-8",
)
```

`written` is the list of output file paths in order. `truncated` is the number of rows cut off at `max_row_bytes`. If the input can't be decoded, `split_file` raises `UnicodeDecodeError`.

## Changes

See [CHANGELOG.md](CHANGELOG.md).
