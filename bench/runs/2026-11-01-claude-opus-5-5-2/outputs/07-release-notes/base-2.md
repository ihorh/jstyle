# splitlane 0.4.0

This release fixes how splitlane handles quoted fields that contain line breaks (#42). It also renames the output files, which breaks existing setups. **If you're upgrading from 0.3.1, read "Breaking changes" first.**

## Breaking changes

### Output files have new names

Chunk files are now called `part-0001.csv`, `part-0002.csv`, and so on. In 0.3.1 they were `chunk_1.csv`, `chunk_2.csv`, and so on.

- Update any script, glob or import job that looks for `chunk_*.csv`.
- splitlane doesn't delete old files. If you reuse an output directory from a 0.3.1 run, the old `chunk_*.csv` files stay next to the new `part-*.csv` files. A pipeline that still matches `chunk_*.csv` will then quietly read stale data. Start with an empty `--out` directory, or clear out the old files.
- The new names are zero-padded, so they sort correctly as text (`part-0002` sorts before `part-0010`).

### Row counts can change for files with multi-line fields

splitlane now follows RFC 4180: a line break inside a quoted field is part of the field, not the end of the row. In 0.3.1 such a row was split into two broken rows. If your input has fields like this (for example, a `notes` column in a CRM export), you'll get fewer rows than before, with correct contents. Chunk boundaries move to match.

## Fixes

- **Quoted line breaks stay in one row (#42).** For example, this input now gives two data rows instead of three:

  ```
  id,name,notes
  7,Ana,"called twice
  asked for refund"
  8,Bo,ok
  ```

- **An unterminated quote no longer swallows the rest of the file (#42).** If a stray `"` would otherwise make the rest of the file one huge field, the row is cut off at `--max-row-bytes`. splitlane counts it as truncated and goes on with the next line. A broken quote damages one row, not the whole output.
- **`--rows 0` no longer hangs.** A `--rows` value below 1 now exits right away with status 2 and the message `splitlane: --rows must be at least 1`.

## Changes

### Truncated rows are reported

At the end of a run, splitlane now prints how many rows were truncated, on stderr:

```
splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
```

A truncated row keeps its first `--max-row-bytes` bytes. Everything after that, up to the next line break, is dropped.

- **The exit status is still 0 when rows are truncated.** If your downstream tools can't detect a shortened row, have your scripts check stderr for this warning.
- If real rows in your data are longer than 65536 bytes, raise `--max-row-bytes`.
- After truncating a row, splitlane goes on at the next line break, even if that line break is inside a quoted field. So in rare cases the row after a truncated row can also come out wrong.

### Exit status 3 for decode errors

If the input can't be decoded with the given `--encoding`, splitlane now exits with status 3 and a message like this:

```
splitlane: cannot decode exports/customers.csv as utf-8: 'utf-8' codec can't decode byte 0xe9 ...
```

The error can come partway through the file. **By then, some chunks may already be written**, so the output directory holds partial output. Don't use it. Rerun with the correct encoding (for example, `--encoding latin-1` for ISO-8859 files) into an empty directory.

### Exit status summary

| Status | Meaning |
|---|---|
| 0 | Success (check stderr for a truncation warning) |
| 2 | Invalid arguments, such as `--rows 0` |
| 3 | The input couldn't be decoded with `--encoding` |

## Known issue: Windows (#57)

On Windows, if a chunk file from an earlier run is open in another program (such as Excel), splitlane crashes with `PermissionError` when it tries to overwrite that file. The chunks before it have already been overwritten with new data, and the chunks after it are still from the old run. The error doesn't say which file failed.

**Workaround:** close any open chunk files before running splitlane, or write to a new, empty `--out` directory each time. If splitlane exits with `PermissionError`, treat the whole output directory as unusable and run it again.

## Upgrade checklist

1. Change references from `chunk_N.csv` to `part-NNNN.csv`.
2. Use an empty output directory, or delete the old `chunk_*.csv` files.
3. Make your scripts handle exit statuses 2 and 3, and check stderr for the truncation warning.
4. If you're on Windows, close chunk files before each run (see #57).
