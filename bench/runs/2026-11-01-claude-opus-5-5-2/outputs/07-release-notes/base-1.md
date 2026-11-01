# splitlane 0.4.0

This release fixes how quoted fields that contain line breaks are handled (#42), renames the output files, and adds clearer errors and exit statuses. **Read "Breaking changes" before you upgrade.** If any script, pipeline or import job looks for splitlane's output files by name, it will need to change.

## Breaking changes

### Output files have new names

Chunk files are now named with a zero-padded number:

| 0.3.1 | 0.4.0 |
|---|---|
| `chunk_1.csv` | `part-0001.csv` |
| `chunk_2.csv` | `part-0002.csv` |
| `chunk_10.csv` | `part-0010.csv` |

Update anything that matches `chunk_*.csv`. The new names also sort in the right order as plain text.

splitlane doesn't remove files from earlier runs. If you reuse an output directory from 0.3.1, the old `chunk_*.csv` files stay next to the new `part-*.csv` files. Empty the directory first, or use a new one.

### Quoted line breaks stay inside the row (#42)

In 0.3.1, every line break ended a row, even one inside a quoted field. A row like this:

```
7,Ana,"called twice
asked for refund"
```

was split into two broken rows. In 0.4.0 it stays one row, as RFC 4180 specifies and as spreadsheet programs expect. If your data has multi-line quoted fields, such as a notes column in a CRM export, you'll get fewer rows than before, and the counts will be correct. Rows are counted the new way when filling chunks for `--rows`.

## Data that may be lost: truncated rows

Because splitlane now tracks quotes, a stray unmatched `"` could make it read the rest of the file as one field. To prevent that, a row is capped at `--max-row-bytes` (default 65536):

- splitlane keeps the row up to the limit, skips ahead to the next line break and continues from there.
- At the end of the run it prints a warning to stderr:
  ```
  splitlane: warning: 3 row(s) longer than 65536 bytes were truncated
  ```

Things to know:

- **The exit status is still 0 when rows are truncated.** If your scripts need to catch this, check stderr for `warning:` and `truncated`.
- One stray quote can pull the next rows into the truncated row. So you may lose more than one input row, up to `--max-row-bytes` of data, though only one row appears damaged in the output.
- In rare cases the skip after truncation stops at a line break inside a real multi-line field, so the next row may be misread. This is a known limitation.
- If your real rows are longer than 64 KiB, raise `--max-row-bytes`.

## Other changes

- **`--rows` below 1 is now an error.** `--rows 0` used to loop forever. It now prints `splitlane: --rows must be at least 1` and exits with status 2.
- **Encoding errors exit with status 3** and name the file and encoding:
  ```
  splitlane: cannot decode exports/customers.csv as utf-8: ...
  ```
  If you see this, pass the right `--encoding` (for example `--encoding latin-1`). **Chunks written before the error stay on disk**, and the last one is incomplete. Treat any run that exits with a nonzero status as failed, and delete its output.
- **Library users:** `read_row()` now returns a `(row, truncated)` pair instead of a bare row.

## Known issue: Windows (#57)

On Windows, if a chunk file from an earlier run is open in another program (for example Excel), splitlane crashes with `PermissionError` when it tries to overwrite that file. Chunks before that file have already been replaced and later ones haven't, so the directory holds a mix of new and old chunks. The error doesn't say which file failed.

Until this is fixed, close the chunk files before you run splitlane, or write to a new, empty output directory each time. If the run fails, discard the whole output directory.

## Upgrading from 0.3.1

1. Replace any `chunk_N.csv` patterns with `part-NNNN.csv`.
2. Start from an empty output directory.
3. Treat exit status 2 (bad arguments) and 3 (encoding error) as failures, and delete the output from those runs.
4. If you can't accept lost data, check stderr for the truncation warning, since those runs still exit with status 0.
