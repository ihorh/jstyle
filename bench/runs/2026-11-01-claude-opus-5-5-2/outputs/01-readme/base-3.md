# splitlane

splitlane splits a large CSV file into smaller files. Every output file starts with the input's header row, so you can import or process each one on its own.

```bash
splitlane data/export.csv --rows 50000 --out chunks
```

```
chunks/part-0001.csv
chunks/part-0002.csv
chunks/part-0003.csv
...
```

It needs only the Python standard library. It reads the input once, one row at a time, so memory use stays flat even on very large exports.

> **Version note:** This README describes the current `main` branch, which will be released as 0.4.0. If you're on 0.3.x, see [What changed in 0.4.0](#what-changed-in-040). Some of the behavior below is different there.

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
| `--out DIR` | `out` | Output directory. It's created if it doesn't exist. |
| `--max-row-bytes N` | `65536` | Size limit for a single row. Longer rows are truncated (see below). |
| `--encoding NAME` | `utf-8` | Encoding of the input file, for example `latin-1` or `cp1252`. |

The output files are named `part-0001.csv`, `part-0002.csv`, and so on. They are always written as UTF-8, whatever the input encoding was.

All messages, including progress, the summary and warnings, go to stderr. stdout stays empty.

### Exit status

| Code | Meaning |
| --- | --- |
| `0` | Success. Check stderr for a truncation warning (see below). |
| `2` | Invalid arguments, for example `--rows 0`. |
| `3` | The input couldn't be decoded with `--encoding`. |

Other failures, like a missing input file or an unwritable output directory, end with a Python traceback and exit status 1.

## How rows are read

**Quoted line breaks stay in the row.** A field like the one below counts as one row, as RFC 4180 and spreadsheet programs expect:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

That file has two data rows, and splitlane keeps both of them intact.

**Long or broken rows are truncated, not dropped silently.** If a row grows past `--max-row-bytes`, splitlane cuts it at that limit. Then it skips ahead to the next line break and carries on. This protects you from a stray, unterminated `"`, which would otherwise make the rest of the file look like one giant field. A bad quote damages one row instead of the whole output.

At the end of the run, splitlane reports how many rows it truncated:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

The exit status is still 0. **If truncated rows matter to you, check stderr for this warning in your scripts.** If your data really does have rows over 64 KiB, raise `--max-row-bytes`.

## Known limitations

- **Failed runs leave partial output.** Chunks are written straight into `--out` as the run goes. If a run fails partway, for example on a decoding error, the chunks written before the failure stay in place. Treat the output of a run that exited non-zero as incomplete.
- **Old chunks aren't cleaned up.** splitlane overwrites chunk files with the same name but doesn't delete anything else. If a new run produces fewer chunks than an earlier run into the same directory, the extra old chunks remain. Use a fresh or empty output directory for each run.
- **Windows: open chunk files cause a crash ([#57](../../issues/57)).** If a chunk from an earlier run is open in another program, such as Excel, splitlane crashes with `PermissionError` when it tries to overwrite that file. The error doesn't say how many chunks were already written, so the directory ends up with a mix of new and old files. Close the files first, or write to a new directory.
- **Resync after truncation can land inside a quoted field.** After a truncated row, splitlane resumes at the next line break, even if that break is inside a quoted field. With a stray quote near a legitimate multi-line field, a following row could also come out wrong. This should be rare.
- **The row size limit counts UTF-8 bytes,** even when the input uses another encoding.
- **A file with only a header produces no chunks.**

## Using it as a library

```python
from splitlane.split import split_file

written, truncated = split_file("data/export.csv", 50000, "chunks",
                                max_row_bytes=65536, encoding="utf-8")
# written:   list of chunk file paths, in order
# truncated: number of rows cut at max_row_bytes
```

If the input can't be decoded, `split_file` raises `UnicodeDecodeError`.

## What changed in 0.4.0

Upgrading from 0.3.x? These changes may affect your pipeline:

- **Output files are renamed** from `chunk_1.csv`, `chunk_2.csv`, … to `part-0001.csv`, `part-0002.csv`, …. Update anything that matches the old names.
- Quoted fields that contain line breaks now stay in one row. Before, they were split into two broken rows ([#42](../../issues/42)).
- An unterminated quote now damages one row, which is truncated and counted, instead of the rest of the file.
- The number of truncated rows is reported at the end of the run.
- `--rows 0` now exits with status 2 instead of looping.
- A decoding failure now exits with status 3 and a clear message.

The full history is in [CHANGELOG.md](CHANGELOG.md).
