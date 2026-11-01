# splitlane

splitlane splits a large CSV file into smaller files. Every output file starts with the input's header row, so each one is a valid CSV on its own. It handles quoted fields that contain line breaks, and it reports any row it had to cut instead of hiding the damage.

It needs only Python's standard library.

```bash
splitlane exports/customers.csv --rows 50000 --out chunks
```

```
chunks/part-0001.csv   header + rows 1–50000
chunks/part-0002.csv   header + rows 50001–100000
...
```

## Install

There is no package on PyPI yet. Install from a checkout:

```bash
git clone <this repository>
cd splitlane
pip install .
```

## Usage

```
splitlane INPUT [--rows N] [--out DIR] [--max-row-bytes N] [--encoding NAME]
```

| Option | Default | Meaning |
|---|---|---|
| `--rows N` | `100000` | Data rows per chunk, not counting the header. Must be at least 1. |
| `--out DIR` | `out` | Output directory. It is created if it doesn't exist. |
| `--max-row-bytes N` | `65536` | Longest row kept whole. See [Long rows and stray quotes](#long-rows-and-stray-quotes). |
| `--encoding NAME` | `utf-8` | Encoding of the input file. Any Python codec name works, e.g. `latin-1`, `cp1252`. |

Chunks are named `part-0001.csv`, `part-0002.csv`, and so on. They are always written as UTF-8, whatever the input encoding, so `--encoding` also converts the file to UTF-8.

An input with only a header, or an empty input, produces no chunks.

### Output and exit codes

splitlane prints nothing to stdout. All progress messages and warnings go to stderr.

| Exit code | Meaning |
|---|---|
| `0` | Success. **Check stderr for a truncation warning**, because a run that truncated rows still exits 0. |
| `2` | Bad arguments, e.g. `--rows 0`. |
| `3` | The input could not be decoded with the given `--encoding`. |

If you get exit code 3, the file is probably not UTF-8. A file that `file` reports as `ISO-8859 text` usually works with `--encoding latin-1`.

## Quoted fields with line breaks

Following RFC 4180, a line break inside a quoted field belongs to that field and does not end the row. This input has two data rows, not three:

```csv
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

Exports from CRMs, ticket systems, and spreadsheets often contain fields like this. splitlane keeps each of them in one piece.

## Long rows and stray quotes

When a file has one unmatched `"`, a quote-aware reader can treat the rest of the file as a single field. splitlane limits that damage with `--max-row-bytes`:

- When a row passes the limit, splitlane cuts it at the limit, skips ahead to the next line break, and continues from there.
- At the end of the run, it prints how many rows were cut:

  ```
  splitlane: warning: 1 row(s) longer than 65536 bytes were truncated
  ```

A real multi-line field is normally far below the default limit. A stray quote will hit the limit, and you lose the input between the quote and the cut-off point. That loss is confined to one bad row, and the rest of the file is unaffected.

If your data really has rows longer than 64 KiB, raise `--max-row-bytes`. If you feed the output to an importer that won't notice a shortened row, check stderr for the warning in your scripts.

## Using it as a library

```python
from splitlane.split import split_file

written, truncated = split_file("export.csv", 50000, "chunks",
                                max_row_bytes=65536, encoding="utf-8")
# written:   list of chunk paths, in order
# truncated: number of rows cut at max_row_bytes
```

`split_file` raises `UnicodeDecodeError` if the input doesn't match `encoding`.

## Known limitations

- **Old chunks are not removed.** splitlane overwrites `part-NNNN.csv` files with the same name but never deletes others. If a new run writes fewer chunks than an earlier run in the same directory, the extra old chunks stay behind. Use a fresh or empty `--out` directory for each run.
- **Failures leave partial output.** If a run stops partway through, for example on a decoding error, the chunks written so far stay on disk. Treat a non-zero exit code as "discard the output directory".
- **Windows: open chunk files cause a crash ([#57](../../issues/57)).** If a chunk from an earlier run is open in another program, such as Excel, splitlane fails with `PermissionError` when it tries to overwrite that chunk. The directory is then left holding a mix of new and old chunks. Close the files or write to a new directory.
- **Recovery after a cut row can land inside a quoted field.** After cutting a row, splitlane resumes at the next line break, even if that line break is inside a quoted multi-line field. This is rare, but it can damage the row that follows.
- **Comma-separated input only.** There is no option for other delimiters or quote characters.

## Upgrading from 0.3.x

The next release, 0.4.0 (currently on the main branch), changes behavior you may depend on:

- Chunk files are now named `part-0001.csv` instead of `chunk_1.csv`. Update any scripts or globs that match the old names.
- Quoted line breaks no longer split a row in two ([#42](../../issues/42)).
- `--rows 0` now exits with status 2 instead of hanging.
- A decoding error now exits with status 3.
- The number of truncated rows is reported at the end of the run.

See [CHANGELOG.md](CHANGELOG.md) for the full history.
