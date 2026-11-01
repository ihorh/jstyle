# splitlane 0.4.0

This release fixes how splitlane handles quoted fields that contain line breaks (#42). It also renames the output files and adds new exit codes. **If you have scripts or pipelines built on 0.3.1, read "Breaking changes" before you upgrade.**

## Breaking changes

### Output files have new names

Chunks used to be named `chunk_1.csv`, `chunk_2.csv`, … and are now named `part-0001.csv`, `part-0002.csv`, …

- Update any script, glob, or downstream job that looks for `chunk_*.csv`.
- splitlane does not delete old files. If you reuse an output directory from 0.3.1, the old `chunk_*.csv` files will still be there next to the new `part-*.csv` files. Clear the directory first, or use a new one.
- The number has four digits. A run with more than 9,999 chunks continues with `part-10000.csv`, which sorts out of order in a plain text sort.

### Quoted line breaks stay inside the row

A line break inside a quoted field (RFC 4180) is now part of the field and no longer ends the row. Take this input:

```
id,name,notes
7,Ana,"called twice
asked for refund"
8,Bo,ok
```

It now gives two data rows, where 0.3.1 gave three broken ones. If you added a workaround for split rows downstream, you can remove it. Row counts per chunk may also change, since `--rows` now counts real rows and not physical lines.

### New exit codes

| Status | Meaning |
|---|---|
| 0 | Success (this includes runs with truncated rows, see below) |
| 2 | Invalid `--rows` value (anything below 1) |
| 3 | Input could not be decoded with `--encoding` |

## Fixes

- **`--rows 0` no longer loops forever.** splitlane now prints `--rows must be at least 1` and exits with status 2. Negative values are rejected the same way.
- **An unmatched quote no longer swallows the rest of the file.** If a row grows past `--max-row-bytes` (default 65536), for example because of a stray `"`, splitlane cuts the row at that limit and skips to the next line break. Then it carries on with the rest of the file. You lose one damaged row and keep the rest of the file.

## New behavior

### Truncated rows are reported

At the end of a run, splitlane prints a warning to stderr when rows were cut:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

**The exit status is still 0 in this case.** A truncated row is still written to the chunk, just shortened. If your downstream importer can't detect short rows, have your scripts check stderr for this warning. If you have legitimately long rows, raise `--max-row-bytes`.

Library users: `read_row()` returns a `(row, truncated)` pair, and `split_file()` returns `(written_files, truncated_count)`.

### Decode errors exit with status 3

When the input doesn't match `--encoding`, splitlane now prints a clear message and exits with status 3:

```
splitlane: cannot decode exports/customers.csv as utf-8: 'utf-8' codec can't decode byte 0xe9 ...
```

**Chunks written before the error are left in the output directory**, and the last one may be incomplete. If you get status 3, delete the output, then rerun with the correct encoding. For example, many legacy exports need `--encoding latin-1`.

## Known issues

- **Windows: crash when a chunk file is open in another program (#57).** If a `part-*.csv` from an earlier run is open, for example in Excel, splitlane crashes with `PermissionError` when it tries to overwrite that file. The chunks before it have already been replaced, and the error doesn't say which file failed. This leaves a mix of new and old chunks. Until this is fixed, close any open chunk files before a run, or write to a new, empty `--out` directory each time.
- **Recovery after a truncated row can land inside a quoted field.** After cutting an oversized row, splitlane resumes at the next line break, even if that line break is inside quotes. In rare cases, one unmatched quote can therefore damage a second row next to it. Check the truncation warning to catch this.

## Upgrading from 0.3.1: checklist

1. Change references from `chunk_N.csv` to `part-NNNN.csv`, and clear out old output directories.
2. Treat exit status 2 and 3 as failures in your scripts. On status 3, delete the partial output.
3. Check stderr for the `row(s) ... were truncated` warning, because it doesn't change the exit status.
4. On Windows, close any open chunk files before you run splitlane.
