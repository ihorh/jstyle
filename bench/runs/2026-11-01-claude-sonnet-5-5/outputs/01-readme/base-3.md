# splitlane

Split a large CSV file into smaller CSV files. Every chunk repeats the header row.

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

```
chunks/part-0001.csv
chunks/part-0002.csv
...
```

It uses only the Python standard library and has no dependencies.

## Why use it

- **Quoted newlines are handled.** A quoted field that contains line breaks, such as a free-text notes column, stays in one row (RFC 4180). Rows are never cut in the middle of a field.
- **One bad quote can't swallow the file.** A stray `"` would normally make a reader treat everything after it as one field. Here a row stops growing at `--max-row-bytes`. That row is cut and counted, and reading carries on from the next line.
- **Truncation is reported.** If any rows were cut, the run ends with a warning on stderr that gives the count. Check for it in scripts.
- **Scripts get clear exit codes.** See below.

## Install

From a checkout:

```bash
pip install .
```

It needs Python 3 and has no runtime dependencies. It is not published to PyPI.

## Usage

```bash
splitlane INPUT [--rows N] [--out DIR] [--max-row-bytes N] [--encoding NAME]
```

| Option | Default | Meaning |
|---|---|---|
| `--rows N` | `100000` | Rows per chunk, not counting the header. Must be at least 1. |
| `--out DIR` | `out` | Output directory. Created if missing. |
| `--max-row-bytes N` | `65536` | Longest row kept whole. Longer rows are cut here and counted as truncated. |
| `--encoding NAME` | `utf-8` | Input encoding. |

Progress and messages go to stderr. Nothing is written to stdout.

### Exit codes

| Code | Meaning |
|---|---|
| `0` | Success. Check stderr for a truncation warning. |
| `2` | Bad usage, such as `--rows 0`. |
| `3` | The input could not be decoded with `--encoding`. |

### Library use

```python
from splitlane.split import split_file

written, truncated = split_file("data/export.csv", 50000, "chunks")
```

`split_file` returns the list of files written and the number of truncated rows.

## Limitations

Know these before you rely on it:

- **Truncated rows lose data.** A row longer than `--max-row_bytes` is cut, and a downstream importer won't notice the shortened row. Raise `--max-row-bytes` if your data has very large fields, and check for the warning.
- **Recovery after truncation is approximate.** After a cut, the reader skips to the next newline, even one inside quotes. In rare cases it can resume in the middle of a real multi-line field.
- **A failed run can leave partial output.** If the input can't be decoded partway through (exit code 3), the chunks written before the error stay in the output directory. Rerun with the correct `--encoding` into an empty directory. For example, a Latin-1 file needs `--encoding latin-1`.
- **Output is always UTF-8**, whatever the input encoding.
- **Existing files are overwritten without warning.** Chunks from an earlier run with the same names are replaced. Extra chunks left from a longer earlier run are not removed. Use a fresh `--out` directory.
- **Windows: open chunks can break a rerun.** If a chunk from an earlier run is open in Excel, splitlane stops with a `PermissionError` that doesn't name the file. Chunks before that one are already rewritten, so you end up with a mix of old and new files. Close the files or use a new output directory. This is a known issue (#57).
- **It reads one character at a time.** It is built for correctness and a small memory footprint, not for speed. It never loads the whole input into memory. It also doesn't report percentage progress.
- It does not validate that rows have the same number of columns as the header.

## Upgrading from 0.3.x

0.4.0 changes the output file names from `chunk_N.csv` to zero-padded `part-0001.csv`. Update any pipeline that matches the old names. See [CHANGELOG.md](CHANGELOG.md) for the full list of changes.

## Reporting problems

Open an issue with a small input that reproduces the problem and the stderr output from the run.
