# splitlane

Split a large CSV file into smaller CSV files. Every chunk starts with the input's header row.

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

This writes `chunks/part-0001.csv`, `chunks/part-0002.csv`, and so on. Each chunk holds up to 50,000 data rows.

## Install

splitlane is installed from a checkout:

```bash
git clone <this repository's URL>
cd splitlane
pip install .
```

## Options

| Option | Meaning | Default |
| --- | --- | --- |
| `--rows N` | Data rows per chunk, not counting the header. Must be at least 1. | 100000 |
| `--out DIR` | Output directory, created if missing. | `out` |
| `--max-row-bytes N` | Longest row kept whole. Longer rows are cut. | 65536 |
| `--encoding NAME` | Encoding of the input file. | `utf-8` |

Chunks are always written as UTF-8, whatever the input encoding.

## How it handles awkward input

**Quoted line breaks.** A quoted field that contains a newline stays inside its row, as RFC 4180 describes. A CRM export with multi-line notes splits cleanly.

**Stray quotes.** A lone `"` makes the reader think a field never ends. To contain the damage, a row that grows past `--max-row-bytes` is cut at that limit, and reading resumes at the next newline. One row is damaged and the rest of the file is unaffected. If your data has legitimate rows longer than 64 KiB, raise the limit.

**Truncation is reported, not silent.** At the end of a run, splitlane prints the number of truncated rows to stderr:

```
splitlane: warning: 1 row(s) longer than 65536 bytes were truncated
```

The exit status is still 0, so a script that needs to catch truncation has to look for this message.

**Wrong encoding.** If the input can't be decoded, splitlane prints the error and exits with status 3. Chunks written before the bad byte stay on disk, so delete the output directory before you retry. Pass `--encoding` (for example `--encoding latin-1`) to read a non-UTF-8 file.

## Output and exit status

- All messages go to stderr. Nothing is printed to stdout.
- Exit status is 0 on success, 2 for invalid arguments (such as `--rows 0`), and 3 for a decoding failure.
- Existing files with the same names in the output directory are overwritten.

## Known limitations

- **Windows:** if a chunk file from an earlier run is open in Excel, splitlane crashes with `PermissionError` when it tries to overwrite that file. The chunks before it are already written, and the error doesn't say which ones. You end up with a mix of new and old chunks. Close the files, or use an empty output directory. This is tracked as #57.
- **Resync after truncation:** after cutting a row, splitlane resumes at the next newline even if that newline is inside quotes. In rare cases it can resume in the middle of a real multi-line field.

## Using it from Python

```python
from splitlane.split import split_file

written, truncated = split_file("data/export.csv", 50000, "chunks")
```

`split_file` returns the list of chunk paths and the number of truncated rows. Its optional arguments are `max_row_bytes` and `encoding`.

## Changes

See [CHANGELOG.md](CHANGELOG.md). Version 0.4.0 isn't released yet, so this README describes the current `main` branch. Chunk names changed in 0.4.0 from `chunk_N.csv` to the zero-padded `part-NNNN.csv`, so update any pipeline that matches the old names.
