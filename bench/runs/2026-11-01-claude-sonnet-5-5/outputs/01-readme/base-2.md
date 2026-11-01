# splitlane

Split a large CSV file into smaller CSV files. Every chunk starts with the input's header row.

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on.

## Why use it

- **Quoted newlines stay in one row.** A field like `"called twice⏎asked for refund"` is not split across two rows, as RFC 4180 specifies. (Fixed in 0.4.0, which is not released yet. See [Status](#status).)
- **A malformed quote can't swallow the file.** A stray `"` damages at most one row. The reader stops at `--max-row-bytes`, truncates that row, and carries on.
- **Truncation is reported.** The run ends with a warning on stderr that gives the number of truncated rows, so you can check for it in scripts.
- **Memory use stays small.** It reads the input row by row. It has no dependencies beyond the Python standard library.

## Install

From a checkout:

```bash
pip install .
```

## Usage

```bash
splitlane INPUT [--rows N] [--out DIR] [--max-row-bytes N] [--encoding NAME]
```

| Option | Meaning | Default |
| --- | --- | --- |
| `--rows N` | Rows per chunk, not counting the header. Must be at least 1. | `100000` |
| `--out DIR` | Output directory. Created if missing. | `out` |
| `--max-row-bytes N` | Longest row kept whole. Longer rows are truncated and counted. | `65536` |
| `--encoding NAME` | Input encoding. Output is always UTF-8. | `utf-8` |

All messages go to stderr.

### Exit codes

| Code | Meaning |
| --- | --- |
| `0` | Success |
| `2` | Invalid usage, such as `--rows 0` |
| `3` | The input could not be decoded with the given encoding |

If a file isn't UTF-8, pass its encoding explicitly, for example `--encoding latin-1`.

## Limitations

- **A failed run can leave partial output.** Chunks are written directly into the output directory. If the run stops partway, for example on a decode error, the chunks written so far stay there. Use a fresh `--out` directory for each run and check the exit code.
- **Windows: overwriting open files fails.** If a chunk from an earlier run is open in Excel, splitlane crashes with `PermissionError` and doesn't say which file. You end up with a mix of new and old chunks (#57). Write to an empty directory to avoid this.
- **Truncated rows lose data.** A row longer than `--max-row-bytes` is cut at that point. This is how a stray quote is contained. If your data has legitimately huge fields, raise the limit.
- **Recovery after truncation is approximate.** After a cut, the reader skips to the next newline even if that newline is inside quotes. In rare cases it can resume in the middle of a real multi-line field.

## Status

The current release is 0.3.1. Version 0.4.0 is still unreleased and contains the quoted-newline fix, the zero-padded `part-NNNN.csv` naming, the truncation report, and the exit codes above. Earlier versions named chunks differently and split rows at every newline. If you have scripts that depend on file names, check the [changelog](CHANGELOG.md) before upgrading.

The 0.4.0 release is waiting on the Windows issue (#57).

## Contributing

Issues and discussion are welcome. Please keep changes dependency-free, write messages to stderr only, and don't change output file names or option defaults without discussing it first.
