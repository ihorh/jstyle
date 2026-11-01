# splitlane

splitlane splits a large CSV file into smaller files. Every output file gets the input's header row. It's a small command-line tool and Python library with no dependencies outside the standard library.

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

```
chunks/part-0001.csv   header + rows 1–50000
chunks/part-0002.csv   header + rows 50001–100000
...
```

## When to use it

Use splitlane when a CSV export is too big for the next step in your pipeline, such as an importer with a row limit, a spreadsheet, or an upload size cap, and each piece has to be a valid CSV file on its own.

splitlane follows RFC 4180 quoting. A quoted field that contains line breaks stays in one row and is never split across two rows or two files. CRM exports with free-text "notes" columns are a common example:

```csv
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

splitlane counts this as two data rows.

## Install

Install from a checkout of this repository:

```bash
pip install .
```

## Usage

```bash
splitlane INPUT [--rows N] [--out DIR] [--max-row-bytes N] [--encoding NAME]
```

| Option | Default | Meaning |
| --- | --- | --- |
| `--rows N` | `100000` | Data rows per output file, not counting the header. Must be at least 1. |
| `--out DIR` | `out` | Output directory. Created if it doesn't exist. |
| `--max-row-bytes N` | `65536` | Longest row that is kept whole. See [Long rows and stray quotes](#long-rows-and-stray-quotes). |
| `--encoding NAME` | `utf-8` | Encoding of the input file, e.g. `latin-1` or `cp1252`. |

Output files are named `part-0001.csv`, `part-0002.csv`, and so on, and are always written as UTF-8. splitlane prints all of its messages to stderr, so stdout stays empty.

### Exit status

| Code | Meaning |
| --- | --- |
| `0` | Success. Check stderr for a truncation warning (see below). |
| `2` | Invalid arguments, e.g. `--rows 0`. |
| `3` | The input could not be decoded with `--encoding`. |

## Long rows and stray quotes

If a quote in a file is never closed, a reader that tracks quotes can treat the rest of the file as a single field. splitlane limits this damage with `--max-row-bytes`:

- If a row grows past the limit, splitlane cuts it at the limit, writes the part it has so far, and skips ahead to the next line break.
- Every row cut this way is counted. At the end of the run, splitlane prints:

  ```
  splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
  ```

A truncated row has lost data, and the exit status is still `0`. If downstream systems can't tolerate shortened rows, have your scripts check stderr for this warning. If your file has rows that really are longer than 64 KiB, raise `--max-row-bytes`.

After a truncation, splitlane resumes at the next line break, even if that line break is inside a quoted field. In rare cases, a row or two after a stray quote can therefore also come out malformed.

## Things to know before you rely on it

- **Failed runs leave partial output.** For example, if decoding fails partway through the input, the chunks written before the failure stay in the output directory. Treat any non-zero exit status as "discard this output directory."
- **Old chunks are not cleaned up.** splitlane overwrites files with the same names, but it doesn't delete extra files from an earlier run that produced more chunks. Use a fresh or empty `--out` directory for each run.
- **Header-only or empty input writes no files.**
- **Windows: files open in another program.** If an output file from an earlier run is open in another program (for example Excel), splitlane crashes with `PermissionError` when it tries to overwrite that file. The chunks written before the crash are new and the rest are old, and the error doesn't say which file failed. Close the files or use a new output directory. This is tracked as #57.

## Using it as a library

```python
from splitlane.split import split_file

written, truncated = split_file("export.csv", 50000, "chunks",
                                max_row_bytes=65536, encoding="utf-8")
# written:   list of output file paths
# truncated: number of rows cut at max_row_bytes
```

`split_file` raises `UnicodeDecodeError` if the input doesn't match `encoding`.

## Upgrading from 0.3.x

The upcoming 0.4.0 release changes behavior that scripts may depend on:

- Output files are renamed from `chunk_1.csv`, `chunk_2.csv`, … to `part-0001.csv`, `part-0002.csv`, …
- Quoted line breaks no longer split a row.
- Decoding errors exit with status `3`, and `--rows 0` exits with status `2` instead of looping.

See [CHANGELOG.md](CHANGELOG.md) for the full list.
