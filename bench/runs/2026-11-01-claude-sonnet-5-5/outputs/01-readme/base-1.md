# splitlane

Split a large CSV file into smaller CSV files. Each output file starts with the input's header row.

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

```
chunks/part-0001.csv
chunks/part-0002.csv
...
```

## Why use it

- **Quoted newlines are handled.** A field like `"called twice⏎asked for refund"` stays in one row, as RFC 4180 specifies. Rows are never split in the middle of a quoted field.
- **A stray quote can't swallow the file.** A malformed quote can make a reader treat the rest of the file as one field. splitlane caps row length with `--max-row-bytes`. A row that reaches the cap is cut there and counted, and reading resumes at the next line. A stray quote damages one row, not everything after it.
- **Truncation is reported.** If any row is cut, the run ends with a warning on stderr that gives the count. You can check for it in scripts.
- **No dependencies.** It's pure Python and uses only the standard library.

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
| `--out DIR` | `out` | Output directory. It's created if missing. |
| `--max-row-bytes N` | `65536` | Longest row kept whole. Longer rows are truncated and counted. |
| `--encoding NAME` | `utf-8` | Encoding of the input file. Output is always UTF-8. |

Progress and warnings go to stderr:

```
splitlane: processing data/export.csv
splitlane: wrote 3 chunk(s) to chunks/
splitlane: warning: 1 row(s) longer than 65536 bytes were truncated
```

### Exit codes

| Code | Meaning |
| --- | --- |
| `0` | Success. Check stderr for the truncation warning. |
| `2` | Invalid usage, such as `--rows 0`. |
| `3` | The input couldn't be decoded with the given `--encoding`. |

## Known limitations

- **Truncation loses data.** A row longer than `--max-row-bytes` is cut, not preserved. If your data has legitimately huge fields, raise the limit. If a run reports truncated rows, treat those rows as damaged.
- **Resync after truncation is approximate.** After a cut, reading resumes at the next newline even if that newline is inside quotes. In rare cases the reader may resume in the middle of a real multi-line field.
- **Windows: overwriting open files.** Chunks are written directly into the output directory. On Windows, if a chunk from an earlier run is open in Excel, splitlane stops with a `PermissionError` and doesn't say which file caused it. Earlier chunks have already been written, so you can end up with a mix of new and old files. Close the files or use a fresh `--out` directory. This is tracked as #57.
- **Output file naming changed in 0.4.0.** Names are zero-padded (`part-0001.csv`). Scripts that depend on older names need updating.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).
